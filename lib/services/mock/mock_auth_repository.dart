import '../../features/auth/domain/models/user_model.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import 'mock_data_generator.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _sessionUser;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final matchedUser = MockDataGenerator.sampleUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => MockDataGenerator.sampleUsers.first,
    );
    _sessionUser = matchedUser;
    return matchedUser;
  }

  @override
  Future<bool> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sessionUser != null;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_sessionUser != null) {
      return _sessionUser!;
    }
    return MockDataGenerator.sampleUsers.first;
  }

  @override
  Future<bool> changePasswordWithResetToken({
    required String newPassword,
    required String confirmPassword,
    required String resetToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<bool> changePasswordAuthenticated({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.employee,
    String? adminSecret,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return RegisterResult(
      requiresVerification: true,
      email: email,
      message: 'Account created! Please verify your email.',
    );
  }

  @override
  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> resendVerificationCode({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'If an account exists with this email, password reset instructions have been sent.';
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    String? confirmPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sessionUser = null;
  }

  @override
  Future<UserModel?> getSessionUser() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _sessionUser;
  }

  @override
  Future<bool> isAuthenticated() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _sessionUser != null;
  }

  @override
  Future<String?> getAuthToken() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _sessionUser != null
        ? 'mock_jwt_token_connectsoar_${_sessionUser!.id}'
        : null;
  }

  @override
  Future<bool> healthCheck() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }
}
