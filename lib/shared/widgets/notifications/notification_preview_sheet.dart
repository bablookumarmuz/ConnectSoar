import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/notifications/domain/models/notification_model.dart';
import '../../../features/notifications/providers/notification_providers.dart';
import '../buttons/app_button.dart';

class NotificationPreviewSheet extends ConsumerWidget {
  const NotificationPreviewSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPreviewSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    AppSpacing.gapWSm,
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ref.read(notificationRepositoryProvider).markAllAsRead();
                    ref.invalidate(notificationsListProvider);
                  },
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),

          // Items list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No notifications right now.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.5)
                        : AppColors.lightBorder.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    IconData icon;
                    Color iconColor;
                    switch (notif.type) {
                      case NotificationType.invite:
                        icon = Icons.event_available_rounded;
                        iconColor = AppColors.primary;
                        break;
                      case NotificationType.meeting:
                        icon = Icons.video_call_rounded;
                        iconColor = AppColors.warning;
                        break;
                      case NotificationType.system:
                        icon = Icons.security_rounded;
                        iconColor = AppColors.info;
                        break;
                      case NotificationType.alert:
                        icon = Icons.warning_amber_rounded;
                        iconColor = AppColors.danger;
                        break;
                    }

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: iconColor.withValues(alpha: 0.1),
                        child: Icon(icon, color: iconColor, size: 16),
                      ),
                      title: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: notif.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        notif.message,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: notif.isRead
                              ? Colors.transparent
                              : AppColors.primary,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $err'),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'View All Notifications',
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.sm,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(AppRoutes.notifications);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
