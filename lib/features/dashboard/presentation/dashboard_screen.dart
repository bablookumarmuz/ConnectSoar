import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../analytics/providers/analytics_providers.dart';
import '../../history/providers/history_providers.dart';
import '../../meetings/providers/meeting_providers.dart';
import '../../users/providers/user_providers.dart';
import '../../../shared/widgets/avatars/app_avatar.dart';
import '../../../shared/widgets/avatars/avatar_group.dart';
import '../../../shared/widgets/badges/live_pulse_indicator.dart';
import '../../../shared/widgets/badges/role_badge.dart';
import '../../../shared/widgets/badges/status_badge.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/cards/stat_card.dart';
import '../../../shared/widgets/charts/mini_chart_widget.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/loading/skeleton_loader.dart';
import '../../../shared/widgets/states/empty_state_widget.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import '../../auth/domain/models/user_model.dart';
import '../../meetings/domain/models/meeting_model.dart';
import '../../meetings/presentation/create_meeting_dialog.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _joinCodeController = TextEditingController();

  void _handleQuickJoin() {
    final code = _joinCodeController.text.trim();
    if (code.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please enter a valid join code',
        type: AppSnackBarType.warning,
      );
      return;
    }
    context.go(AppRoutes.liveMeeting);
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(currentUserProvider);
    ref.invalidate(meetingsListProvider);
    ref.invalidate(analyticsSummaryProvider);
    ref.invalidate(allUsersProvider);
    await Future.delayed(const Duration(milliseconds: 400));
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final meetingsAsync = ref.watch(meetingsListProvider);
    final analyticsAsync = ref.watch(analyticsSummaryProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.paddingMd,
          child: currentUserAsync.when(
            data: (user) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, user),
                  AppSpacing.gapLg,
                  switch (user.role) {
                    UserRole.admin => _buildAdminDashboard(
                      context,
                      meetingsAsync,
                      analyticsAsync,
                      usersAsync,
                    ),
                    UserRole.manager => _buildManagerDashboard(
                      context,
                      meetingsAsync,
                      analyticsAsync,
                      usersAsync,
                    ),
                    UserRole.employee => _buildEmployeeDashboard(
                      context,
                      meetingsAsync,
                      analyticsAsync,
                    ),
                  },
                ],
              );
            },
            loading: () => const Column(
              children: [
                SkeletonLoader(width: double.infinity, height: 110),
                AppSpacing.gapLg,
                SkeletonLoader(width: double.infinity, height: 260),
                AppSpacing.gapLg,
                SkeletonLoader(width: double.infinity, height: 260),
              ],
            ),
            error: (err, stack) => ErrorStateWidget(
              errorMessage: err.toString(),
              onRetry: () => ref.invalidate(currentUserProvider),
            ),
          ),
        ),
      ),
    );
  }

  // --- COMMON HEADER ---
  Widget _buildHeader(BuildContext context, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);

    return AppCard(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.darkSurfaceElevated,
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.06),
                    AppColors.lightSurface,
                  ],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                AppAvatar(
                  name: user.name,
                  imageUrl: user.avatarUrl,
                  size: 48,
                  status: user.status,
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${_getGreeting()}, ${user.name.trim().isNotEmpty ? user.name.trim().split(RegExp(r'\s+')).first : 'User'}',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          RoleBadge(role: user.role),
                        ],
                      ),
                      AppSpacing.gapXXs,
                      Text(
                        '${user.title} • ${user.department}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isMobile) AppSpacing.gapMd else const Spacer(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppButton(
                  text: 'New Meeting',
                  icon: Icons.video_call_rounded,
                  size: AppButtonSize.sm,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateMeetingDialog(),
                    );
                  },
                ),
                AppButton(
                  text: 'Schedule',
                  icon: Icons.calendar_today_rounded,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.sm,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateMeetingDialog(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // --- EMPLOYEE DASHBOARD ---
  // ==========================================
  Widget _buildEmployeeDashboard(
    BuildContext context,
    AsyncValue<List<MeetingModel>> meetingsAsync,
    AsyncValue<dynamic> analyticsAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Stats Overview Row
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 340) {
              return Column(
                children: [
                  StatCard(
                    title: 'Meeting Hours',
                    value: '14.5 hrs',
                    trendText: 'This week',
                    icon: Icons.access_time_filled_rounded,
                    iconColor: AppColors.primary,
                  ),
                  AppSpacing.gapSm,
                  StatCard(
                    title: 'Completed',
                    value: '12',
                    trendText: '100% attended',
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.success,
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Meeting Hours',
                    value: '14.5 hrs',
                    trendText: 'This week',
                    icon: Icons.access_time_filled_rounded,
                    iconColor: AppColors.primary,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: StatCard(
                    title: 'Completed',
                    value: '12',
                    trendText: '100% attended',
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.success,
                  ),
                ),
                if (!isMobile) ...[
                  AppSpacing.gapMd,
                  Expanded(
                    child: StatCard(
                      title: 'Participation',
                      value: '96%',
                      trendText: 'High engagement',
                      icon: Icons.stars_rounded,
                      iconColor: AppColors.warning,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        AppSpacing.gapLg,

        // Quick Join Card
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flash_on_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  AppSpacing.gapWSm,
                  Expanded(
                    child: Text(
                      'Instant Meeting Join',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapXs,
              Text(
                'Enter a 9-digit join code or paste a meeting room URL to hop in directly.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
              AppSpacing.gapMd,
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(
                    flex: isMobile ? 0 : 1,
                    child: SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: AppTextField(
                        hint: 'e.g. SOAR-982-314',
                        controller: _joinCodeController,
                        prefixIcon: Icons.key_rounded,
                      ),
                    ),
                  ),
                  if (isMobile) AppSpacing.gapSm else AppSpacing.gapWSm,
                  SizedBox(
                    width: isMobile ? double.infinity : null,
                    child: AppButton(
                      text: 'Join Live Room',
                      icon: Icons.login_rounded,
                      onPressed: _handleQuickJoin,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // Schedule & Upcoming Meetings
        _buildMeetingsSection(
          context,
          meetingsAsync,
          title: "Today's Schedule & Upcoming Meetings",
        ),
        AppSpacing.gapLg,

        // Recent Meetings Timeline
        _buildRecentMeetingsTimeline(context),
      ],
    );
  }

  // ==========================================
  // --- MANAGER DASHBOARD ---
  // ==========================================
  Widget _buildManagerDashboard(
    BuildContext context,
    AsyncValue<List<MeetingModel>> meetingsAsync,
    AsyncValue<dynamic> analyticsAsync,
    AsyncValue<List<UserModel>> usersAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Manager Stats & Team Overview Summary
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 340) {
              return Column(
                children: [
                  StatCard(
                    title: 'Team Online',
                    value: '4 / 5 Active',
                    trendText: '1 Away, 0 Offline',
                    icon: Icons.groups_rounded,
                    iconColor: AppColors.roleManager,
                  ),
                  AppSpacing.gapSm,
                  StatCard(
                    title: 'Team Syncs',
                    value: '3 Scheduled',
                    trendText: 'Next at 2:00 PM',
                    icon: Icons.event_available_rounded,
                    iconColor: AppColors.warning,
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Team Online',
                    value: '4 / 5 Active',
                    trendText: '1 Away, 0 Offline',
                    icon: Icons.groups_rounded,
                    iconColor: AppColors.roleManager,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: StatCard(
                    title: 'Team Syncs',
                    value: '3 Scheduled',
                    trendText: 'Next at 2:00 PM',
                    icon: Icons.event_available_rounded,
                    iconColor: AppColors.warning,
                  ),
                ),
              ],
            );
          },
        ),
        AppSpacing.gapLg,

        // Analytics & Meeting Activity Preview Card
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Meeting Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Weekly sync breakdown across engineering & design teams',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  StatusBadge(
                    label: 'Avg 98.4% Attendance',
                    type: BadgeType.success,
                  ),
                ],
              ),
              AppSpacing.gapLg,
              const WeeklyActivityBarChart(
                data: [12, 19, 15, 22, 28, 14, 20],
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                height: 140,
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // Team Meetings Section
        _buildMeetingsSection(
          context,
          meetingsAsync,
          title: 'Upcoming Team Meetings',
        ),
        AppSpacing.gapLg,

        // Team Members List & Status
        _buildUserManagementSection(
          context,
          usersAsync,
          title: 'Direct Team Members',
        ),
      ],
    );
  }

  // ==========================================
  // --- ADMIN DASHBOARD ---
  // ==========================================
  Widget _buildAdminDashboard(
    BuildContext context,
    AsyncValue<List<MeetingModel>> meetingsAsync,
    AsyncValue<dynamic> analyticsAsync,
    AsyncValue<List<UserModel>> usersAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top System Metrics Grid (Responsive calculation - guarantees no bottom overflow)
        analyticsAsync.when(
          data: (analytics) => LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 360 ? 1 : (width < 680 ? 2 : 4);
              final spacing = 12.0;
              final itemWidth =
                  (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;
              // Dynamically ensure card height is given at least 110px-115px
              final childAspectRatio = (itemWidth / 112.0).clamp(0.9, 2.5);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                shrinkWrap: true,
                childAspectRatio: childAspectRatio,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'Total Users',
                    value: '84 Users',
                    trendText: '+12% this month',
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.primary,
                  ),
                  StatCard(
                    title: 'Active Users',
                    value: '${analytics.activeUsers} Online',
                    trendText: '99.9% uptime',
                    icon: Icons.bolt_rounded,
                    iconColor: AppColors.success,
                  ),
                  StatCard(
                    title: 'Total Meetings',
                    value: '${analytics.totalMeetings}',
                    trendText: '+${analytics.monthlyGrowthPercent}% growth',
                    icon: Icons.video_camera_front_rounded,
                    iconColor: AppColors.info,
                  ),
                  StatCard(
                    title: 'Live Meetings',
                    value: '${analytics.peakConcurrentMeetings} Live',
                    trendText: 'Live capacity 100%',
                    icon: Icons.sensors_rounded,
                    iconColor: AppColors.danger,
                  ),
                ],
              );
            },
          ),
          loading: () =>
              const SkeletonLoader(width: double.infinity, height: 120),
          error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
        ),
        AppSpacing.gapLg,

        // Live Meeting Monitor ("Live Now" Section)
        _buildLiveMeetingMonitor(context, meetingsAsync),
        AppSpacing.gapLg,

        // Quick Access Shortcuts Bar
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Management Shortcuts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              AppSpacing.gapMd,
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildShortcutChip(
                    context,
                    icon: Icons.manage_accounts_rounded,
                    label: 'User Directory',
                    route: AppRoutes.settings,
                  ),
                  _buildShortcutChip(
                    context,
                    icon: Icons.video_library_rounded,
                    label: 'All Meetings',
                    route: AppRoutes.meetings,
                  ),
                  _buildShortcutChip(
                    context,
                    icon: Icons.security_rounded,
                    label: 'Audit Logs',
                    route: AppRoutes.notifications,
                  ),
                  _buildShortcutChip(
                    context,
                    icon: Icons.bar_chart_rounded,
                    label: 'Full Analytics',
                    route: AppRoutes.showcase,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,

        // System Activity & User Roster
        ResponsiveLayout(
          mobile: Column(
            children: [
              _buildUserManagementSection(
                context,
                usersAsync,
                title: 'Platform Users & Roles',
              ),
              AppSpacing.gapLg,
              _buildAuditActivityTimeline(context),
            ],
          ),
          tablet: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildUserManagementSection(
                  context,
                  usersAsync,
                  title: 'Platform Users & Roles',
                ),
              ),
              AppSpacing.gapLg,
              Expanded(child: _buildAuditActivityTimeline(context)),
            ],
          ),
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildUserManagementSection(
                  context,
                  usersAsync,
                  title: 'Platform Users & Roles',
                ),
              ),
              AppSpacing.gapLg,
              Expanded(flex: 2, child: _buildAuditActivityTimeline(context)),
            ],
          ),
        ),
      ],
    );
  }

  // --- REUSABLE LIVE MEETINGS / SCHEDULE SECTION ---
  Widget _buildMeetingsSection(
    BuildContext context,
    AsyncValue<List<MeetingModel>> meetingsAsync, {
    required String title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              AppSpacing.gapWSm,
              const LivePulseIndicator(),
            ],
          ),
          AppSpacing.gapMd,
          meetingsAsync.when(
            data: (meetings) {
              if (meetings.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No meetings scheduled',
                  description: 'You have a clear schedule today.',
                  icon: Icons.event_available_rounded,
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meetings.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  final isLive = meeting.status == MeetingStatus.live;

                  return Container(
                    decoration: BoxDecoration(
                      color: isLive
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : (isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.lightSurfaceElevated),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isLive
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                        width: isLive ? 1.5 : 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Flex(
                      direction: ResponsiveLayout.isMobile(context)
                          ? Axis.vertical
                          : Axis.horizontal,
                      crossAxisAlignment: ResponsiveLayout.isMobile(context)
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isLive
                                    ? AppColors.dangerContainerDark
                                    : AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isLive
                                    ? Icons.sensors_rounded
                                    : Icons.event_rounded,
                                color: isLive
                                    ? AppColors.danger
                                    : AppColors.primary,
                                size: 20,
                              ),
                            ),
                            AppSpacing.gapMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meeting.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AppSpacing.gapXXs,
                                  Text(
                                    'Host: ${meeting.hostName} • Code: ${meeting.joinCode}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (ResponsiveLayout.isMobile(context))
                          AppSpacing.gapSm,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatusBadge(
                              label: meeting.status.name,
                              type: isLive
                                  ? BadgeType.live
                                  : BadgeType.scheduled,
                            ),
                            AppSpacing.gapWSm,
                            AppButton(
                              text: isLive ? 'Join Live' : 'Pre-Join',
                              size: AppButtonSize.sm,
                              variant: isLive
                                  ? AppButtonVariant.primary
                                  : AppButtonVariant.secondary,
                              onPressed: () {
                                context.push(
                                  '/meetings/pre-join/${meeting.id}',
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () =>
                const SkeletonLoader(width: double.infinity, height: 160),
            error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE USER MANAGEMENT / TEAM SECTION ---
  Widget _buildUserManagementSection(
    BuildContext context,
    AsyncValue<List<UserModel>> usersAsync, {
    required String title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              AppSpacing.gapWSm,
              const Icon(
                Icons.manage_accounts_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
          AppSpacing.gapMd,
          usersAsync.when(
            data: (users) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        AppAvatar(
                          name: user.name,
                          imageUrl: user.avatarUrl,
                          size: 36,
                          status: user.status,
                        ),
                        AppSpacing.gapWSm,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${user.title} • ${user.department}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RoleBadge(role: user.role),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () =>
                const SkeletonLoader(width: double.infinity, height: 160),
            error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
          ),
        ],
      ),
    );
  }

  // --- LIVE MEETING MONITOR ("LIVE NOW" WIDGET FOR ADMIN) ---
  Widget _buildLiveMeetingMonitor(
    BuildContext context,
    AsyncValue<List<MeetingModel>> meetingsAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monitor_heart_rounded,
                    color: AppColors.danger,
                    size: 20,
                  ),
                  AppSpacing.gapWSm,
                  Text(
                    'Live Meeting Monitor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_rounded,
                      size: 14,
                      color: AppColors.success,
                    ),
                    AppSpacing.gapXXs,
                    Text(
                      '1080p60 • 42 ms',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          meetingsAsync.when(
            data: (meetings) {
              final liveMeetings = meetings
                  .where((m) => m.status == MeetingStatus.live)
                  .toList();
              if (liveMeetings.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No meetings currently live.',
                    style: TextStyle(fontSize: 13),
                  ),
                );
              }

              final live = liveMeetings.first;
              final participants = ref.watch(allUsersProvider).value ?? [];

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceElevated
                      : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                live.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              AppSpacing.gapXXs,
                              Text(
                                'Host: ${live.hostName} • Code: ${live.joinCode}',
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
                          ),
                        ),
                        AppSpacing.gapWSm,
                        StatusBadge(label: 'LIVE NOW', type: BadgeType.live),
                      ],
                    ),
                    AppSpacing.gapMd,
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        AvatarGroup(
                          items: participants
                              .map(
                                (p) => AvatarGroupItem(
                                  name: p.name,
                                  imageUrl: p.avatarUrl,
                                ),
                              )
                              .toList(),
                          maxVisible: 3,
                          avatarSize: 30,
                        ),
                        AppButton(
                          text: 'Monitor Stream',
                          icon: Icons.visibility_rounded,
                          size: AppButtonSize.sm,
                          onPressed: () {
                            context.push('/meetings/live/${live.id}');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () =>
                const SkeletonLoader(width: double.infinity, height: 100),
            error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
          ),
        ],
      ),
    );
  }

  // --- RECENT MEETINGS TIMELINE FOR EMPLOYEE ---
  Widget _buildRecentMeetingsTimeline(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history =
        ref.watch(meetingHistoryListProvider(const MeetingHistoryFilter())).value ??
            [];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_toggle_off_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              AppSpacing.gapWSm,
              Expanded(
                child: Text(
                  'Recent Activity & Completed Sessions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  '${item.type} • ${item.summary}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
                trailing: Text(
                  '${item.durationMinutes} min',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- AUDIT ACTIVITY TIMELINE FOR ADMIN ---
  Widget _buildAuditActivityTimeline(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auditItems = [
      {
        'title': 'Role Elevated to Admin',
        'desc': 'Alex Vance elevated Sophia Chen permissions',
        'time': '10m ago',
        'icon': Icons.security_rounded,
        'color': AppColors.warning,
      },
      {
        'title': 'New Meeting Room Created',
        'desc': 'Marcus Brody scheduled Sprint Demo',
        'time': '45m ago',
        'icon': Icons.add_circle_outline_rounded,
        'color': AppColors.primary,
      },
      {
        'title': 'System Security Audit',
        'desc': 'TLS 1.3 certificate auto-renewed cleanly',
        'time': '2h ago',
        'icon': Icons.verified_user_rounded,
        'color': AppColors.success,
      },
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_rounded,
                color: AppColors.warning,
                size: 20,
              ),
              AppSpacing.gapWSm,
              Expanded(
                child: Text(
                  'System Audit Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: auditItems.length,
            separatorBuilder: (_, _) => AppSpacing.gapSm,
            itemBuilder: (context, index) {
              final item = auditItems[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: (item['color'] as Color).withValues(
                      alpha: 0.15,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 14,
                      color: item['color'] as Color,
                    ),
                  ),
                  AppSpacing.gapWSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          item['desc'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item['time'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      onPressed: () => context.go(route),
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
    );
  }
}
