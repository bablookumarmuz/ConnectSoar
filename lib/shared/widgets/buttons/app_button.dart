import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final height = switch (size) {
      AppButtonSize.sm => 36.0,
      AppButtonSize.md => 44.0,
      AppButtonSize.lg => 52.0,
    };

    final fontSize = switch (size) {
      AppButtonSize.sm => 13.0,
      AppButtonSize.md => 14.0,
      AppButtonSize.lg => 16.0,
    };

    final padding = switch (size) {
      AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 12),
      AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 16),
      AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 24),
    };

    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bgColor = isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated;
        fgColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        borderSide = BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        );
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        borderSide = BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        );
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.danger;
        fgColor = Colors.white;
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: fontSize + 2,
            height: fontSize + 2,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: fontSize + 4, color: fgColor),
            if (text.isNotEmpty) AppSpacing.gapWXs,
          ],
          if (text.isNotEmpty)
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ],
    );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 0,
      padding: padding,
      minimumSize: Size(isFullWidth ? double.infinity : 0, height),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusMd,
        side: borderSide,
      ),
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading || onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
