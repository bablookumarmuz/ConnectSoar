import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/avatars/app_avatar.dart';
import '../../../../shared/widgets/badges/role_badge.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../auth/domain/models/user_model.dart';

class UserProfileDialog extends StatelessWidget {
  final UserModel user;

  const UserProfileDialog({super.key, required this.user});

  static void show(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => UserProfileDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Profile Header Avatar
            AppAvatar(
              name: user.name,
              imageUrl: user.avatarUrl,
              size: 80,
              status: user.status,
            ),
            AppSpacing.gapMd,

            // Name & Title
            Text(
              user.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapXXs,
            Text(
              user.title,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapSm,

            // Role & Status Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoleBadge(role: user.role),
                AppSpacing.gapSm,
                StatusBadge(status: user.status),
              ],
            ),
            AppSpacing.gapLg,

            const Divider(),
            AppSpacing.gapSm,

            // User Info Details
            _buildDetailRow(
              context,
              icon: Icons.business_center_outlined,
              label: 'Department',
              value: user.department,
              isDark: isDark,
            ),
            AppSpacing.gapSm,
            _buildDetailRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email,
              isDark: isDark,
            ),
            AppSpacing.gapSm,
            _buildDetailRow(
              context,
              icon: Icons.schedule_outlined,
              label: 'Timezone',
              value: 'UTC+05:30 (Asia/Kolkata)',
              isDark: isDark,
            ),

            AppSpacing.gapLg,

            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Direct Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.md,
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.chat);
                    },
                  ),
                ),
                AppSpacing.gapSm,
                Expanded(
                  child: AppButton(
                    text: 'Start Call',
                    icon: Icons.video_call_rounded,
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.md,
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('${AppRoutes.meetings}/pre-join/mtg_live_1');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
        AppSpacing.gapSm,
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
