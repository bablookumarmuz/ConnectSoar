import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/history/providers/history_providers.dart';
import '../../../features/meetings/domain/models/meeting_model.dart';
import '../../../features/meetings/providers/meeting_providers.dart';
import '../../../features/users/providers/user_providers.dart';
import '../avatars/app_avatar.dart';
import '../badges/status_badge.dart';

enum SearchFilter { all, meetings, users, logs }

class AppSearchModal extends ConsumerStatefulWidget {
  const AppSearchModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (context) {
        return const Dialog(
          alignment: Alignment.topCenter,
          insetPadding: EdgeInsets.only(
            top: 24,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AppSearchModal(),
        );
      },
    );
  }

  @override
  ConsumerState<AppSearchModal> createState() => _AppSearchModalState();
}

class _AppSearchModalState extends ConsumerState<AppSearchModal> {
  final TextEditingController _controller = TextEditingController();
  SearchFilter _selectedFilter = SearchFilter.all;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim().toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final safeTop = mediaQuery.padding.top;
    final safeBottom = mediaQuery.padding.bottom;

    // Calculate adaptive max height that responds dynamically to keyboard & screen size
    final maxAvailableHeight =
        (screenHeight - keyboardHeight - safeTop - safeBottom - 48).clamp(
          200.0,
          620.0,
        );

    final allMeetings = ref.watch(meetingsListProvider).value ?? [];
    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final allLogs =
        ref.watch(meetingHistoryListProvider(const MeetingHistoryFilter())).value ??
            [];

    final filteredMeetings = allMeetings.where((m) {
      return m.title.toLowerCase().contains(query) ||
          m.description.toLowerCase().contains(query) ||
          m.joinCode.toLowerCase().contains(query) ||
          m.hostName.toLowerCase().contains(query);
    }).toList();

    final filteredUsers = allUsers.where((u) {
      if (query.isEmpty) return true;
      return u.name.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          u.department.toLowerCase().contains(query) ||
          u.title.toLowerCase().contains(query);
    }).toList();

    final filteredLogs = allLogs.where((l) {
      if (query.isEmpty) return true;
      return l.title.toLowerCase().contains(query) ||
          l.type.toLowerCase().contains(query) ||
          l.summary.toLowerCase().contains(query);
    }).toList();

    final totalCount =
        (_selectedFilter == SearchFilter.all ||
                _selectedFilter == SearchFilter.meetings
            ? filteredMeetings.length
            : 0) +
        (_selectedFilter == SearchFilter.all ||
                _selectedFilter == SearchFilter.users
            ? filteredUsers.length
            : 0) +
        (_selectedFilter == SearchFilter.all ||
                _selectedFilter == SearchFilter.logs
            ? filteredLogs.length
            : 0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      constraints: BoxConstraints(maxWidth: 640, maxHeight: maxAvailableHeight),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Search Bar Input Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                AppSpacing.gapWSm,
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search meetings, team members, codes...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    tooltip: 'Clear search',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Close search',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),

          // 2. Horizontal Scrollable Filter Chips (NEVER overflows horizontally)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('All', SearchFilter.all),
                AppSpacing.gapWSm,
                _buildFilterChip(
                  'Meetings (${filteredMeetings.length})',
                  SearchFilter.meetings,
                ),
                AppSpacing.gapWSm,
                _buildFilterChip(
                  'Users (${filteredUsers.length})',
                  SearchFilter.users,
                ),
                AppSpacing.gapWSm,
                _buildFilterChip(
                  'Logs (${filteredLogs.length})',
                  SearchFilter.logs,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),

          // 3. Scrollable Results (Adaptive Flexible container — NEVER overflows vertically)
          Flexible(
            child: totalCount == 0
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          AppSpacing.gapSm,
                          Text(
                            _controller.text.isEmpty
                                ? 'No items available'
                                : 'No results matching "${_controller.text}"',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.gapXXs,
                          Text(
                            'Try searching for meeting titles, join codes (e.g. SOAR-982), or team member names.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    children: [
                      if (_selectedFilter == SearchFilter.all ||
                          _selectedFilter == SearchFilter.meetings) ...[
                        if (filteredMeetings.isNotEmpty) ...[
                          _buildSectionHeader('Meetings'),
                          ...filteredMeetings.map(
                            (meeting) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.video_call_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                meeting.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'Host: ${meeting.hostName} • Code: ${meeting.joinCode}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              trailing: StatusBadge(
                                label: meeting.status.name,
                                type: meeting.status == MeetingStatus.live
                                    ? BadgeType.live
                                    : BadgeType.scheduled,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.go('/meetings/pre-join/${meeting.id}');
                              },
                            ),
                          ),
                        ],
                      ],
                      if (_selectedFilter == SearchFilter.all ||
                          _selectedFilter == SearchFilter.users) ...[
                        if (filteredUsers.isNotEmpty) ...[
                          _buildSectionHeader('Team Members'),
                          ...filteredUsers.map(
                            (user) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              leading: AppAvatar(
                                name: user.name,
                                imageUrl: user.avatarUrl,
                                size: 32,
                                status: user.status,
                              ),
                              title: Text(
                                user.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              subtitle: Text(
                                '${user.title} • ${user.department}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              trailing: StatusBadge(
                                label: user.role.name.toUpperCase(),
                                type: BadgeType.info,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Selected user: ${user.name} (${user.email})',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                      if (_selectedFilter == SearchFilter.all ||
                          _selectedFilter == SearchFilter.logs) ...[
                        if (filteredLogs.isNotEmpty) ...[
                          _buildSectionHeader('Audit Logs & History'),
                          ...filteredLogs.map(
                            (log) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.history_rounded,
                                  color: AppColors.info,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                log.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              subtitle: Text(
                                '${log.type} • ${log.summary}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                '${log.durationMinutes} min',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                context.go(AppRoutes.meetings);
                              },
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SearchFilter filter) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onSelected: (_) => setState(() => _selectedFilter = filter),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
