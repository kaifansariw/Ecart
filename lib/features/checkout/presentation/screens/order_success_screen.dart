import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});
  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)));
    _controller.forward();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          ScaleTransition(scale: _scale, child: Container(
            width: 100, height: 100, decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 56, color: AppColors.success),
          )),
          const SizedBox(height: AppSpacing.xxl),
          FadeTransition(opacity: _fade, child: Column(children: [
            Text('Order Placed!', style: AppTypography.displaySmall),
            const SizedBox(height: AppSpacing.md),
            Text('Your order has been placed successfully.\nYou\'ll receive a confirmation email shortly.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (widget.orderId.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                child: Text('Order #${widget.orderId.substring(0, 8).toUpperCase()}', style: AppTypography.labelMedium),
              ),
            ],
          ])),
          const Spacer(),
          CustomButton(label: 'View Order', variant: ButtonVariant.outline, onPressed: () => context.go('/orders/${widget.orderId}')),
          const SizedBox(height: AppSpacing.md),
          CustomButton(label: 'Continue Shopping', onPressed: () => context.go('/')),
          const SizedBox(height: AppSpacing.xl),
        ],
      ))),
    );
  }
}
