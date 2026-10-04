import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

enum AppIconButtonVariant { primary, secondary, outline, ghost, danger }

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final double size;
  final double iconSize;
  final String? tooltip;
  final bool isSelected;
  final Color? activeColor;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppIconButtonVariant.secondary,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.tooltip,
    this.isSelected = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color iconColor;
    BorderSide borderSide = BorderSide.none;

    if (isSelected && activeColor != null) {
      bgColor = activeColor!;
      iconColor = Colors.white;
    } else {
      switch (variant) {
        case AppIconButtonVariant.primary:
          bgColor = AppColors.primary;
          iconColor = Colors.white;
          break;
        case AppIconButtonVariant.secondary:
          bgColor = isDark
              ? AppColors.darkSurfaceElevated
              : AppColors.lightSurfaceElevated;
          iconColor = isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary;
          borderSide = BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          );
          break;
        case AppIconButtonVariant.outline:
          bgColor = Colors.transparent;
          iconColor = isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary;
          borderSide = BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          );
          break;
        case AppIconButtonVariant.ghost:
          bgColor = Colors.transparent;
          iconColor = isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary;
          break;
        case AppIconButtonVariant.danger:
          bgColor = AppColors.dangerContainerDark;
          iconColor = AppColors.danger;
          break;
      }
    }

    Widget button = InkWell(
      onTap: onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      borderRadius: AppRadius.borderRadiusMd,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.borderRadiusMd,
          border: borderSide != BorderSide.none
              ? Border.fromBorderSide(borderSide)
              : null,
        ),
        child: Center(
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
