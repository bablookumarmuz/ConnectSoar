import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/audit_log/domain/models/audit_log_model.dart';
import '../../features/auth/domain/models/user_model.dart';

import '../../features/audit_log/domain/repositories/audit_log_repository.dart';

class MockAuditLogRepository implements AuditLogRepository {
  static List<AuditLogModel> get _sampleLogs {
    final now = DateTime.now();
    return [
      AuditLogModel(
        id: 'audit_101',
        timestamp: now.subtract(const Duration(minutes: 5)),
        userId: 'usr_admin_1',
        userName: 'Alex Vance',
        userEmail: 'alex.vance@connectsoar.io',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        userRole: UserRole.admin,
        action: 'ROLE_CHANGE',
        category: AuditActionCategory.roleManagement,
        ipAddress: '192.168.1.104',
        device: 'Chrome 128 (Windows 11)',
        location: 'San Jose, CA, US',
        metadata: {
          'target_user': 'Marcus Brody',
          'previous_role': 'Employee',
          'new_role': 'Manager',
          'reason': 'Promotion & Team Lead Assignment',
        },
      ),
      AuditLogModel(
        id: 'audit_102',
        timestamp: now.subtract(const Duration(minutes: 18)),
        userId: 'usr_admin_1',
        userName: 'Alex Vance',
        userEmail: 'alex.vance@connectsoar.io',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        userRole: UserRole.admin,
        action: 'SCREEN_SHARE_START',
        category: AuditActionCategory.mediaSharing,
        meetingId: 'mtg_live_1',
        meetingTitle: 'ConnectSoar Architecture Sync & Q3 Roadmap',
        ipAddress: '192.168.1.104',
        device: 'ConnectSoar Desktop App v1.4',
        location: 'San Jose, CA, US',
        metadata: {
          'resolution': '3840x2160 @ 60fps',
          'codec': 'AV1 / WebRTC VP9',
          'audio_embedded': true,
        },
      ),
      AuditLogModel(
        id: 'audit_103',
        timestamp: now.subtract(const Duration(minutes: 32)),
        userId: 'usr_mgr_1',
        userName: 'Sophia Chen',
        userEmail: 'sophia.chen@connectsoar.io',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        userRole: UserRole.manager,
        action: 'MUTE_ALL',
        category: AuditActionCategory.meetingControl,
        meetingId: 'mtg_live_1',
        meetingTitle: 'ConnectSoar Architecture Sync & Q3 Roadmap',
        ipAddress: '172.16.0.45',
        device: 'Safari 17.4 (macOS Sonoma)',
        location: 'Seattle, WA, US',
        metadata: {
          'muted_participants_count': 4,
          'force_mute': true,
          'allow_unmute': true,
        },
      ),
      AuditLogModel(
        id: 'audit_104',
        timestamp: now.subtract(const Duration(hours: 2)),
        userId: 'usr_emp_1',
        userName: 'Marcus Brody',
        userEmail: 'marcus.brody@connectsoar.io',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        userRole: UserRole.employee,
        action: 'MEETING_CREATED',
        category: AuditActionCategory.meetingControl,
        meetingId: 'mtg_sched_1',
        meetingTitle: 'Design System & Accessibility Review',
        ipAddress: '10.0.0.12',
        device: 'ConnectSoar Flutter Web',
        location: 'Austin, TX, US',
        metadata: {
          'scheduled_time': '2026-08-25T17:00:00Z',
          'max_participants': 25,
          'e2e_encryption': true,
        },
      ),
      AuditLogModel(
        id: 'audit_105',
        timestamp: now.subtract(const Duration(hours: 4)),
        userId: 'usr_admin_1',
        userName: 'Alex Vance',
        userEmail: 'alex.vance@connectsoar.io',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        userRole: UserRole.admin,
        action: 'POLICY_UPDATE',
        category: AuditActionCategory.policyUpdate,
        ipAddress: '192.168.1.104',
        device: 'Chrome 128 (Windows 11)',
        location: 'San Jose, CA, US',
        metadata: {
          'policy': 'MAX_MEETING_DURATION_HOURS',
          'old_value': '8',
          'new_value': '12',
          'enforced_globally': true,
        },
      ),
      AuditLogModel(
        id: 'audit_106',
        timestamp: now.subtract(const Duration(hours: 6)),
        userId: 'usr_emp_3',
        userName: 'David Kim',
        userEmail: 'david.k@connectsoar.io',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        userRole: UserRole.employee,
        action: 'USER_LOGIN',
        category: AuditActionCategory.userAuth,
        ipAddress: '198.51.100.12',
        device: 'Edge 126 (Windows 11)',
        location: 'New York, NY, US',
        metadata: {
          'auth_provider': 'Google OAuth SSO 2.0',
          '2fa_verified': true,
        },
      ),
      AuditLogModel(
        id: 'audit_107',
        timestamp: now.subtract(const Duration(days: 1)),
        userId: 'usr_emp_2',
        userName: 'Elena Rostova',
        userEmail: 'elena.r@connectsoar.io',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        userRole: UserRole.employee,
        action: 'MEETING_ENDED',
        category: AuditActionCategory.meetingControl,
        meetingId: 'mtg_ended_1',
        meetingTitle: 'Sprint 24 Retrospective & Demo',
        ipAddress: '203.0.113.88',
        device: 'Firefox 129 (Linux x86_64)',
        location: 'Berlin, DE',
        metadata: {
          'duration_seconds': 2700,
          'peak_participants': 6,
          'recording_saved': true,
        },
      ),
    ];
  }

  @override
  Future<List<AuditLogModel>> getAuditLogs({
    String? searchQuery,
    String? actionFilter,
    String? userFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = List<AuditLogModel>.from(_sampleLogs);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      results = results
          .where(
            (l) =>
                l.action.toLowerCase().contains(q) ||
                l.userName.toLowerCase().contains(q) ||
                l.userEmail.toLowerCase().contains(q) ||
                (l.meetingTitle != null &&
                    l.meetingTitle!.toLowerCase().contains(q)) ||
                l.ipAddress.contains(q),
          )
          .toList();
    }

    if (actionFilter != null && actionFilter != 'ALL') {
      results = results.where((l) => l.action == actionFilter).toList();
    }

    if (userFilter != null && userFilter != 'ALL') {
      results = results
          .where(
            (l) =>
                l.userId == userFilter ||
                l.userName.toLowerCase().contains(userFilter.toLowerCase()),
          )
          .toList();
    }

    return results;
  }
}

final auditLogRepositoryProvider = Provider<MockAuditLogRepository>((ref) {
  return MockAuditLogRepository();
});

final auditLogsProvider =
    FutureProvider.family<List<AuditLogModel>, Map<String, String>>((
      ref,
      params,
    ) async {
      final repo = ref.watch(auditLogRepositoryProvider);
      return repo.getAuditLogs(
        searchQuery: params['query'],
        actionFilter: params['action'],
        userFilter: params['user'],
      );
    });
