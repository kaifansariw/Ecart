import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';

/// Custom styled text field — no Material TextField chrome.
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final borderColor = hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.accent
            : (isDark ? AppColors.borderDark : AppColors.border);

    final fillColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final hintColor = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelLarge.copyWith(
              color: hasError
                  ? AppColors.error
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: borderColor, width: _isFocused ? 1.5 : 1),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.base),
                  child: Icon(
                    widget.prefixIcon,
                    size: AppSpacing.iconMd,
                    color: _isFocused ? AppColors.accent : hintColor,
                  ),
                ),
              ],
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onEditingComplete: widget.onEditingComplete,
                  enabled: widget.enabled,
                  maxLines: widget.maxLines,
                  validator: widget.validator,
                  style: AppTypography.bodyLarge.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: AppTypography.bodyLarge.copyWith(color: hintColor),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null
                          ? AppSpacing.md
                          : AppSpacing.base,
                      vertical: AppSpacing.base,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              if (widget.suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: widget.suffixIcon!,
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
