import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/app_config.dart';
import '../../../../services/supabase_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!SupabaseService.isAuthenticated) { setState(() => _isLoading = false); return; }
    try {
      final data = await SupabaseService.from('wishlist_items')
          .select('*, products(id, name, price, compare_at_price, rating, product_images(url, is_primary))')
          .eq('user_id', SupabaseService.userId!).order('created_at', ascending: false);
      if (mounted) setState(() { _items = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _remove(String id) async {
    await SupabaseService.from('wishlist_items').delete().eq('id', id);
    _load();
  }

  Future<void> _moveToCart(Map<String, dynamic> item) async {
    final product = item['products'];
    if (product == null) return;
    await SupabaseService.from('cart_items').upsert({
      'user_id': SupabaseService.userId, 'product_id': product['id'], 'quantity': 1,
    }, onConflict: 'user_id,product_id');
    await _remove(item['id']);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Row(children: [
          Text('Wishlist', style: AppTypography.headingLarge),
          const Spacer(),
          Text('${_items.length} items', style: AppTypography.bodySmall),
        ])),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
              : _items.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.favorite_outline_rounded, size: 64, color: AppColors.textTertiary),
                      const SizedBox(height: AppSpacing.md),
                      Text('Your wishlist is empty', style: AppTypography.headingSmall.copyWith(color: AppColors.textTertiary)),
                    ]))
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: AppSpacing.base, crossAxisSpacing: AppSpacing.base, childAspectRatio: 0.6),
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final item = _items[i];
                        final p = item['products'] ?? {};
                        final imgs = p['product_images'] as List? ?? [];
                        final img = imgs.isNotEmpty ? (imgs.firstWhere((x) => x['is_primary'] == true, orElse: () => imgs.first)['url'] ?? '') : '';
                        final price = (p['price'] as num?)?.toDouble() ?? 0;

                        return GestureDetector(
                          onTap: () => context.push('/products/${p['id']}'),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: Stack(children: [
                              Container(
                                decoration: BoxDecoration(color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                                child: img.isNotEmpty ? ClipRRect(borderRadius: BorderRadius.circular(AppSpacing.radiusLg), child: Image.network(img, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.image_outlined, color: AppColors.textTertiary)))) : Center(child: Icon(Icons.image_outlined, color: AppColors.textTertiary, size: 32)),
                              ),
                              Positioned(top: AppSpacing.sm, right: AppSpacing.sm, child: GestureDetector(
                                onTap: () => _remove(item['id']),
                                child: Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                                  child: Icon(Icons.close_rounded, size: 16, color: AppColors.textPrimary)),
                              )),
                            ])),
                            const SizedBox(height: AppSpacing.sm),
                            Text(p['name'] ?? '', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(AppConfig.formatPrice(price), style: AppTypography.price.copyWith(fontSize: 15)),
                            const SizedBox(height: AppSpacing.xs),
                            GestureDetector(
                              onTap: () => _moveToCart(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(border: Border.all(color: AppColors.accent), borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                                child: Text('Move to Cart', style: AppTypography.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ]),
                        );
                      }),
        ),
      ])),
    );
  }
}
