import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/avatars/app_avatar.dart';
import '../../domain/models/meeting_history_detail_model.dart';

class MeetingTimelineWidget extends StatelessWidget {
  final List<MeetingTimelineEvent> events;

  const MeetingTimelineWidget({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        IconData icon;
        Color iconColor;

        switch (event.category) {
          case 'created':
            icon = Icons.add_circle_outline_rounded;
            iconColor = AppColors.info;
            break;
          case 'started':
            icon = Icons.play_circle_fill_rounded;
            iconColor = AppColors.success;
            break;
          case 'joined':
            icon = Icons.login_rounded;
            iconColor = AppColors.primary;
            break;
          case 'left':
            icon = Icons.logout_rounded;
            iconColor = AppColors.warning;
            break;
          case 'screenshare_started':
            icon = Icons.screen_share_rounded;
            iconColor = AppColors.primary;
            break;
          case 'screenshare_stopped':
            icon = Icons.stop_screen_share_rounded;
            iconColor = AppColors.darkTextMuted;
            break;
          case 'ended':
            icon = Icons.stop_circle_rounded;
            iconColor = AppColors.danger;
            break;
          default:
            icon = Icons.event_note_rounded;
            iconColor = AppColors.primary;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Column (Dot + Line)
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: iconColor, width: 1.5),
                    ),
                    child: Center(
                      child: Icon(icon, size: 14, color: iconColor),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                ],
              ),
              AppSpacing.gapMd,

              // Content Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            DateFormatter.formatTime(event.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapXXs,
                      if (event.participantName != null)
                        Row(
                          children: [
                            if (event.avatarUrl != null) ...[
                              AppAvatar(
                                name: event.participantName!,
                                imageUrl: event.avatarUrl,
                                size: 16,
                              ),
                              AppSpacing.gapXXs,
                            ],
                            Text(
                              event.participantName!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      if (event.detail != null) ...[
                        AppSpacing.gapXXs,
                        Text(
                          event.detail!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
