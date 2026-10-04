import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

enum AppSnackBarType { success, error, info, warning }

abstract class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;
    IconData icon;

    switch (type) {
      case AppSnackBarType.success:
        bgColor = isDark
            ? AppColors.successContainerDark
            : AppColors.successContainer;
        fgColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case AppSnackBarType.error:
        bgColor = isDark
            ? AppColors.dangerContainerDark
            : AppColors.dangerContainer;
        fgColor = AppColors.danger;
        icon = Icons.error_rounded;
        break;
      case AppSnackBarType.warning:
        bgColor = isDark
            ? AppColors.warningContainerDark
            : AppColors.warningContainer;
        fgColor = AppColors.warning;
        icon = Icons.warning_rounded;
        break;
      case AppSnackBarType.info:
        bgColor = isDark
            ? AppColors.primaryContainerDark
            : AppColors.primaryContainer;
        fgColor = AppColors.primary;
        icon = Icons.info_rounded;
        break;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        backgroundColor: bgColor,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
          side: BorderSide(color: fgColor.withValues(alpha: 0.3), width: 1),
        ),
        content: Row(
          children: [
            Icon(icon, color: fgColor, size: 20),
            AppSpacing.gapWMd,
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
