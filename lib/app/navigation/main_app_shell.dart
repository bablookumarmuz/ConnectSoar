import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/notifications/providers/notification_providers.dart';
import '../../features/users/providers/user_providers.dart';
import '../../shared/widgets/avatars/app_avatar.dart';
import '../../shared/widgets/badges/role_badge.dart';
import '../../shared/widgets/navigation/connectsoar_app_bar.dart';
import '../../shared/widgets/navigation/connectsoar_bottom_nav_bar.dart';
import '../../shared/widgets/navigation/connectsoar_nav_rail.dart';
import '../../shared/widgets/notifications/notification_preview_sheet.dart';
import '../../shared/widgets/search/app_search_modal.dart';
import '../router/app_router.dart';

class MainAppShell extends ConsumerWidget {
  final Widget child;

  const MainAppShell({super.key, required this.child});

  static const navItems = [
    ConnectSoarNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    ConnectSoarNavItem(
      icon: Icons.video_call_outlined,
      activeIcon: Icons.video_call_rounded,
      label: 'Meetings',
    ),
    ConnectSoarNavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Chat',
    ),
    ConnectSoarNavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'People',
    ),
    ConnectSoarNavItem(
      icon: Icons.history_toggle_off_rounded,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
    ConnectSoarNavItem(
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield_rounded,
      label: 'Audit Log',
    ),
    ConnectSoarNavItem(
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_rounded,
      label: 'Notifications',
    ),
    ConnectSoarNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
    ConnectSoarNavItem(
      icon: Icons.palette_outlined,
      activeIcon: Icons.palette_rounded,
      label: 'Showcase',
    ),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.meetings)) return 1;
    if (location.startsWith(AppRoutes.chat)) return 2;
    if (location.startsWith(AppRoutes.people)) return 3;
    if (location.startsWith(AppRoutes.history)) return 4;
    if (location.startsWith(AppRoutes.auditLog)) return 5;
    if (location.startsWith(AppRoutes.notifications)) return 6;
    if (location.startsWith(AppRoutes.settings)) return 7;
    if (location.startsWith(AppRoutes.showcase)) return 8;
    return 0; // Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.meetings);
        break;
      case 2:
        context.go(AppRoutes.chat);
        break;
      case 3:
        context.go(AppRoutes.people);
        break;
      case 4:
        context.go(AppRoutes.history);
        break;
      case 5:
        context.go(AppRoutes.auditLog);
        break;
      case 6:
        context.go(AppRoutes.notifications);
        break;
      case 7:
        context.go(AppRoutes.settings);
        break;
      case 8:
        context.go(AppRoutes.showcase);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);
    final selectedIndex = _calculateSelectedIndex(context);
    final currentUserAsync = ref.watch(currentUserProvider);
    final notificationsAsync = ref.watch(notificationsListProvider);

    final unreadCount = notificationsAsync.maybeWhen(
      data: (list) => list.where((n) => !n.isRead).length,
      orElse: () => 0,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (selectedIndex != 0) {
          context.go(AppRoutes.dashboard);
        } else {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Exit ConnectSoar?'),
              content: const Text(
                'Are you sure you want to exit the application?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Exit',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          );
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: ConnectSoarAppBar(
          title: 'ConnectSoar',
          subtitle: isMobile ? null : 'Enterprise Video & Workspace Platform',
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          actions: [
            // Search Access Button
            IconButton(
              icon: const Icon(Icons.search_rounded, size: 22),
              tooltip: 'Search Meetings, Users & Logs',
              onPressed: () => AppSearchModal.show(context),
            ),

            // Notifications Button with Unread Badge
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, size: 22),
                  tooltip: 'Notifications Preview',
                  onPressed: () => NotificationPreviewSheet.show(context),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),

            // Theme Mode Switcher
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? AppColors.warning : AppColors.primary,
                size: 20,
              ),
              tooltip: 'Toggle Theme Mode',
              onPressed: () {
                final current = ref.read(themeModeProvider);
                ref
                    .read(themeModeProvider.notifier)
                    .state = current == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
              },
            ),
            AppSpacing.gapWSm,

            // Profile / Avatar Menu
            currentUserAsync.when(
              data: (user) => PopupMenuButton<String>(
                tooltip: 'Account Menu',
                onSelected: (val) async {
                  if (val == 'settings') {
                    context.go(AppRoutes.settings);
                  } else if (val == 'logout') {
                    await ref.read(authRepositoryProvider).logout();
                    ref.invalidate(currentUserProvider);
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              AppSpacing.gapXXs,
                              RoleBadge(role: user.role),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 18),
                        AppSpacing.gapWSm,
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        AppSpacing.gapWSm,
                        Text(
                          'Sign Out',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                ],
                child: AppAvatar(
                  name: user.name,
                  imageUrl: user.avatarUrl,
                  size: 34,
                  status: user.status,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        body: ResponsiveLayout(
          mobile: child,
          tablet: Row(
            children: [
              ConnectSoarNavRail(
                currentIndex: selectedIndex,
                onTap: (idx) => _onItemTapped(idx, context),
                items: navItems,
              ),
              Expanded(child: child),
            ],
          ),
          desktop: Row(
            children: [
              ConnectSoarNavRail(
                currentIndex: selectedIndex,
                onTap: (idx) => _onItemTapped(idx, context),
                items: navItems,
              ),
              Expanded(child: child),
            ],
          ),
        ),
        bottomNavigationBar: isMobile
            ? ConnectSoarBottomNavBar(
                currentIndex: selectedIndex,
                onTap: (idx) => _onItemTapped(idx, context),
                items: navItems,
              )
            : null,
      ),
    );
  }
}
