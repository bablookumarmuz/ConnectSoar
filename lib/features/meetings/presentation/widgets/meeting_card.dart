import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/avatars/app_avatar.dart';
import '../../../../shared/widgets/avatars/avatar_group.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../domain/models/meeting_model.dart';

class MeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;

  const MeetingCard({
    super.key,
    required this.meeting,
    this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isScheduled = meeting.status == MeetingStatus.scheduled;
    final isEnded = meeting.status == MeetingStatus.ended;
    final isCancelled = meeting.status == MeetingStatus.cancelled;

    BadgeType badgeType;
    if (meeting.isLive) {
      badgeType = BadgeType.live;
    } else if (isScheduled) {
      badgeType = BadgeType.scheduled;
    } else if (isEnded) {
      badgeType = BadgeType.info;
    } else {
      badgeType = BadgeType.ended;
    }

    return AppCard(
      onTap: onTap ?? () => context.push('/meetings/pre-join/${meeting.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status Badge + Join Code + Options Button
          Row(
            children: [
              StatusBadge(
                label: meeting.status.name.toUpperCase(),
                type: badgeType,
              ),
              AppSpacing.gapWSm,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceElevated
                      : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  meeting.type.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ),
              const Spacer(),
              if (onMorePressed != null)
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onPressed: onMorePressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Actions',
                ),
            ],
          ),
          AppSpacing.gapSm,

          // Title & Description
          Text(
            meeting.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          if (meeting.description.isNotEmpty) ...[
            AppSpacing.gapXs,
            Text(
              meeting.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          ],
          AppSpacing.gapMd,

          // Date, Time & Duration Metadata Pills
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildMetaPill(
                context,
                icon: Icons.calendar_today_rounded,
                text: DateFormatter.formatDate(meeting.startTime),
              ),
              _buildMetaPill(
                context,
                icon: Icons.access_time_rounded,
                text:
                    '${DateFormatter.formatTime(meeting.startTime)} - ${DateFormatter.formatTime(meeting.endTime)}',
              ),
              _buildMetaPill(
                context,
                icon: Icons.timer_outlined,
                text: '${meeting.durationMinutes} mins',
              ),
              if (meeting.password != null)
                _buildMetaPill(
                  context,
                  icon: Icons.lock_outline_rounded,
                  text: 'Protected',
                ),
            ],
          ),
          AppSpacing.gapMd,
          const Divider(height: 1),
          AppSpacing.gapSm,

          // Bottom Bar: Host + Participants + Action Button
          Row(
            children: [
              // Host Avatar & Name
              AppAvatar(
                name: meeting.hostName,
                imageUrl: meeting.hostAvatarUrl,
                size: 28,
              ),
              AppSpacing.gapWSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.hostName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Host • Code: ${meeting.joinCode}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapWSm,

              // Participant Avatars
              AvatarGroup(
                items: meeting.participantIds.map((id) {
                  return AvatarGroupItem(
                    name: id.replaceAll('usr_', '').toUpperCase(),
                  );
                }).toList(),
                maxVisible: 2,
                avatarSize: 26,
              ),
              AppSpacing.gapWSm,

              // Action Button
              if (isScheduled)
                AppButton(
                  text: 'Pre-Join',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    context.push('/meetings/pre-join/${meeting.id}');
                  },
                )
              else if (isEnded)
                AppButton(
                  text: 'View Details',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.outline,
                  onPressed: onTap,
                )
              else if (isCancelled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    'Cancelled',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
