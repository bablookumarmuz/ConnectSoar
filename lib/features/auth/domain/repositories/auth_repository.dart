import '../models/user_model.dart';

class RegisterResult {
  final bool requiresVerification;
  final String email;
  final String message;

  const RegisterResult({
    required this.requiresVerification,
    required this.email,
    required this.message,
  });
}

abstract class AuthRepository {
  /// Documented 1: POST /api/v1/auth/login
  Future<UserModel> login({required String email, required String password});

  /// Documented 2: POST /api/v1/auth/refresh
  Future<bool> refreshToken();

  /// Documented 3: GET /api/v1/auth/me
  Future<UserModel> getCurrentUser();

  /// Documented 4 (Mode A): POST /api/v1/auth/change-password (First-time setup with reset_token)
  Future<bool> changePasswordWithResetToken({
    required String newPassword,
    required String confirmPassword,
    required String resetToken,
  });

  /// Documented 4 (Mode B): POST /api/v1/auth/change-password (Normal authenticated session)
  Future<bool> changePasswordAuthenticated({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  /// Unified change password helper for convenience
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    String? confirmPassword,
  });

  /// Documented 5: POST /api/v1/auth/forgot-password
  Future<String> forgotPassword({required String email});

  /// Documented 6: POST /api/v1/auth/logout
  Future<void> logout();

  /// Session retrieval & status
  Future<UserModel?> getSessionUser();
  Future<bool> isAuthenticated();
  Future<String?> getAuthToken();

  // Legacy mock methods for test/backward compatibility
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.employee,
    String? adminSecret,
  });
  Future<bool> verifyEmail({required String email, required String code});
  Future<bool> resendVerificationCode({required String email});
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<bool> healthCheck();
}
