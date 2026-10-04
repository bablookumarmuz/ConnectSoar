import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/domain/models/user_model.dart';

enum BadgeType { live, scheduled, ended, success, warning, danger, info }

class StatusBadge extends StatelessWidget {
  final String? label;
  final BadgeType type;
  final bool showDot;
  final UserStatus? status;

  const StatusBadge({
    super.key,
    this.label,
    this.type = BadgeType.scheduled,
    this.showDot = true,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;
    String displayText = label ?? 'ACTIVE';

    if (status != null) {
      displayText = status!.name.toUpperCase();
      switch (status!) {
        case UserStatus.online:
          bgColor = isDark
              ? AppColors.successContainerDark
              : AppColors.successContainer;
          fgColor = AppColors.success;
          break;
        case UserStatus.busy:
          bgColor = isDark
              ? AppColors.dangerContainerDark
              : AppColors.dangerContainer;
          fgColor = AppColors.danger;
          break;
        case UserStatus.away:
          bgColor = isDark
              ? AppColors.warningContainerDark
              : AppColors.warningContainer;
          fgColor = AppColors.warning;
          break;
        case UserStatus.offline:
          bgColor = isDark
              ? AppColors.darkSurfaceElevated
              : AppColors.lightSurfaceElevated;
          fgColor = isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary;
          break;
      }
    } else {
      switch (type) {
        case BadgeType.live:
          bgColor = isDark
              ? AppColors.dangerContainerDark
              : AppColors.dangerContainer;
          fgColor = AppColors.danger;
          break;
        case BadgeType.scheduled:
          bgColor = isDark
              ? AppColors.primaryContainerDark
              : AppColors.primaryContainer;
          fgColor = AppColors.primary;
          break;
        case BadgeType.ended:
          bgColor = isDark
              ? AppColors.darkSurfaceElevated
              : AppColors.lightSurfaceElevated;
          fgColor = isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary;
          break;
        case BadgeType.success:
          bgColor = isDark
              ? AppColors.successContainerDark
              : AppColors.successContainer;
          fgColor = AppColors.success;
          break;
        case BadgeType.warning:
          bgColor = isDark
              ? AppColors.warningContainerDark
              : AppColors.warningContainer;
          fgColor = AppColors.warning;
          break;
        case BadgeType.danger:
          bgColor = isDark
              ? AppColors.dangerContainerDark
              : AppColors.dangerContainer;
          fgColor = AppColors.danger;
          break;
        case BadgeType.info:
          bgColor = isDark
              ? AppColors.infoContainerDark
              : AppColors.infoContainer;
          fgColor = AppColors.info;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fgColor, shape: BoxShape.circle),
            ),
            AppSpacing.gapWXs,
          ],
          Text(
            displayText.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
