import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/app_config.dart';
import '../../../../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _featuredProducts = [];
  List<Map<String, dynamic>> _newArrivals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categoriesFuture = SupabaseService.from('categories')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      final featuredFuture = SupabaseService.from('products')
          .select('*, product_images(*)')
          .eq('is_active', true)
          .eq('is_featured', true)
          .limit(6);

      final newArrivalsFuture = SupabaseService.from('products')
          .select('*, product_images(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(10);

      final results = await Future.wait([
        categoriesFuture,
        featuredFuture,
        newArrivalsFuture,
      ]);

      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(results[0]);
          _featuredProducts = List<Map<String, dynamic>>.from(results[1]);
          _newArrivals = List<Map<String, dynamic>>.from(results[2]);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getProductImage(Map<String, dynamic> product) {
    final images = product['product_images'] as List?;
    if (images != null && images.isNotEmpty) {
      final primary = images.firstWhere(
        (img) => img['is_primary'] == true,
        orElse: () => images.first,
      );
      return primary['url'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.accent,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConfig.appName,
                                style: AppTypography.displaySmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                AppConfig.appTagline,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/cart'),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: AppSpacing.iconLg,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                          ),
                          child: Text(
                            'NEW COLLECTION',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textOnAccent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Summer\nEssentials',
                          style: AppTypography.headingLarge.copyWith(
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Categories
              if (_categories.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Categories', style: AppTypography.headingMedium),
                        GestureDetector(
                          onTap: () => context.push('/products'),
                          child: Text('View All',
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.accent)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return GestureDetector(
                          onTap: () => context
                              .push('/products?category=${cat['id']}'),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: AppSpacing.md),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusLg),
                                  ),
                                  child: Icon(Icons.category_rounded,
                                      color: AppColors.textTertiary, size: 24),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  cat['name'] ?? '',
                                  style: AppTypography.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // Featured Products
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Featured', style: AppTypography.headingMedium),
                      GestureDetector(
                        onTap: () => context.push('/products'),
                        child: Text('View All',
                            style: AppTypography.labelMedium
                                .copyWith(color: AppColors.accent)),
                      ),
                    ],
                  ),
                ),
              ),

              _isLoading
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = _featuredProducts[index];
                            final img = _getProductImage(product);
                            final price =
                                (product['price'] as num?)?.toDouble() ?? 0;
                            return GestureDetector(
                              onTap: () => context
                                  .push('/products/${product['id']}'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.surfaceVariantDark
                                            : AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusLg),
                                      ),
                                      child: img.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppSpacing.radiusLg),
                                              child: Image.network(
                                                img,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(Icons.image_outlined,
                                                        color: AppColors
                                                            .textTertiary),
                                              ),
                                            )
                                          : Icon(Icons.image_outlined,
                                              color: AppColors.textTertiary,
                                              size: 32),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    product['name'] ?? '',
                                    style: AppTypography.bodyMedium
                                        .copyWith(fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppConfig.formatPrice(price),
                                    style: AppTypography.price
                                        .copyWith(fontSize: 15),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: _featuredProducts.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.base,
                          crossAxisSpacing: AppSpacing.base,
                          childAspectRatio: 0.7,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
