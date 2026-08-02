import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/app_config.dart';
import '../../../../services/supabase_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await SupabaseService.from('orders').select().eq('user_id', SupabaseService.userId!).order('created_at', ascending: false);
      if (mounted) setState(() { _orders = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered': return AppColors.success;
      case 'shipped': return AppColors.info;
      case 'cancelled': return AppColors.error;
      case 'processing': return AppColors.warning;
      default: return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Row(children: [
          GestureDetector(onTap: () => context.pop(), child: Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
          const SizedBox(width: AppSpacing.base),
          Text('Order History', style: AppTypography.headingMedium),
        ])),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
              : _orders.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: AppSpacing.md),
                      Text('No orders yet', style: AppTypography.headingSmall.copyWith(color: AppColors.textTertiary)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: _orders.length,
                      itemBuilder: (_, i) {
                        final o = _orders[i];
                        final status = o['status'] ?? 'pending';
                        return GestureDetector(
                          onTap: () => context.push('/orders/${o['id']}'),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md), padding: const EdgeInsets.all(AppSpacing.base),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 0.5),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('#${(o['id'] as String).substring(0, 8).toUpperCase()}', style: AppTypography.labelLarge),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                                  decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                                  child: Text(status.toUpperCase(), style: AppTypography.labelSmall.copyWith(color: _statusColor(status), fontWeight: FontWeight.w700, fontSize: 10)),
                                ),
                              ]),
                              const SizedBox(height: AppSpacing.sm),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(o['created_at']?.toString().substring(0, 10) ?? '', style: AppTypography.bodySmall),
                                Text(AppConfig.formatPrice((o['total'] as num?)?.toDouble() ?? 0), style: AppTypography.price.copyWith(fontSize: 16)),
                              ]),
                            ]),
                          ),
                        );
                      }),
        ),
      ])),
    );
  }
}
