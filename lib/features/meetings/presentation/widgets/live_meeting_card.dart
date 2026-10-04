import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/avatars/app_avatar.dart';
import '../../../../shared/widgets/avatars/avatar_group.dart';
import '../../../../shared/widgets/badges/live_pulse_indicator.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../domain/models/meeting_model.dart';

class LiveMeetingCard extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback? onMorePressed;

  const LiveMeetingCard({super.key, required this.meeting, this.onMorePressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.danger.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0.12),
                ]
              : [
                  AppColors.dangerContainer,
                  AppColors.primary.withValues(alpha: 0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Live Indicator + Join Code + Options
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LivePulseIndicator(size: 8),
                    AppSpacing.gapWXs,
                    Text(
                      'LIVE NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapWSm,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  meeting.joinCode,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              const Spacer(),
              if (onMorePressed != null)
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onPressed: onMorePressed,
                  tooltip: 'More actions',
                ),
            ],
          ),
          AppSpacing.gapMd,

          // Meeting Title & Description
          Text(
            meeting.title,
            style: TextStyle(
              fontSize: 18,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
          ],
          AppSpacing.gapLg,

          // Bottom Row: Host Info + Participants + Join CTA Button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              // Host Info & Avatar
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppAvatar(
                    name: meeting.hostName,
                    imageUrl: meeting.hostAvatarUrl,
                    size: 36,
                  ),
                  AppSpacing.gapWSm,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Host: ${meeting.hostName}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Started ${DateFormatter.formatTime(meeting.startTime)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Participants Avatars + Count & Join CTA
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AvatarGroup(
                        items: meeting.participantIds.map((id) {
                          return AvatarGroupItem(
                            name: id.replaceAll('usr_', '').toUpperCase(),
                          );
                        }).toList(),
                        maxVisible: 3,
                        avatarSize: 28,
                      ),
                      AppSpacing.gapWSm,
                      Text(
                        '${meeting.participantIds.length} in room',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  AppButton(
                    text: 'Join Now',
                    icon: Icons.play_arrow_rounded,
                    size: AppButtonSize.md,
                    onPressed: () {
                      context.push('/meetings/pre-join/${meeting.id}');
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
