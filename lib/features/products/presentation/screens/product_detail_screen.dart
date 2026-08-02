import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/app_config.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../services/supabase_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _product;
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;
  bool _addingToCart = false;
  int _quantity = 1;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final data = await SupabaseService.from('products')
          .select('*, product_images(*), categories(name)')
          .eq('id', widget.productId)
          .single();
      if (mounted) {
        setState(() {
          _product = data;
          _images = List<Map<String, dynamic>>.from(data['product_images'] ?? []);
          _images.sort((a, b) => (a['sort_order'] ?? 0).compareTo(b['sort_order'] ?? 0));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart() async {
    if (!SupabaseService.isAuthenticated) return;
    setState(() => _addingToCart = true);
    try {
      await SupabaseService.from('cart_items').upsert({
        'user_id': SupabaseService.userId,
        'product_id': widget.productId,
        'quantity': _quantity,
      }, onConflict: 'user_id,product_id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to cart'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _addingToCart = false);
  }

  Future<void> _toggleWishlist() async {
    if (!SupabaseService.isAuthenticated) return;
    try {
      final existing = await SupabaseService.from('wishlist_items')
          .select()
          .eq('user_id', SupabaseService.userId!)
          .eq('product_id', widget.productId);
      if (existing.isNotEmpty) {
        await SupabaseService.from('wishlist_items')
            .delete()
            .eq('user_id', SupabaseService.userId!)
            .eq('product_id', widget.productId);
      } else {
        await SupabaseService.from('wishlist_items').insert({
          'user_id': SupabaseService.userId,
          'product_id': widget.productId,
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)),
      );
    }

    if (_product == null) {
      return Scaffold(
        body: Center(child: Text('Product not found', style: AppTypography.bodyLarge)),
      );
    }

    final price = (_product!['price'] as num?)?.toDouble() ?? 0;
    final comparePrice = (_product!['compare_at_price'] as num?)?.toDouble();
    final rating = (_product!['rating'] as num?)?.toDouble() ?? 0;
    final reviewCount = _product!['review_count'] ?? 0;
    final stock = _product!['stock_quantity'] ?? 0;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery
                  Stack(
                    children: [
                      SizedBox(
                        height: 380,
                        child: _images.isNotEmpty
                            ? PageView.builder(
                                controller: _pageController,
                                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                                itemCount: _images.length,
                                itemBuilder: (_, i) {
                                  return Container(
                                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                                    child: Image.network(
                                      _images[i]['url'] ?? '',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Icon(Icons.image_outlined, size: 64, color: AppColors.textTertiary),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                                child: Center(child: Icon(Icons.image_outlined, size: 64, color: AppColors.textTertiary)),
                              ),
                      ),
                      // Back + Wishlist buttons
                      Positioned(
                        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                        left: AppSpacing.base,
                        right: AppSpacing.base,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CircleButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
                            _CircleButton(icon: Icons.favorite_outline_rounded, onTap: _toggleWishlist),
                          ],
                        ),
                      ),
                      // Page indicator
                      if (_images.length > 1)
                        Positioned(
                          bottom: AppSpacing.base,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_images.length, (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentImageIndex == i ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == i ? AppColors.accent : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            )),
                          ),
                        ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        if (_product!['categories'] != null)
                          Text(
                            (_product!['categories']['name'] ?? '').toString().toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(color: AppColors.accent, letterSpacing: 1.5),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(_product!['name'] ?? '', style: AppTypography.headingLarge),
                        const SizedBox(height: AppSpacing.md),

                        // Rating
                        if (rating > 0)
                          Row(children: [
                            ...List.generate(5, (i) => Icon(
                              i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 18, color: AppColors.rating,
                            )),
                            const SizedBox(width: AppSpacing.sm),
                            Text('$rating ($reviewCount reviews)', style: AppTypography.bodySmall),
                          ]),
                        const SizedBox(height: AppSpacing.lg),

                        // Price
                        Row(children: [
                          Text(AppConfig.formatPrice(price), style: AppTypography.price.copyWith(fontSize: 24)),
                          if (comparePrice != null && comparePrice > price) ...[
                            const SizedBox(width: AppSpacing.md),
                            Text(AppConfig.formatPrice(comparePrice), style: AppTypography.priceStrikethrough.copyWith(fontSize: 16)),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                              child: Text('${(((comparePrice - price) / comparePrice) * 100).round()}% OFF',
                                  style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ]),
                        const SizedBox(height: AppSpacing.sm),
                        Text(stock > 0 ? 'In Stock ($stock available)' : 'Out of Stock',
                            style: AppTypography.bodySmall.copyWith(color: stock > 0 ? AppColors.success : AppColors.error)),

                        const SizedBox(height: AppSpacing.xl),
                        Divider(color: isDark ? AppColors.dividerDark : AppColors.divider),
                        const SizedBox(height: AppSpacing.xl),

                        // Description
                        Text('Description', style: AppTypography.headingSmall),
                        const SizedBox(height: AppSpacing.md),
                        Text(_product!['description'] ?? 'No description available.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.7)),

                        const SizedBox(height: AppSpacing.xl),

                        // Quantity selector
                        Row(children: [
                          Text('Quantity', style: AppTypography.labelLarge),
                          const Spacer(),
                          _QuantityButton(icon: Icons.remove, onTap: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          }),
                          Container(
                            width: 48, alignment: Alignment.center,
                            child: Text('$_quantity', style: AppTypography.headingSmall),
                          ),
                          _QuantityButton(icon: Icons.add, onTap: () {
                            if (_quantity < stock) setState(() => _quantity++);
                          }),
                        ]),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.xl, right: AppSpacing.xl,
              top: AppSpacing.base,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.base,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border, width: 0.5)),
            ),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('Total', style: AppTypography.bodySmall),
                Text(AppConfig.formatPrice(price * _quantity), style: AppTypography.price),
              ]),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: CustomButton(
                  label: 'Add to Cart',
                  icon: Icons.shopping_bag_outlined,
                  onPressed: stock > 0 ? _addToCart : null,
                  isLoading: _addingToCart,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40, alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36, alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
