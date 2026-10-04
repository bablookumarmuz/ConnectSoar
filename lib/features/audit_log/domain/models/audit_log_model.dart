import '../../../auth/domain/models/user_model.dart';

enum AuditActionCategory {
  userAuth,
  roleManagement,
  meetingControl,
  mediaSharing,
  policyUpdate,
  securityAlert,
}

class AuditLogModel {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String userEmail;
  final String userAvatarUrl;
  final UserRole userRole;
  final String
  action; // e.g. "USER_LOGIN", "ROLE_CHANGE", "MEETING_CREATED", "SCREEN_SHARE_START", "MUTE_ALL", "MEETING_ENDED", "POLICY_UPDATE"
  final AuditActionCategory category;
  final String? meetingId;
  final String? meetingTitle;
  final String ipAddress;
  final String device; // e.g. "Chrome 128 (Windows 11)"
  final String location; // e.g. "San Jose, CA, US"
  final Map<String, dynamic> metadata;

  const AuditLogModel({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userAvatarUrl,
    required this.userRole,
    required this.action,
    required this.category,
    this.meetingId,
    this.meetingTitle,
    required this.ipAddress,
    required this.device,
    required this.location,
    this.metadata = const {},
  });
}
