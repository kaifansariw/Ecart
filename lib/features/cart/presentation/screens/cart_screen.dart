import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/app_config.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../services/supabase_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadCart(); }

  Future<void> _loadCart() async {
    if (!SupabaseService.isAuthenticated) { setState(() => _isLoading = false); return; }
    try {
      final data = await SupabaseService.from('cart_items')
          .select('*, products(id, name, price, stock_quantity, product_images(url, is_primary))')
          .eq('user_id', SupabaseService.userId!)
          .order('created_at');
      if (mounted) setState(() { _items = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _updateQuantity(String id, int qty) async {
    if (qty < 1) { await _removeItem(id); return; }
    await SupabaseService.from('cart_items').update({'quantity': qty}).eq('id', id);
    _loadCart();
  }

  Future<void> _removeItem(String id) async {
    await SupabaseService.from('cart_items').delete().eq('id', id);
    _loadCart();
  }

  double get _subtotal => _items.fold(0, (sum, item) {
    final price = (item['products']?['price'] as num?)?.toDouble() ?? 0;
    final qty = item['quantity'] ?? 1;
    return sum + (price * qty);
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(children: [
              Text('Cart', style: AppTypography.headingLarge),
              const Spacer(),
              Text('${_items.length} items', style: AppTypography.bodySmall),
            ]),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
                : _items.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.md),
                        Text('Your cart is empty', style: AppTypography.headingSmall.copyWith(color: AppColors.textTertiary)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Browse products and add items', style: AppTypography.bodySmall),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final item = _items[i];
                          final product = item['products'] ?? {};
                          final price = (product['price'] as num?)?.toDouble() ?? 0;
                          final qty = item['quantity'] ?? 1;
                          final imgs = product['product_images'] as List? ?? [];
                          final img = imgs.isNotEmpty ? (imgs.firstWhere((x) => x['is_primary'] == true, orElse: () => imgs.first)['url'] ?? '') : '';

                          return Dismissible(
                            key: ValueKey(item['id']),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _removeItem(item['id']),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: AppSpacing.xl),
                              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                              child: Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.base),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 0.5),
                              ),
                              child: Row(children: [
                                Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  ),
                                  child: img.isNotEmpty
                                      ? ClipRRect(borderRadius: BorderRadius.circular(AppSpacing.radiusMd), child: Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, color: AppColors.textTertiary)))
                                      : Icon(Icons.image_outlined, color: AppColors.textTertiary),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(product['name'] ?? '', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(AppConfig.formatPrice(price), style: AppTypography.labelLarge.copyWith(color: AppColors.accent)),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(children: [
                                    _QtyBtn(icon: Icons.remove, onTap: () => _updateQuantity(item['id'], qty - 1)),
                                    Container(width: 36, alignment: Alignment.center, child: Text('$qty', style: AppTypography.labelLarge)),
                                    _QtyBtn(icon: Icons.add, onTap: () => _updateQuantity(item['id'], qty + 1)),
                                  ]),
                                ])),
                                Text(AppConfig.formatPrice(price * qty), style: AppTypography.price.copyWith(fontSize: 16)),
                              ]),
                            ),
                          );
                        },
                      ),
          ),
          if (_items.isNotEmpty)
            Container(
              padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.base, bottom: MediaQuery.of(context).padding.bottom + AppSpacing.base),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border, width: 0.5)),
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Subtotal', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  Text(AppConfig.formatPrice(_subtotal), style: AppTypography.price),
                ]),
                const SizedBox(height: AppSpacing.base),
                CustomButton(label: 'Proceed to Checkout', onPressed: () => context.push('/checkout')),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(onTap: onTap, child: Container(
      width: 28, height: 28, alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border), borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 14),
    ));
  }
}
