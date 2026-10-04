import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';

enum EndMeetingChoice { leave, endForAll }

class EndMeetingDialog extends StatelessWidget {
  final bool isHost;

  const EndMeetingDialog({super.key, required this.isHost});

  static Future<EndMeetingChoice?> show(
    BuildContext context, {
    required bool isHost,
  }) {
    return showDialog<EndMeetingChoice>(
      context: context,
      builder: (context) => EndMeetingDialog(isHost: isHost),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusXl,
        side: BorderSide(
          color: isDark ? const Color(0xFF2E3446) : AppColors.lightBorder,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_end_rounded,
                    color: AppColors.danger,
                    size: 22,
                  ),
                ),
                AppSpacing.gapWMd,
                Text(
                  isHost ? 'End or Leave Meeting?' : 'Leave Meeting?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            AppSpacing.gapMd,
            Text(
              isHost
                  ? 'As the meeting host, you can end this session for all participants or leave while keeping the room open.'
                  : 'Are you sure you want to exit this meeting room?',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
            AppSpacing.gapLg,

            if (isHost) ...[
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'End Meeting for All',
                  variant: AppButtonVariant.danger,
                  icon: Icons.power_settings_new_rounded,
                  onPressed: () =>
                      Navigator.of(context).pop(EndMeetingChoice.endForAll),
                ),
              ),
              AppSpacing.gapSm,
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Just Leave Meeting',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.logout_rounded,
                  onPressed: () =>
                      Navigator.of(context).pop(EndMeetingChoice.leave),
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                  AppSpacing.gapWMd,
                  AppButton(
                    text: 'Leave Meeting',
                    variant: AppButtonVariant.danger,
                    icon: Icons.logout_rounded,
                    onPressed: () =>
                        Navigator.of(context).pop(EndMeetingChoice.leave),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
