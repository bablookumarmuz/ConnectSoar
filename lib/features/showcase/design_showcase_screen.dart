import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

import '../../features/auth/domain/models/user_model.dart';
import '../../features/meetings/domain/models/meeting_model.dart';

import '../analytics/providers/analytics_providers.dart';
import '../meetings/providers/meeting_providers.dart';
import '../users/providers/user_providers.dart';

import '../../shared/widgets/avatars/app_avatar.dart';
import '../../shared/widgets/avatars/avatar_group.dart';
import '../../shared/widgets/badges/live_pulse_indicator.dart';
import '../../shared/widgets/badges/role_badge.dart';
import '../../shared/widgets/badges/status_badge.dart';
import '../../shared/widgets/buttons/app_button.dart';
import '../../shared/widgets/buttons/app_icon_button.dart';
import '../../shared/widgets/cards/app_card.dart';
import '../../shared/widgets/cards/stat_card.dart';
import '../../shared/widgets/fab/connectsoar_fab.dart';
import '../../shared/widgets/feedback/app_bottom_sheet.dart';
import '../../shared/widgets/feedback/app_dialog.dart';
import '../../shared/widgets/feedback/app_snackbar.dart';
import '../../shared/widgets/inputs/app_dropdown.dart';
import '../../shared/widgets/inputs/app_search_field.dart';
import '../../shared/widgets/inputs/app_text_field.dart';
import '../../shared/widgets/loading/app_spinner.dart';
import '../../shared/widgets/loading/skeleton_loader.dart';
import '../../shared/widgets/states/empty_state_widget.dart';
import '../../shared/widgets/states/error_state_widget.dart';

class DesignShowcaseScreen extends ConsumerStatefulWidget {
  const DesignShowcaseScreen({super.key});

  @override
  ConsumerState<DesignShowcaseScreen> createState() =>
      _DesignShowcaseScreenState();
}

class _DesignShowcaseScreenState extends ConsumerState<DesignShowcaseScreen> {
  final TextEditingController _textController = TextEditingController(
    text: 'ConnectSoar Workspace',
  );
  final TextEditingController _searchController = TextEditingController();
  UserRole _selectedRole = UserRole.admin;

  @override
  void initState() {
    super.initState();
    // Default role perspective to current authenticated user if available
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      _selectedRole = currentUser.role;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final meetingsAsync = ref.watch(meetingsListProvider);
    final analyticsAsync = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileContent(
          context,
          currentUserAsync,
          meetingsAsync,
          analyticsAsync,
        ),
        tablet: _buildTabletDesktopContent(
          context,
          currentUserAsync,
          meetingsAsync,
          analyticsAsync,
        ),
        desktop: _buildTabletDesktopContent(
          context,
          currentUserAsync,
          meetingsAsync,
          analyticsAsync,
        ),
      ),
      floatingActionButton: ConnectSoarFAB(
        icon: Icons.add_call,
        label: 'New Meeting',
        onPressed: () {
          AppSnackBar.show(
            context,
            message: 'Quick Meeting Creator Launched (Mock)',
            type: AppSnackBarType.success,
          );
        },
      ),
    );
  }

  Widget _buildMobileContent(
    BuildContext context,
    AsyncValue<UserModel> currentUserAsync,
    AsyncValue<dynamic> meetingsAsync,
    AsyncValue<dynamic> analyticsAsync,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 120 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(context, currentUserAsync),
          AppSpacing.gapLg,
          _buildStatCardsSection(analyticsAsync),
          AppSpacing.gapLg,
          _buildDesignSystemSection(context),
          AppSpacing.gapLg,
          _buildMockDataSection(meetingsAsync),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildTabletDesktopContent(
    BuildContext context,
    AsyncValue<UserModel> currentUserAsync,
    AsyncValue<dynamic> meetingsAsync,
    AsyncValue<dynamic> analyticsAsync,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 120 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(context, currentUserAsync),
          AppSpacing.gapLg,
          _buildStatCardsSection(analyticsAsync),
          AppSpacing.gapLg,
          _buildDesignSystemSection(context),
          AppSpacing.gapLg,
          _buildMockDataSection(meetingsAsync),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    AsyncValue<UserModel> currentUserAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: AppSpacing.paddingLg,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const StatusBadge(
                      label: 'LIVE PLATFORM v1.0',
                      type: BadgeType.live,
                    ),
                    AppSpacing.gapWSm,
                    RoleBadge(role: _selectedRole),
                  ],
                ),
                AppSpacing.gapSm,
                Text(
                  'Welcome to ConnectSoar',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                AppSpacing.gapXs,
                Text(
                  'Production-grade Material 3 design tokens, Riverpod repositories, and responsive layout foundations.',
                  style: TextStyle(
                    fontSize: 14,
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
    );
  }

  Widget _buildStatCardsSection(AsyncValue<dynamic> analyticsAsync) {
    return analyticsAsync.when(
      data: (analytics) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 340) {
            return Column(
              children: [
                StatCard(
                  title: 'Total Meetings',
                  value: '${analytics.totalMeetings}',
                  trendText: '+${analytics.monthlyGrowthPercent}%',
                  icon: Icons.video_camera_front_rounded,
                  iconColor: AppColors.primary,
                ),
                AppSpacing.gapSm,
                StatCard(
                  title: 'Active Users',
                  value: '${analytics.activeUsers}',
                  trendText: '98.4% uptime',
                  icon: Icons.people_alt_rounded,
                  iconColor: AppColors.success,
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Meetings',
                  value: '${analytics.totalMeetings}',
                  trendText: '+${analytics.monthlyGrowthPercent}%',
                  icon: Icons.video_camera_front_rounded,
                  iconColor: AppColors.primary,
                ),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: StatCard(
                  title: 'Active Users',
                  value: '${analytics.activeUsers}',
                  trendText: '98.4% uptime',
                  icon: Icons.people_alt_rounded,
                  iconColor: AppColors.success,
                ),
              ),
            ],
          );
        },
      ),
      loading: () => const Row(
        children: [
          Expanded(child: SkeletonLoader(width: double.infinity, height: 100)),
          AppSpacing.gapMd,
          Expanded(child: SkeletonLoader(width: double.infinity, height: 100)),
        ],
      ),
      error: (err, stack) => ErrorStateWidget(errorMessage: err.toString()),
    );
  }

  Widget _buildDesignSystemSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. Reusable Design Components',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          AppSpacing.gapMd,

          // Buttons Row
          const Text(
            'Buttons & Icons:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          AppSpacing.gapSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppButton(
                text: 'Primary Action',
                icon: Icons.add,
                onPressed: () {
                  AppSnackBar.show(
                    context,
                    message: 'Primary Button Clicked',
                    type: AppSnackBarType.success,
                  );
                },
              ),
              AppButton(
                text: 'Secondary',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
              AppButton(
                text: 'Outline',
                variant: AppButtonVariant.outline,
                onPressed: () {},
              ),
              AppButton(
                text: 'Danger',
                variant: AppButtonVariant.danger,
                onPressed: () {},
              ),
              const AppIconButton(
                icon: Icons.mic_rounded,
                isSelected: true,
                activeColor: AppColors.danger,
              ),
              const AppIconButton(
                icon: Icons.videocam_rounded,
                variant: AppIconButtonVariant.secondary,
              ),
              const AppIconButton(
                icon: Icons.screen_share_rounded,
                variant: AppIconButtonVariant.outline,
              ),
            ],
          ),
          AppSpacing.gapLg,

          // Badges & Avatars
          const Text(
            'Badges & Avatars:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          AppSpacing.gapSm,
          Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const StatusBadge(label: 'Live', type: BadgeType.live),
              const StatusBadge(label: 'Scheduled', type: BadgeType.scheduled),
              const StatusBadge(label: 'Ended', type: BadgeType.ended),
              const RoleBadge(role: UserRole.admin),
              const RoleBadge(role: UserRole.manager),
              const RoleBadge(role: UserRole.employee),
              const AppAvatar(
                name: 'Alex Vance',
                size: 36,
                status: UserStatus.online,
              ),
              const AppAvatar(
                name: 'Sophia Chen',
                size: 36,
                status: UserStatus.busy,
              ),
              const AvatarGroup(
                items: [
                  AvatarGroupItem(name: 'Alex Vance'),
                  AvatarGroupItem(name: 'Sophia Chen'),
                  AvatarGroupItem(name: 'Marcus Brody'),
                  AvatarGroupItem(name: 'Elena Rostova'),
                ],
              ),
            ],
          ),
          AppSpacing.gapLg,

          // Inputs
          const Text(
            'Inputs & Controls:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          AppSpacing.gapSm,
          AppTextField(
            label: 'Meeting Subject',
            hint: 'Enter subject line...',
            controller: _textController,
            prefixIcon: Icons.title_rounded,
          ),
          AppSpacing.gapSm,
          AppSearchField(controller: _searchController),
          AppSpacing.gapSm,
          AppDropdown<UserRole>(
            label: 'Switch Active Role Perspective',
            value: _selectedRole,
            items: const [
              AppDropdownItem(
                value: UserRole.admin,
                label: 'Admin (Alex Vance)',
                icon: Icons.admin_panel_settings_rounded,
              ),
              AppDropdownItem(
                value: UserRole.manager,
                label: 'Manager (Sophia Chen)',
                icon: Icons.manage_accounts_rounded,
              ),
              AppDropdownItem(
                value: UserRole.employee,
                label: 'Employee (Marcus Brody)',
                icon: Icons.person_rounded,
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedRole = val);
              }
            },
          ),
          AppSpacing.gapLg,

          // Dialogs & Sheets Triggers (Wrap prevents RenderFlex overflow on narrow screens)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppButton(
                text: 'Show Modal Dialog',
                variant: AppButtonVariant.outline,
                onPressed: () {
                  AppDialog.show(
                    context: context,
                    title: 'Start Instant Meeting?',
                    message:
                        'This will notify all team members in the Engineering room.',
                    actions: [
                      AppButton(
                        text: 'Cancel',
                        variant: AppButtonVariant.ghost,
                        onPressed: () => Navigator.pop(context),
                      ),
                      AppButton(
                        text: 'Start Now',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              ),
              AppButton(
                text: 'Show Bottom Sheet',
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  AppBottomSheet.show(
                    context: context,
                    title: 'Meeting Settings & Audio',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Audio Input: System Default Microphone',
                        ),
                        AppSpacing.gapSm,
                        const Text('Video Camera: Built-in HD Camera'),
                        AppSpacing.gapMd,
                        AppButton(
                          text: 'Save Preferences',
                          isFullWidth: true,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockDataSection(AsyncValue<dynamic> meetingsAsync) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  '2. Mock Repository - Upcoming & Live Meetings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                  title: 'No Meetings Scheduled',
                  description:
                      'Create your first collaboration room to start meeting.',
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
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: isLive
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isLive ? AppColors.primary : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isLive
                              ? AppColors.liveIndicator.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLive ? Icons.sensors_rounded : Icons.event_rounded,
                          color: isLive
                              ? AppColors.liveIndicator
                              : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        meeting.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'Host: ${meeting.hostName} • Code: ${meeting.joinCode}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: StatusBadge(
                        label: meeting.status.displayName,
                        type: isLive ? BadgeType.live : BadgeType.scheduled,
                      ),
                    ),
                  );
                },
              );
            },
            loading: () =>
                const AppSpinner(message: 'Loading repository mock data...'),
            error: (err, stack) => ErrorStateWidget(
              errorMessage: 'Failed to fetch mock data: $err',
            ),
          ),
        ],
      ),
    );
  }
}
