import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/app_config.dart';
import '../../../../services/supabase_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final order = await SupabaseService.from('orders').select().eq('id', widget.orderId).single();
      final items = await SupabaseService.from('order_items').select().eq('order_id', widget.orderId);
      if (mounted) setState(() { _order = order; _items = List<Map<String, dynamic>>.from(items); _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)));
    if (_order == null) return Scaffold(body: Center(child: Text('Order not found')));

    final status = _order!['status'] ?? 'pending';
    final addr = _order!['shipping_address'] as Map<String, dynamic>?;

    return Scaffold(
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Row(children: [
          GestureDetector(onTap: () => context.pop(), child: Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
          const SizedBox(width: AppSpacing.base),
          Text('Order Details', style: AppTypography.headingMedium),
        ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Status
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            child: Row(children: [
              Icon(Icons.local_shipping_outlined, color: AppColors.accent),
              const SizedBox(width: AppSpacing.md),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Status', style: AppTypography.labelSmall),
                Text(status.toUpperCase(), style: AppTypography.labelLarge.copyWith(color: AppColors.accent)),
              ]),
            ]),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Items
          Text('Items', style: AppTypography.headingSmall),
          const SizedBox(height: AppSpacing.md),
          ..._items.map((item) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                child: item['product_image'] != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(AppSpacing.radiusSm), child: Image.network(item['product_image'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, color: AppColors.textTertiary)))
                    : Icon(Icons.image_outlined, color: AppColors.textTertiary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['product_name'] ?? '', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                Text('Qty: ${item['quantity']}  ×  ${AppConfig.formatPrice((item['price'] as num?)?.toDouble() ?? 0)}', style: AppTypography.bodySmall),
              ])),
              Text(AppConfig.formatPrice((item['subtotal'] as num?)?.toDouble() ?? 0), style: AppTypography.labelLarge),
            ]),
          )),
          const SizedBox(height: AppSpacing.xl),

          // Address
          if (addr != null) ...[
            Text('Shipping Address', style: AppTypography.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Text('${addr['full_name'] ?? ''}', style: AppTypography.bodyMedium),
            Text('${addr['address_line_1'] ?? ''}, ${addr['city'] ?? ''} ${addr['postal_code'] ?? ''}', style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Summary
          Divider(color: isDark ? AppColors.dividerDark : AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          _Row('Subtotal', AppConfig.formatPrice((_order!['subtotal'] as num?)?.toDouble() ?? 0)),
          _Row('Shipping', AppConfig.formatPrice((_order!['shipping_cost'] as num?)?.toDouble() ?? 0)),
          _Row('Tax', AppConfig.formatPrice((_order!['tax'] as num?)?.toDouble() ?? 0)),
          const SizedBox(height: AppSpacing.sm),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total', style: AppTypography.headingSmall),
            Text(AppConfig.formatPrice((_order!['total'] as num?)?.toDouble() ?? 0), style: AppTypography.price.copyWith(fontSize: 22)),
          ]),
          const SizedBox(height: AppSpacing.xxl),
        ]))),
      ])),
    );
  }
}

class _Row extends StatelessWidget {
  final String label; final String value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
    Text(value, style: AppTypography.bodyMedium),
  ]));
}
