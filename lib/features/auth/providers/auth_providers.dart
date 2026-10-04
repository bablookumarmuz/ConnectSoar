import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../services/mock/mock_auth_repository.dart';
import '../../../services/remote/remote_auth_repository.dart';
import '../domain/models/auth_state.dart';
import '../domain/models/user_model.dart';
import '../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useMockData) {
    return MockAuthRepository();
  }
  final client = ref.watch(apiClientProvider);
  return RemoteAuthRepository(client);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial());

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.getSessionUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthState.authenticated(user);
      return user;
    } on ApiException catch (e) {
      if (e.isPasswordChangeRequired) {
        final resetToken = e.passwordResetToken ?? '';
        final resetUser = e.resetUserData != null
            ? UserModel.fromJson(e.resetUserData!)
            : null;
        state = AuthState.passwordChangeRequired(
          resetToken: resetToken,
          user: resetUser,
        );
      } else {
        state = AuthState.error(e.message);
      }
      rethrow;
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<bool> changePasswordWithResetToken({
    required String newPassword,
    required String confirmPassword,
    required String resetToken,
  }) async {
    state = const AuthState.loading();
    try {
      final success = await _repository.changePasswordWithResetToken(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        resetToken: resetToken,
      );
      if (success) {
        state = const AuthState.unauthenticated(
          message:
              'Password set successfully! Please log in with your new password.',
        );
      }
      return success;
    } on ApiException catch (e) {
      state = AuthState.error(e.message);
      rethrow;
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<bool> changePasswordAuthenticated({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      return await _repository.changePasswordAuthenticated(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _repository.logout();
    } finally {
      state = const AuthState.unauthenticated();
    }
  }
}

final authStateNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return AuthNotifier(repo);
    });
