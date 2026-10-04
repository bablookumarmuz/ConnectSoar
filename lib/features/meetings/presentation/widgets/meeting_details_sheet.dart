import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../providers/meeting_providers.dart';
import '../../../../shared/widgets/avatars/app_avatar.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/feedback/app_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/app_dialog.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../domain/models/meeting_model.dart';
import 'share_meeting_sheet.dart';

class MeetingDetailsSheet extends ConsumerWidget {
  final MeetingModel meeting;

  const MeetingDetailsSheet({super.key, required this.meeting});

  static Future<void> show(BuildContext context, MeetingModel meeting) {
    return AppBottomSheet.show(
      context: context,
      title: 'Meeting Details',
      child: MeetingDetailsSheet(meeting: meeting),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header info: Status & Title
        Row(
          children: [
            StatusBadge(
              label: meeting.status.name.toUpperCase(),
              type: meeting.isLive
                  ? BadgeType.live
                  : meeting.status == MeetingStatus.scheduled
                  ? BadgeType.scheduled
                  : BadgeType.info,
            ),
            AppSpacing.gapWSm,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                meeting.type.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.gapSm,

        Text(
          meeting.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        if (meeting.description.isNotEmpty) ...[
          AppSpacing.gapXs,
          Text(
            meeting.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
        ],
        AppSpacing.gapLg,

        // Host Information
        Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              AppAvatar(
                name: meeting.hostName,
                imageUrl: meeting.hostAvatarUrl,
                size: 40,
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.hostName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Meeting Organizer & Host',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,

        // Logistics Grid (Date, Time, Timezone, Duration, Reminder)
        Column(
          children: [
            _buildDetailRow(
              context,
              icon: Icons.calendar_today_rounded,
              label: 'Date & Time',
              value:
                  '${DateFormatter.formatDate(meeting.startTime)} • ${DateFormatter.formatTime(meeting.startTime)} - ${DateFormatter.formatTime(meeting.endTime)}',
            ),
            _buildDetailRow(
              context,
              icon: Icons.public_rounded,
              label: 'Timezone',
              value: meeting.timezone,
            ),
            _buildDetailRow(
              context,
              icon: Icons.timer_rounded,
              label: 'Duration & Repeat',
              value:
                  '${meeting.durationMinutes} mins (${meeting.repeatOption.name})',
            ),
            _buildDetailRow(
              context,
              icon: Icons.notifications_active_outlined,
              label: 'Reminder',
              value: '${meeting.reminderMinutes} minutes before',
            ),
          ],
        ),
        AppSpacing.gapLg,

        // Join Code & Direct Link Card
        Container(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meeting Passcode / Code',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                      Text(
                        meeting.joinCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: meeting.meetingLink),
                      );
                      AppSnackBar.show(
                        context,
                        message: 'Meeting link copied to clipboard!',
                        type: AppSnackBarType.success,
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Link'),
                  ),
                ],
              ),
              if (meeting.password != null) ...[
                const Divider(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    AppSpacing.gapWSm,
                    Text(
                      'Password Protection Required: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    SelectableText(
                      meeting.password!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        AppSpacing.gapLg,

        // Permissions Breakdown
        Text(
          'Room Permissions & Security',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        AppSpacing.gapSm,
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildPermissionChip(
              context,
              label: 'Chat Allowed',
              enabled: meeting.isChatAllowed,
              icon: Icons.chat_bubble_outline_rounded,
            ),
            _buildPermissionChip(
              context,
              label: 'Screen Sharing',
              enabled: meeting.isScreenShareAllowed,
              icon: Icons.screen_share_outlined,
            ),
            _buildPermissionChip(
              context,
              label: 'Mute on Entry',
              enabled: meeting.isMuteOnEntry,
              icon: Icons.mic_off_outlined,
            ),
            _buildPermissionChip(
              context,
              label: 'Video Camera',
              enabled: meeting.isCameraAllowed,
              icon: Icons.videocam_outlined,
            ),
          ],
        ),
        AppSpacing.gapLg,

        // Action Buttons Row with responsive narrow screen handling
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (meeting.status == MeetingStatus.scheduled) ...[
                    AppButton(
                      text: 'Start Meeting',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        try {
                          await ref
                              .read(meetingsNotifierProvider.notifier)
                              .startMeeting(meeting.id);
                        } catch (_) {}
                        if (context.mounted) {
                          context.push('/meetings/live/${meeting.id}');
                        }
                      },
                    ),
                    AppSpacing.gapSm,
                    AppButton(
                      text: 'Pre-Join',
                      variant: AppButtonVariant.outline,
                      icon: Icons.video_call_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/meetings/pre-join/${meeting.id}');
                      },
                    ),
                  ] else if (meeting.status != MeetingStatus.cancelled) ...[
                    AppButton(
                      text: meeting.isLive ? 'Join Live Room' : 'Pre-Join Room',
                      icon: Icons.video_call_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/meetings/pre-join/${meeting.id}');
                      },
                    ),
                  ],
                  AppSpacing.gapSm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ShareMeetingSheet.show(context, meeting);
                        },
                        icon: const Icon(Icons.share_rounded),
                        tooltip: 'Share Invite',
                      ),
                      if (meeting.status == MeetingStatus.scheduled) ...[
                        AppSpacing.gapWSm,
                        IconButton(
                          onPressed: () => _confirmCancel(context, ref),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.danger,
                          ),
                          tooltip: 'Cancel Meeting',
                        ),
                      ],
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                if (meeting.status == MeetingStatus.scheduled) ...[
                  Expanded(
                    child: AppButton(
                      text: 'Start Meeting',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        try {
                          await ref
                              .read(meetingsNotifierProvider.notifier)
                              .startMeeting(meeting.id);
                        } catch (_) {}
                        if (context.mounted) {
                          context.push('/meetings/live/${meeting.id}');
                        }
                      },
                    ),
                  ),
                  AppSpacing.gapWSm,
                  Expanded(
                    child: AppButton(
                      text: 'Pre-Join',
                      variant: AppButtonVariant.outline,
                      icon: Icons.video_call_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/meetings/pre-join/${meeting.id}');
                      },
                    ),
                  ),
                  AppSpacing.gapWSm,
                ] else if (meeting.status != MeetingStatus.cancelled) ...[
                  Expanded(
                    child: AppButton(
                      text: meeting.isLive ? 'Join Live Room' : 'Pre-Join Room',
                      icon: Icons.video_call_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push('/meetings/pre-join/${meeting.id}');
                      },
                    ),
                  ),
                  AppSpacing.gapWSm,
                ],
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ShareMeetingSheet.show(context, meeting);
                  },
                  icon: const Icon(Icons.share_rounded),
                  tooltip: 'Share Invite',
                ),
                if (meeting.status == MeetingStatus.scheduled) ...[
                  AppSpacing.gapWSm,
                  IconButton(
                    onPressed: () => _confirmCancel(context, ref),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                    tooltip: 'Cancel Meeting',
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AppDialog(
        title: 'Cancel Meeting',
        message:
            'Are you sure you want to cancel "${meeting.title}"? All participants will be notified.',
        actions: [
          AppButton(
            text: 'Keep Meeting',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          AppSpacing.gapWSm,
          AppButton(
            text: 'Cancel Meeting',
            variant: AppButtonVariant.danger,
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop();
              await ref
                  .read(meetingsNotifierProvider.notifier)
                  .cancelMeeting(meeting.id);
              if (context.mounted) {
                AppSnackBar.show(
                  context,
                  message: 'Meeting cancelled successfully',
                  type: AppSnackBarType.info,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          AppSpacing.gapWMd,
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(
    BuildContext context, {
    required String label,
    required bool enabled,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: enabled
            ? (isDark
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.successContainer)
            : (isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled
              ? AppColors.success.withValues(alpha: 0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: enabled
                ? AppColors.success
                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary)
                  : (isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}
