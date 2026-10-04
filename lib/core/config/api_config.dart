class ApiConfig {
  ApiConfig._();

  /// The primary backend base URL deployed on Render.
  /// Centralized in this single location for easy environment switching.
  static const String baseUrl = 'https://connectsoar-backend.onrender.com';

  /// Connection and receive timeouts
  static const Duration connectTimeout = Duration(seconds: 25);
  static const Duration receiveTimeout = Duration(seconds: 25);

  // Documented Authentication Endpoints (Source of Truth)
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String refreshEndpoint = '/api/v1/auth/refresh';
  static const String meEndpoint = '/api/v1/auth/me';
  static const String changePasswordEndpoint = '/api/v1/auth/change-password';
  static const String forgotPasswordEndpoint = '/api/v1/auth/forgot-password';
  static const String logoutEndpoint = '/api/v1/auth/logout';
  // Meeting Module Endpoints (/api/meetings strictly, NOT /api/v1/meetings)
  static const String meetingsEndpoint = '/api/meetings';
  static const String createInstantMeetingEndpoint = '/api/meetings';
  static const String scheduleMeetingEndpoint = '/api/meetings';
  static const String joinCodeEndpoint = '/api/meetings/join-code';
  static const String joinMeetingCodeEndpoint = '/api/meetings/join-code';

  static String meetingDetailsEndpoint(String meetingId) =>
      '/api/meetings/$meetingId';
  static String meetingStartEndpoint(String meetingId) =>
      '/api/meetings/$meetingId/start';
  static String meetingJoinEndpoint(String meetingId) =>
      '/api/meetings/$meetingId/join';
  static String meetingLeaveEndpoint(String meetingId) =>
      '/api/meetings/$meetingId/leave';
  static String meetingEndEndpoint(String meetingId) =>
      '/api/meetings/$meetingId/end';
  static String meetingParticipantsEndpoint(String meetingId) =>
      '/api/meetings/$meetingId/participants';
  static String meetingParticipantDetailEndpoint(
    String meetingId,
    String participantUserId,
  ) => '/api/meetings/$meetingId/participants/$participantUserId';
  static String meetingMessagesEndpoint(String meetingId) =>
      '/api/meetings/$meetingId/messages';

  // WebSocket Signaling URL Builder
  static String meetingSignalingWsUrl(String meetingId, String token) {
    final wsBase = baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$wsBase/ws/meetings/$meetingId?token=$token';
  }
}
