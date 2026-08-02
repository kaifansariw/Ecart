import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';

/// Shimmer loading placeholder for skeleton screens.
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a product card.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerLoading(height: 180, borderRadius: AppSpacing.radiusLg),
        const SizedBox(height: AppSpacing.sm),
        ShimmerLoading(height: 14, width: 120, borderRadius: AppSpacing.radiusSm),
        const SizedBox(height: AppSpacing.xs),
        ShimmerLoading(height: 12, width: 80, borderRadius: AppSpacing.radiusSm),
        const SizedBox(height: AppSpacing.xs),
        ShimmerLoading(height: 16, width: 60, borderRadius: AppSpacing.radiusSm),
      ],
    );
  }
}
