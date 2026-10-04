import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/history_providers.dart';
import '../../../shared/widgets/avatars/app_avatar.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/inputs/app_search_field.dart';
import '../../../shared/widgets/loading/skeleton_loader.dart';
import '../../../shared/widgets/states/empty_state_widget.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import 'widgets/meeting_timeline_widget.dart';

class MeetingHistoryScreen extends ConsumerStatefulWidget {
  const MeetingHistoryScreen({super.key});

  @override
  ConsumerState<MeetingHistoryScreen> createState() =>
      _MeetingHistoryScreenState();
}

class _MeetingHistoryScreenState extends ConsumerState<MeetingHistoryScreen> {
  String _searchQuery = '';
  String _dateFilter = 'all'; // "all", "today", "week", "month"

  void _showMeetingDetailsSheet(BuildContext context, String meetingId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MeetingDetailSheet(meetingId: meetingId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = MeetingHistoryFilter(
      query: _searchQuery,
      date: _dateFilter,
    );
    final historyAsync = ref.watch(meetingHistoryListProvider(filter));

    return Scaffold(
      body: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Text(
              'Meeting History & Logs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            Text(
              'Archived sessions, attendee logs, screen-share duration & timeline',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            AppSpacing.gapMd,

            // Search Bar
            AppSearchField(
              hintText:
                  'Search past meetings by title, join code, or summary...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            AppSpacing.gapSm,

            // Date Filters
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDateChip('All History', 'all'),
                _buildDateChip('Today', 'today'),
                _buildDateChip('Past 7 Days', 'week'),
                _buildDateChip('Past Month', 'month'),
              ],
            ),
            AppSpacing.gapMd,

            // History List
            Expanded(
              child: historyAsync.when(
                data: (historyList) {
                  if (historyList.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.history_toggle_off_rounded,
                      title: 'No Meeting History Found',
                      description:
                          'No ended meeting sessions match your date filter or search query.',
                    );
                  }

                  return ListView.separated(
                    itemCount: historyList.length,
                    separatorBuilder: (_, _) => AppSpacing.gapSm,
                    itemBuilder: (context, index) {
                      final item = historyList[index];

                      return AppCard(
                        onTap: () =>
                            _showMeetingDetailsSheet(context, item.meetingId),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.type.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormatter.formatDate(item.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gapSm,

                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            AppSpacing.gapXXs,
                            Text(
                              item.summary,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpacing.gapMd,

                            // Metrics Row (Duration & Attendees)
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildMetricPill(
                                      icon: Icons.timer_outlined,
                                      label: '${item.durationMinutes} min',
                                      isDark: isDark,
                                    ),
                                    AppSpacing.gapWSm,
                                    _buildMetricPill(
                                      icon: Icons.groups_outlined,
                                      label: '${item.participantCount} users',
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                                const Text(
                                  'View Timeline →',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.separated(
                  itemCount: 4,
                  separatorBuilder: (_, _) => AppSpacing.gapSm,
                  itemBuilder: (_, _) =>
                      const SkeletonLoader(width: double.infinity, height: 80),
                ),
                error: (err, _) => ErrorStateWidget(
                  errorMessage: err.toString(),
                  onRetry: () =>
                      ref.invalidate(meetingHistoryListProvider(filter)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, String value) {
    final isSelected = _dateFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _dateFilter = value),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
      ),
      backgroundColor: isDark
          ? AppColors.darkSurfaceElevated
          : AppColors.lightSurfaceElevated,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
          AppSpacing.gapXXs,
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeetingDetailSheet extends ConsumerWidget {
  final String meetingId;

  const _MeetingDetailSheet({required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(meetingHistoryDetailProvider(meetingId));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: AppSpacing.paddingMd,
          child: detailAsync.when(
            data: (detail) {
              if (detail == null) {
                return const Center(child: Text('Meeting detail not found'));
              }

              return ListView(
                controller: controller,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,

                  // Header Title & Host
                  Row(
                    children: [
                      AppAvatar(
                        name: detail.hostName,
                        imageUrl: detail.hostAvatarUrl,
                        size: 48,
                      ),
                      AppSpacing.gapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Hosted by ${detail.hostName} • Code: ${detail.joinCode}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapLg,

                  // Metric Stat Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailStatCard(
                          context,
                          icon: Icons.timer_outlined,
                          title: 'Meeting Duration',
                          value: '${detail.durationMinutes} mins',
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                      ),
                      AppSpacing.gapSm,
                      Expanded(
                        child: _buildDetailStatCard(
                          context,
                          icon: Icons.screen_share_rounded,
                          title: 'Screen Share',
                          value: '${detail.screenShareDurationMinutes} mins',
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ),
                      AppSpacing.gapSm,
                      Expanded(
                        child: _buildDetailStatCard(
                          context,
                          icon: Icons.forum_rounded,
                          title: 'Chat Activity',
                          value: '${detail.chatMessageCount} msgs',
                          color: AppColors.info,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapLg,

                  // Attendees Section
                  Text(
                    'ATTENDEES (${detail.participants.length})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                  AppSpacing.gapSm,
                  SizedBox(
                    height: 54,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: detail.participants.length,
                      separatorBuilder: (_, _) => AppSpacing.gapSm,
                      itemBuilder: (context, idx) {
                        final p = detail.participants[idx];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              AppAvatar(
                                name: p.name,
                                imageUrl: p.avatarUrl,
                                size: 28,
                              ),
                              AppSpacing.gapSm,
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  AppSpacing.gapLg,

                  // Event Timeline Section
                  Text(
                    'SESSION EVENT TIMELINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                  AppSpacing.gapMd,

                  MeetingTimelineWidget(events: detail.timelineEvents),
                ],
              );
            },
            loading: () => const Center(
              child: SkeletonLoader(width: double.infinity, height: 300),
            ),
            error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
          ),
        );
      },
    );
  }

  Widget _buildDetailStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          AppSpacing.gapXs,
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
