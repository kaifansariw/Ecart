import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';

/// Custom app bar built entirely from scratch — no Material AppBar.
class CustomAppBar extends StatelessWidget {
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? leading;
  final bool transparent;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.leading,
    this.transparent = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = transparent
        ? Colors.transparent
        : backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface);
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        left: AppSpacing.base,
        right: AppSpacing.base,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: transparent
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        children: [
          if (showBack)
            _AppBarButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack ?? () => Navigator.of(context).pop(),
              color: textColor,
            )
          else if (leading != null)
            leading!
          else
            const SizedBox(width: 40),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: title != null
                ? Text(
                    title!,
                    style: AppTypography.headingSmall.copyWith(color: textColor),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (actions != null && actions!.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: actions!)
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _AppBarButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _AppBarButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  State<_AppBarButton> createState() => _AppBarButtonState();
}

class _AppBarButtonState extends State<_AppBarButton>
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
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(widget.icon, size: AppSpacing.iconLg, color: widget.color),
        ),
      ),
    );
  }
}
