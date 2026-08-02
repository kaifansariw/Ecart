import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/app_config.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../services/supabase_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _addresses = [];
  String? _selectedAddressId;
  bool _isLoading = true;
  bool _isPlacingOrder = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final cart = await SupabaseService.from('cart_items').select('*, products(id, name, price, product_images(url, is_primary))').eq('user_id', SupabaseService.userId!);
      final addr = await SupabaseService.from('addresses').select().eq('user_id', SupabaseService.userId!).order('is_default', ascending: false);
      if (mounted) setState(() {
        _cartItems = List<Map<String, dynamic>>.from(cart);
        _addresses = List<Map<String, dynamic>>.from(addr);
        if (_addresses.isNotEmpty) _selectedAddressId = _addresses.first['id'];
        _isLoading = false;
      });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  double get _subtotal => _cartItems.fold(0, (s, i) => s + ((i['products']?['price'] as num?)?.toDouble() ?? 0) * (i['quantity'] ?? 1));
  double get _shipping => _subtotal > 50 ? 0 : 5.99;
  double get _tax => _subtotal * 0.08;
  double get _total => _subtotal + _shipping + _tax;

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) return;
    setState(() => _isPlacingOrder = true);
    try {
      final addr = _addresses.firstWhere((a) => a['id'] == _selectedAddressId);
      final order = await SupabaseService.from('orders').insert({
        'user_id': SupabaseService.userId, 'subtotal': _subtotal, 'shipping_cost': _shipping,
        'tax': _tax, 'total': _total, 'shipping_address': addr, 'payment_method': 'card',
      }).select().single();

      for (final item in _cartItems) {
        final p = item['products'];
        final imgs = p?['product_images'] as List? ?? [];
        final img = imgs.isNotEmpty ? imgs.first['url'] : null;
        await SupabaseService.from('order_items').insert({
          'order_id': order['id'], 'product_id': p?['id'], 'product_name': p?['name'] ?? '',
          'product_image': img, 'price': (p?['price'] as num?)?.toDouble() ?? 0,
          'quantity': item['quantity'] ?? 1, 'subtotal': ((p?['price'] as num?)?.toDouble() ?? 0) * (item['quantity'] ?? 1),
        });
      }
      await SupabaseService.from('cart_items').delete().eq('user_id', SupabaseService.userId!);
      if (mounted) context.go('/order-success?orderId=${order['id']}');
    } catch (e) {
      if (mounted) { setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to place order'), backgroundColor: AppColors.error)); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)));

    return Scaffold(
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Row(children: [
          GestureDetector(onTap: () => context.pop(), child: Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
          const SizedBox(width: AppSpacing.base),
          Text('Checkout', style: AppTypography.headingMedium),
        ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Shipping Address', style: AppTypography.headingSmall),
          const SizedBox(height: AppSpacing.md),
          if (_addresses.isEmpty) Text('No addresses. Please add one in your profile.', style: AppTypography.bodySmall)
          else ..._addresses.map((a) => GestureDetector(
            onTap: () => setState(() => _selectedAddressId = a['id']),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm), padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: _selectedAddressId == a['id'] ? AppColors.accent : (isDark ? AppColors.borderDark : AppColors.border), width: _selectedAddressId == a['id'] ? 2 : 1),
              ),
              child: Row(children: [
                Icon(_selectedAddressId == a['id'] ? Icons.radio_button_checked : Icons.radio_button_off, color: _selectedAddressId == a['id'] ? AppColors.accent : AppColors.textTertiary, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a['label'] ?? 'Address', style: AppTypography.labelLarge),
                  Text('${a['address_line_1']}, ${a['city']}', style: AppTypography.bodySmall),
                ])),
              ]),
            ),
          )),
          const SizedBox(height: AppSpacing.xl),
          Text('Order Summary', style: AppTypography.headingSmall),
          const SizedBox(height: AppSpacing.md),
          ..._cartItems.map((item) {
            final p = item['products'] ?? {};
            return Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text('${p['name'] ?? ''} x${item['quantity']}', style: AppTypography.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(AppConfig.formatPrice(((p['price'] as num?)?.toDouble() ?? 0) * (item['quantity'] ?? 1)), style: AppTypography.labelLarge),
            ]));
          }),
          Divider(color: isDark ? AppColors.dividerDark : AppColors.divider),
          _PriceRow(label: 'Subtotal', value: _subtotal),
          _PriceRow(label: 'Shipping', value: _shipping),
          _PriceRow(label: 'Tax', value: _tax),
          const SizedBox(height: AppSpacing.sm),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total', style: AppTypography.headingSmall),
            Text(AppConfig.formatPrice(_total), style: AppTypography.price.copyWith(fontSize: 22)),
          ]),
          const SizedBox(height: AppSpacing.xxl),
        ]))),
        Container(
          padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.base, bottom: MediaQuery.of(context).padding.bottom + AppSpacing.base),
          child: CustomButton(label: 'Place Order', onPressed: _isPlacingOrder ? null : _placeOrder, isLoading: _isPlacingOrder),
        ),
      ])),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label; final double value;
  const _PriceRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
    Text(AppConfig.formatPrice(value), style: AppTypography.bodyMedium),
  ]));
}
