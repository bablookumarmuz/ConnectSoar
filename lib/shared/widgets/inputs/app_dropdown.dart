import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class AppDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppDropdownItem({required this.value, required this.label, this.icon});
}

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final T value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;

  const AppDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapHXs,
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: isDark
              ? AppColors.darkSurfaceElevated
              : AppColors.lightSurface,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusMd,
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusMd,
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.darkBorderFocus
                    : AppColors.lightBorderFocus,
                width: 1.5,
              ),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item.value,
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 15,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
