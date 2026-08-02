import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/app_config.dart';
import '../../../../services/supabase_service.dart';

class ProductListScreen extends StatefulWidget {
  final String? categoryId;
  const ProductListScreen({super.key, this.categoryId});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      var query = SupabaseService.from('products')
          .select('*, product_images(*)')
          .eq('is_active', true);
      if (widget.categoryId != null) {
        query = query.eq('category_id', widget.categoryId!);
      }
      final data = await query.order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getImage(Map<String, dynamic> p) {
    final imgs = p['product_images'] as List?;
    if (imgs != null && imgs.isNotEmpty) {
      final primary = imgs.firstWhere((i) => i['is_primary'] == true, orElse: () => imgs.first);
      return primary['url'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Text('Products', style: AppTypography.headingMedium),
                  const Spacer(),
                  Text('${_products.length} items', style: AppTypography.bodySmall),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
                  : _products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textTertiary),
                              const SizedBox(height: AppSpacing.md),
                              Text('No products found', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpacing.base,
                            crossAxisSpacing: AppSpacing.base,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, i) {
                            final p = _products[i];
                            final img = _getImage(p);
                            final price = (p['price'] as num?)?.toDouble() ?? 0;
                            final compare = (p['compare_at_price'] as num?)?.toDouble();
                            return GestureDetector(
                              onTap: () => context.push('/products/${p['id']}'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                      ),
                                      child: img.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                              child: Image.network(img, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                                                  errorBuilder: (_, __, ___) => Center(child: Icon(Icons.image_outlined, color: AppColors.textTertiary))),
                                            )
                                          : Center(child: Icon(Icons.image_outlined, color: AppColors.textTertiary, size: 32)),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(p['name'] ?? '', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Row(children: [
                                    Text(AppConfig.formatPrice(price), style: AppTypography.price.copyWith(fontSize: 15)),
                                    if (compare != null && compare > price) ...[
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(AppConfig.formatPrice(compare), style: AppTypography.priceStrikethrough.copyWith(fontSize: 12)),
                                    ],
                                  ]),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
