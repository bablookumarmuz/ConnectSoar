import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/notification_providers.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/feedback/app_dialog.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/loading/skeleton_loader.dart';
import '../../../shared/widgets/states/empty_state_widget.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import '../domain/models/notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _activeTab = 'all'; // "all", "unread", "invites", "reminders"

  void _confirmClearAll(BuildContext context) {
    AppDialog.showConfirmation(
      context,
      title: 'Clear All Notifications?',
      message:
          'Are you sure you want to dismiss all notifications? This action cannot be undone.',
      confirmText: 'Clear All',
      isDanger: true,
      onConfirm: () async {
        await ref.read(notificationsNotifierProvider.notifier).clearAll();
        if (context.mounted) {
          AppSnackBar.show(
            context,
            message: 'All notifications cleared.',
            type: AppSnackBarType.info,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      body: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar Header
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
                      'Notification Center',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Meeting invites, reminders, and alerts',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: 'Mark All Read',
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      onPressed: () async {
                        await ref
                            .read(notificationsNotifierProvider.notifier)
                            .markAllAsRead();
                        if (context.mounted) {
                          AppSnackBar.show(
                            context,
                            message: 'All notifications marked as read.',
                            type: AppSnackBarType.success,
                          );
                        }
                      },
                    ),
                    AppSpacing.gapSm,
                    AppButton(
                      text: 'Clear All',
                      variant: AppButtonVariant.ghost,
                      size: AppButtonSize.sm,
                      onPressed: () => _confirmClearAll(context),
                    ),
                  ],
                ),
              ],
            ),
            AppSpacing.gapMd,

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip('All Notifications', 'all'),
                  AppSpacing.gapXXs,
                  _buildTabChip('Unread', 'unread'),
                  AppSpacing.gapXXs,
                  _buildTabChip('Meeting Invites', 'invites'),
                  AppSpacing.gapXXs,
                  _buildTabChip('Reminders', 'reminders'),
                ],
              ),
            ),
            AppSpacing.gapMd,

            // Notifications List Grouped
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) {
                  var filtered = notifications.where((n) {
                    if (_activeTab == 'unread' && n.isRead) {
                      return false;
                    }
                    if (_activeTab == 'invites' &&
                        n.type != NotificationType.invite) {
                      return false;
                    }
                    if (_activeTab == 'reminders' &&
                        n.type != NotificationType.meeting) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.notifications_none_rounded,
                      title: 'All Caught Up!',
                      description:
                          'You have no pending notifications or unread alerts.',
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => AppSpacing.gapSm,
                    itemBuilder: (context, index) {
                      final n = filtered[index];

                      // Formatted Meeting Reminder Card UI
                      if (n.type == NotificationType.meeting &&
                          n.meetingId != null) {
                        return _buildMeetingReminderCard(n, isDark);
                      }

                      // Standard Notification Item
                      return _buildStandardNotificationCard(n, isDark);
                    },
                  );
                },
                loading: () =>
                    const SkeletonLoader(width: double.infinity, height: 300),
                error: (err, _) =>
                    ErrorStateWidget(errorMessage: err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, String value) {
    final isSelected = _activeTab == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _activeTab = value),
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

  Widget _buildMeetingReminderCard(NotificationModel n, bool isDark) {
    return AppCard(
      onTap: () {
        ref.read(notificationsNotifierProvider.notifier).markAsRead(n.id);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.video_call_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      n.message,
                      style: TextStyle(
                        fontSize: 13,
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
          AppSpacing.gapMd,

          // Meeting Reminder Action Card Box
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Host: ${n.hostName ?? "Alex Vance"} • ${n.meetingTime ?? "In 15 minutes"}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Join Code: ${n.joinCode ?? "SOAR-982-314"}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapWSm,
                AppButton(
                  text: 'Join',
                  icon: Icons.video_camera_front_rounded,
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.sm,
                  onPressed: () {
                    ref
                        .read(notificationsNotifierProvider.notifier)
                        .markAsRead(n.id);
                    context.push(
                      '${AppRoutes.meetings}/pre-join/${n.meetingId}',
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: 'Dismiss',
                  onPressed: () {
                    ref
                        .read(notificationsNotifierProvider.notifier)
                        .removeNotification(n.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardNotificationCard(NotificationModel n, bool isDark) {
    IconData icon;
    Color iconColor;

    switch (n.type) {
      case NotificationType.invite:
        icon = Icons.mail_rounded;
        iconColor = AppColors.primary;
        break;
      case NotificationType.meeting:
        icon = Icons.video_camera_front_rounded;
        iconColor = AppColors.success;
        break;
      case NotificationType.system:
        icon = Icons.security_rounded;
        iconColor = AppColors.info;
        break;
      case NotificationType.alert:
        icon = Icons.warning_rounded;
        iconColor = AppColors.warning;
        break;
    }

    return AppCard(
      onTap: () {
        ref.read(notificationsNotifierProvider.notifier).markAsRead(n.id);
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                AppSpacing.gapXXs,
                Text(
                  n.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                AppSpacing.gapXs,
                Text(
                  DateFormatter.formatDateTime(n.timestamp),
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
          if (!n.isRead) ...[
            AppSpacing.gapSm,
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
