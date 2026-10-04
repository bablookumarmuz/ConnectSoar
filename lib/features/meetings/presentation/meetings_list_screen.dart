import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/meeting_providers.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_dialog.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_search_field.dart';
import '../../../shared/widgets/loading/skeleton_loader.dart';
import '../../../shared/widgets/states/empty_state_widget.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import '../domain/models/meeting_model.dart';
import '../../users/providers/user_providers.dart';
import 'widgets/create_meeting_sheet.dart';
import 'widgets/join_meeting_sheet.dart';
import 'widgets/live_meeting_card.dart';
import 'widgets/meeting_card.dart';
import 'widgets/meeting_details_sheet.dart';
import 'widgets/meeting_filter_sheet.dart';
import 'widgets/schedule_meeting_sheet.dart';
import 'widgets/share_meeting_sheet.dart';

class MeetingsListScreen extends ConsumerStatefulWidget {
  const MeetingsListScreen({super.key});

  @override
  ConsumerState<MeetingsListScreen> createState() => _MeetingsListScreenState();
}

class _MeetingsListScreenState extends ConsumerState<MeetingsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  MeetingFilterOptions _filterOptions = const MeetingFilterOptions();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() async {
    final result = await MeetingFilterSheet.show(context, _filterOptions);
    if (result != null) {
      setState(() => _filterOptions = result);
    }
  }

  void _showMoreActionsMenu(BuildContext context, MeetingModel meeting) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('View Full Details'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    MeetingDetailsSheet.show(context, meeting);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded),
                  title: const Text('Share Meeting Invite'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ShareMeetingSheet.show(context, meeting);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copy Meeting Link'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Clipboard.setData(ClipboardData(text: meeting.meetingLink));
                    AppSnackBar.show(
                      context,
                      message: 'Meeting link copied to clipboard!',
                      type: AppSnackBarType.success,
                    );
                  },
                ),
                if (meeting.status == MeetingStatus.scheduled) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                    title: const Text(
                      'Cancel Meeting',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _confirmCancelMeeting(context, meeting);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmCancelMeeting(BuildContext context, MeetingModel meeting) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AppDialog(
        title: 'Cancel Meeting',
        message:
            'Are you sure you want to cancel "${meeting.title}"? Participants will be notified.',
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingsAsync = ref.watch(meetingsNotifierProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          children: [
            // Top Toolbar: Search + Filters + Quick Actions
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppSearchField(
                            hint: 'Search meetings by title, host, or code...',
                            controller: _searchController,
                            onChanged: (val) => setState(
                              () => _searchQuery = val.toLowerCase(),
                            ),
                          ),
                        ),
                        AppSpacing.gapWSm,
                        Stack(
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.filter_list_rounded),
                              tooltip: 'Filter Options',
                              onPressed: _openFilterSheet,
                            ),
                            if (!_filterOptions.isEmpty)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (isWide) ...[
                          AppSpacing.gapWMd,
                          AppButton(
                            text: 'Join Room',
                            icon: Icons.login_rounded,
                            variant: AppButtonVariant.secondary,
                            onPressed: () => JoinMeetingSheet.show(context),
                          ),
                          AppSpacing.gapWSm,
                          AppButton(
                            text: 'Schedule',
                            icon: Icons.calendar_month_rounded,
                            variant: AppButtonVariant.outline,
                            onPressed: () => ScheduleMeetingSheet.show(context),
                          ),
                          AppSpacing.gapWSm,
                          AppButton(
                            text: 'Instant Meeting',
                            icon: Icons.video_call_rounded,
                            onPressed: () => CreateMeetingSheet.show(context),
                          ),
                        ],
                      ],
                    ),
                    if (!isWide) ...[
                      AppSpacing.gapSm,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            AppButton(
                              text: 'Instant Room',
                              icon: Icons.video_call_rounded,
                              size: AppButtonSize.sm,
                              onPressed: () => CreateMeetingSheet.show(context),
                            ),
                            AppSpacing.gapWSm,
                            AppButton(
                              text: 'Schedule',
                              icon: Icons.calendar_month_rounded,
                              size: AppButtonSize.sm,
                              variant: AppButtonVariant.outline,
                              onPressed: () =>
                                  ScheduleMeetingSheet.show(context),
                            ),
                            AppSpacing.gapWSm,
                            AppButton(
                              text: 'Join Code',
                              icon: Icons.login_rounded,
                              size: AppButtonSize.sm,
                              variant: AppButtonVariant.secondary,
                              onPressed: () => JoinMeetingSheet.show(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            AppSpacing.gapMd,

            // Tab Bar Filter Strip (Upcoming, Live Now, Completed, My Meetings)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildTabPill(0, 'Upcoming', isDark),
                  const SizedBox(width: 8),
                  _buildTabPill(1, 'Live Now', isDark),
                  const SizedBox(width: 8),
                  _buildTabPill(2, 'Completed', isDark),
                  const SizedBox(width: 8),
                  _buildTabPill(3, 'My Meetings', isDark),
                ],
              ),
            ),
            AppSpacing.gapMd,

            // Meetings Tab Content View
            Expanded(
              child: meetingsAsync.when(
                data: (meetings) {
                  final filtered = meetings.where((m) {
                    // Search query match
                    final matchesQuery =
                        _searchQuery.isEmpty ||
                        m.title.toLowerCase().contains(_searchQuery) ||
                        m.hostName.toLowerCase().contains(_searchQuery) ||
                        m.joinCode.toLowerCase().contains(_searchQuery);

                    if (!matchesQuery) return false;

                    // Filter Options Match
                    if (_filterOptions.type != null &&
                        m.type != _filterOptions.type) {
                      return false;
                    }
                    if (_filterOptions.requiresPassword != null) {
                      final hasPassword =
                          m.password != null && m.password!.isNotEmpty;
                      if (_filterOptions.requiresPassword! != hasPassword) {
                        return false;
                      }
                    }

                    // Tab Index Match
                    switch (_tabController.index) {
                      case 0: // Upcoming
                        return m.status == MeetingStatus.scheduled;
                      case 1: // Live
                        return m.status == MeetingStatus.live;
                      case 2: // Completed
                        return m.status == MeetingStatus.ended ||
                            m.status == MeetingStatus.cancelled;
                      case 3: // My Meetings (Host matches current user)
                        final currentUser = ref
                            .watch(currentUserProvider)
                            .value;
                        final myId = currentUser?.id;
                        final myName = currentUser?.name.toLowerCase();
                        final myEmail = currentUser?.email.toLowerCase();
                        return (myId != null && m.hostId == myId) ||
                            (myName != null &&
                                myName.isNotEmpty &&
                                m.hostName.toLowerCase().contains(myName)) ||
                            (myEmail != null &&
                                myEmail.isNotEmpty &&
                                m.hostName.toLowerCase().contains(myEmail)) ||
                            m.hostId == 'usr_admin_1' ||
                            m.hostName.contains('Alex Vance');
                      default:
                        return true;
                    }
                  }).toList();

                  if (filtered.isEmpty) {
                    String title = 'No Meetings Found';
                    String desc = 'Try adjusting your search query or filters.';
                    if (_tabController.index == 1) {
                      title = 'No Live Meetings Currently';
                      desc =
                          'There are no active video calls happening right now. Start an instant room!';
                    } else if (_tabController.index == 0) {
                      title = 'No Upcoming Meetings';
                      desc = 'You have no meetings scheduled for the future.';
                    } else if (_tabController.index == 3) {
                      title = 'No Meetings Created By You';
                      desc =
                          'Click "Instant Meeting" or "Schedule" to create your first room.';
                    }

                    return EmptyStateWidget(
                      icon: Icons.video_call_outlined,
                      title: title,
                      description: desc,
                      actionLabel: 'Create New Meeting',
                      onAction: () => CreateMeetingSheet.show(context),
                    );
                  }

                  if (isDesktop) {
                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(meetingsNotifierProvider.notifier)
                          .loadMeetings(),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 220,
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final meeting = filtered[index];
                          if (meeting.isLive) {
                            return LiveMeetingCard(
                              meeting: meeting,
                              onMorePressed: () =>
                                  _showMoreActionsMenu(context, meeting),
                            );
                          }
                          return MeetingCard(
                            meeting: meeting,
                            onTap: () =>
                                MeetingDetailsSheet.show(context, meeting),
                            onMorePressed: () =>
                                _showMoreActionsMenu(context, meeting),
                          );
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(meetingsNotifierProvider.notifier)
                        .loadMeetings(),
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => AppSpacing.gapMd,
                      itemBuilder: (context, index) {
                        final meeting = filtered[index];
                        if (meeting.isLive) {
                          return LiveMeetingCard(
                            meeting: meeting,
                            onMorePressed: () =>
                                _showMoreActionsMenu(context, meeting),
                          );
                        }
                        return MeetingCard(
                          meeting: meeting,
                          onTap: () =>
                              MeetingDetailsSheet.show(context, meeting),
                          onMorePressed: () =>
                              _showMoreActionsMenu(context, meeting),
                        );
                      },
                    ),
                  );
                },
                loading: () => ListView.separated(
                  itemCount: 4,
                  separatorBuilder: (_, _) => AppSpacing.gapMd,
                  itemBuilder: (_, _) =>
                      const SkeletonLoader(width: double.infinity, height: 120),
                ),
                error: (err, _) =>
                    ErrorStateWidget(errorMessage: err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(int index, String label, bool isDark) {
    final isSelected = _tabController.index == index;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _tabController.index = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceElevated),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
