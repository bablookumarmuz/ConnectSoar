class ApiException implements Exception {
  final int statusCode;
  final String? code;
  final String message;
  final dynamic data;

  const ApiException({
    required this.statusCode,
    this.code,
    required this.message,
    this.data,
  });

  bool get isPasswordChangeRequired => code == 'PASSWORD_CHANGE_REQUIRED';
  bool get isInvalidCredentials => code == 'INVALID_CREDENTIALS';
  bool get isUserInactive => code == 'USER_INACTIVE';
  bool get isTokenInvalid => code == 'TOKEN_INVALID';

  String? get passwordResetToken {
    if (data is Map<String, dynamic>) {
      return data['password_reset_token'] as String?;
    }
    return null;
  }

  Map<String, dynamic>? get resetUserData {
    if (data is Map<String, dynamic> && data['user'] is Map<String, dynamic>) {
      return data['user'] as Map<String, dynamic>;
    }
    return null;
  }

  @override
  String toString() {
    if (code != null) {
      return 'ApiException [$statusCode | $code]: $message';
    }
    return 'ApiException [$statusCode]: $message';
  }
}
