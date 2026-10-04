import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/feedback/app_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../domain/models/meeting_model.dart';
import 'qr_code_placeholder.dart';

class ShareMeetingSheet extends StatelessWidget {
  final MeetingModel meeting;

  const ShareMeetingSheet({super.key, required this.meeting});

  static Future<void> show(BuildContext context, MeetingModel meeting) {
    return AppBottomSheet.show(
      context: context,
      title: 'Share Meeting Invite',
      child: ShareMeetingSheet(meeting: meeting),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          meeting.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        AppSpacing.gapXs,
        Text(
          'Share this room code or QR code with participants to invite them.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        AppSpacing.gapLg,

        // QR Visual Placeholder
        QrCodePlaceholder(data: meeting.meetingLink, size: 170),
        AppSpacing.gapLg,

        // Meeting Code Box
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              Text(
                'MEETING CODE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
              AppSpacing.gapXs,
              SelectableText(
                meeting.joinCode,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,

        // Meeting Direct Link Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.link_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              AppSpacing.gapWSm,
              Expanded(
                child: SelectableText(
                  meeting.meetingLink,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // Copy & Share Action Buttons
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Copy Link',
                icon: Icons.copy_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: meeting.meetingLink));
                  AppSnackBar.show(
                    context,
                    message: 'Meeting link copied to clipboard!',
                    type: AppSnackBarType.success,
                  );
                },
              ),
            ),
            AppSpacing.gapWMd,
            Expanded(
              child: AppButton(
                text: 'Share Invite',
                icon: Icons.share_rounded,
                variant: AppButtonVariant.primary,
                onPressed: () {
                  AppSnackBar.show(
                    context,
                    message: 'Invite link shared successfully!',
                    type: AppSnackBarType.info,
                  );
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
