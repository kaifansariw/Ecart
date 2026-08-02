import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';

/// Reusable button with variants: primary, secondary, outline, text.
/// Includes animated press scale effect.
enum ButtonVariant { primary, secondary, outline, text }

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final double? height;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.height,
    this.borderRadius,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (widget.variant) {
      case ButtonVariant.primary:
        bgColor = AppColors.primary;
        textColor = AppColors.textOnPrimary;
        borderColor = Colors.transparent;
        break;
      case ButtonVariant.secondary:
        bgColor = AppColors.accent;
        textColor = AppColors.textOnAccent;
        borderColor = Colors.transparent;
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
        borderColor = isDark ? AppColors.borderDark : AppColors.border;
        break;
      case ButtonVariant.text:
        bgColor = Colors.transparent;
        textColor = AppColors.accent;
        borderColor = Colors.transparent;
        break;
    }

    if (_isDisabled) {
      bgColor = bgColor.withValues(alpha: 0.5);
      textColor = textColor.withValues(alpha: 0.5);
    }

    final radius = widget.borderRadius ?? AppSpacing.radiusLg;
    final height = widget.height ?? 52.0;

    Widget child;
    if (widget.isLoading) {
      child = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(textColor),
        ),
      );
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: AppSpacing.iconMd, color: textColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            widget.label,
            style: AppTypography.button.copyWith(color: textColor),
          ),
        ],
      );
    }

    final button = GestureDetector(
      onTapDown: _isDisabled ? null : (_) => _controller.forward(),
      onTapUp: _isDisabled
          ? null
          : (_) {
              _controller.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: _isDisabled ? null : () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: child,
        ),
      ),
    );

    return widget.isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
