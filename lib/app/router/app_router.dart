import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/audit_log/presentation/audit_log_screen.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/chat/presentation/chat_inbox_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/history/presentation/meeting_history_screen.dart';
import '../../features/live_meeting/presentation/live_meeting_screen.dart';
import '../../features/meetings/presentation/meetings_list_screen.dart';
import '../../features/meetings/presentation/pre_join_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/people/presentation/people_directory_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/showcase/design_showcase_screen.dart';
import '../navigation/main_app_shell.dart';

abstract class AppRoutes {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String dashboard = '/dashboard';
  static const String meetings = '/meetings';
  static const String chat = '/chat';
  static const String people = '/people';
  static const String history = '/history';
  static const String auditLog = '/audit-log';
  static const String preJoin = '/meetings/pre-join/:id';
  static const String liveMeeting = '/meetings/live/:id';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String showcase = '/showcase';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      name: 'resetPassword',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return ResetPasswordScreen(email: email);
      },
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      name: 'changePassword',
      builder: (context, state) {
        final token =
            state.uri.queryParameters['token'] ??
            (state.extra is Map
                ? (state.extra as Map)['token'] as String?
                : null);
        final email =
            state.uri.queryParameters['email'] ??
            (state.extra is Map
                ? (state.extra as Map)['email'] as String?
                : null);
        return ChangePasswordScreen(resetToken: token, email: email);
      },
    ),

    // Fullscreen Meeting Room Routes (without shell)
    GoRoute(
      path: AppRoutes.preJoin,
      name: 'preJoin',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'mtg_live_1';
        return PreJoinScreen(meetingId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.liveMeeting,
      name: 'liveMeeting',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'mtg_live_1';
        return LiveMeetingScreen(meetingId: id);
      },
    ),

    // App Shell Routes
    ShellRoute(
      builder: (context, state, child) => MainAppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.meetings,
          name: 'meetings',
          builder: (context, state) => const MeetingsListScreen(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          name: 'chat',
          builder: (context, state) => const ChatInboxScreen(),
        ),
        GoRoute(
          path: AppRoutes.people,
          name: 'people',
          builder: (context, state) => const PeopleDirectoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.history,
          name: 'history',
          builder: (context, state) => const MeetingHistoryScreen(),
        ),
        GoRoute(
          path: AppRoutes.auditLog,
          name: 'auditLog',
          builder: (context, state) => const AuditLogScreen(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.showcase,
          name: 'showcase',
          builder: (context, state) => const DesignShowcaseScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);
