import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../features/auth/domain/models/user_model.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  final ApiClient _client;
  final SecureStorageService _storage;

  RemoteAuthRepository(this._client, [SecureStorageService? storage])
    : _storage = storage ?? SecureStorageService() {
    _client.onSessionExpired = () async {
      await _storage.clearTokens();
    };
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConfig.loginEndpoint,
      body: {'email': email.trim(), 'password': password},
    );

    if (response is Map<String, dynamic>) {
      final data = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response;
      final accessToken =
          (data['access_token'] ?? data['accessToken']) as String?;
      final refreshToken =
          (data['refresh_token'] ?? data['refreshToken']) as String?;
      final userData = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : (response['user'] is Map<String, dynamic>
                ? response['user'] as Map<String, dynamic>
                : data);

      if (accessToken != null && refreshToken != null) {
        _client.setAuthToken(accessToken);
        await _storage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      if (userData.containsKey('email') ||
          userData.containsKey('id') ||
          userData.containsKey('userId')) {
        return UserModel.fromJson(userData);
      }
    }

    throw const ApiException(
      statusCode: 500,
      message: 'Invalid server response structure during login.',
    );
  }

  @override
  Future<bool> refreshToken() async {
    final storedRefreshToken = await _storage.getRefreshToken();
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      await logout();
      return false;
    }

    try {
      final response = await _client.post(
        ApiConfig.refreshEndpoint,
        body: {
          'refresh_token': storedRefreshToken,
          'refreshToken': storedRefreshToken,
        },
      );

      if (response is Map<String, dynamic>) {
        final data = (response['data'] is Map<String, dynamic>)
            ? response['data'] as Map<String, dynamic>
            : response;
        final newAccessToken =
            (data['access_token'] ?? data['accessToken']) as String?;
        final newRefreshToken =
            (data['refresh_token'] ?? data['refreshToken']) as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          _client.setAuthToken(newAccessToken);
          await _storage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }
      await logout();
      return false;
    } catch (_) {
      await logout();
      return false;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _client.get(ApiConfig.meEndpoint);

    if (response is Map<String, dynamic> &&
        response['data'] is Map<String, dynamic>) {
      final data = response['data'] as Map<String, dynamic>;
      // Some endpoints return user directly under data or data['user']
      final userData = data.containsKey('email')
          ? data
          : (data['user'] as Map<String, dynamic>? ?? data);
      return UserModel.fromJson(userData);
    }

    throw const ApiException(
      statusCode: 500,
      message: 'Failed to retrieve current user profile.',
    );
  }

  @override
  Future<bool> changePasswordWithResetToken({
    required String newPassword,
    required String confirmPassword,
    required String resetToken,
  }) async {
    final response = await _client.post(
      ApiConfig.changePasswordEndpoint,
      body: {
        'new_password': newPassword,
        'confirm_password': confirmPassword,
        'reset_token': resetToken,
      },
    );

    if (response is Map<String, dynamic>) {
      return response['success'] == true;
    }
    return false;
  }

  @override
  Future<bool> changePasswordAuthenticated({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _client.post(
      ApiConfig.changePasswordEndpoint,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );

    if (response is Map<String, dynamic>) {
      return response['success'] == true;
    }
    return false;
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    String? confirmPassword,
  }) async {
    return changePasswordAuthenticated(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword ?? newPassword,
    );
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    final response = await _client.post(
      ApiConfig.forgotPasswordEndpoint,
      body: {'email': email.trim()},
    );

    if (response is Map<String, dynamic>) {
      return response['message'] as String? ??
          'If an account exists with this email, password reset instructions have been sent.';
    }
    return 'If an account exists with this email, password reset instructions have been sent.';
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(ApiConfig.logoutEndpoint);
    } catch (_) {
      // Regardless of server network/auth outcome, always wipe local session
    } finally {
      _client.setAuthToken(null);
      await _storage.clearTokens();
    }
  }

  @override
  Future<UserModel?> getSessionUser() async {
    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) {
      // Check if refresh token exists to restore session
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final refreshed = await this.refreshToken();
        if (!refreshed) return null;
      } else {
        return null;
      }
    } else {
      _client.setAuthToken(token);
    }

    try {
      return await getCurrentUser();
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        // Try refresh once
        final refreshed = await refreshToken();
        if (refreshed) {
          try {
            return await getCurrentUser();
          } catch (_) {
            await logout();
            return null;
          }
        }
        await logout();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final user = await getSessionUser();
    return user != null;
  }

  @override
  Future<String?> getAuthToken() async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      _client.setAuthToken(token);
    }
    return token;
  }

  // --- Legacy mock/stubs kept for test backward compatibility ---
  @override
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.employee,
    String? adminSecret,
  }) async {
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
  }) async => true;

  @override
  Future<bool> resendVerificationCode({required String email}) async => true;

  @override
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async => true;

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await _client.get('/');
      return response is Map && response['status'] == 'UP';
    } catch (_) {
      return false;
    }
  }
}
