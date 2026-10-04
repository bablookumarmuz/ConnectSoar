import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class AppSearchField extends StatelessWidget {
  final String hint;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    this.hint = 'Search meetings, users or channels...',
    this.hintText,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText ?? hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 18,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                onPressed: () {
                  controller?.clear();
                  if (onClear != null) onClear!();
                },
              )
            : null,
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
    );
  }
}
