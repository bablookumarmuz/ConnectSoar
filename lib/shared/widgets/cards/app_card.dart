import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.paddingMd,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusLg,
        child: content,
      );
    }
    return content;
  }
}
