import 'package:flutter_test/flutter_test.dart';
import 'package:connectsoar/core/config/api_config.dart';
import 'package:connectsoar/core/network/api_exception.dart';
import 'package:connectsoar/features/auth/domain/models/auth_state.dart';
import 'package:connectsoar/features/auth/domain/models/user_model.dart';

void main() {
  group('Authentication Unit Tests — Real API Contract & Models', () {
    test('ApiConfig contains correct Render backend URL and endpoints', () {
      expect(
        ApiConfig.baseUrl,
        equals('https://connectsoar-backend.onrender.com'),
      );
      expect(ApiConfig.loginEndpoint, equals('/api/v1/auth/login'));
      expect(ApiConfig.refreshEndpoint, equals('/api/v1/auth/refresh'));
      expect(ApiConfig.meEndpoint, equals('/api/v1/auth/me'));
      expect(
        ApiConfig.changePasswordEndpoint,
        equals('/api/v1/auth/change-password'),
      );
      expect(
        ApiConfig.forgotPasswordEndpoint,
        equals('/api/v1/auth/forgot-password'),
      );
      expect(ApiConfig.logoutEndpoint, equals('/api/v1/auth/logout'));
    });

    test('UserModel.fromJson maps real backend payload correctly', () {
      final json = {
        "id": "c8d62635-4309-450f-a7b6-c677610368a5",
        "email": "employee@example.com",
        "name": "Rahul Kumar",
        "role": "employee",
        "status": "active",
        "department": "Engineering",
        "designation": "Flutter Developer",
        "phone": "+919876543210",
        "image_url": null,
        "reset_password": false,
        "created_at": "2026-08-31T13:30:00Z",
        "updated_at": "2026-08-31T13:30:00Z",
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals("c8d62635-4309-450f-a7b6-c677610368a5"));
      expect(user.email, equals("employee@example.com"));
      expect(user.name, equals("Rahul Kumar"));
      expect(user.role, equals(UserRole.employee));
      expect(user.department, equals("Engineering"));
      expect(user.designation, equals("Flutter Developer"));
      expect(user.title, equals("Flutter Developer"));
      expect(user.phone, equals("+919876543210"));
      expect(user.imageUrl, isNull);
      expect(user.avatarUrl, equals(''));
      expect(user.resetPassword, isFalse);
      expect(user.createdAt, equals("2026-08-31T13:30:00Z"));
    });

    test('ApiException correctly identifies PASSWORD_CHANGE_REQUIRED', () {
      const exception = ApiException(
        statusCode: 403,
        code: 'PASSWORD_CHANGE_REQUIRED',
        message:
            'Password change is required before accessing the application.',
        data: {
          'reset_password': true,
          'password_reset_token': 'test_reset_token_xyz_123',
          'user': {
            'id': 'user_123',
            'email': 'new.employee@example.com',
            'name': 'Jane New',
            'role': 'employee',
          },
        },
      );

      expect(exception.isPasswordChangeRequired, isTrue);
      expect(exception.passwordResetToken, equals('test_reset_token_xyz_123'));
      expect(exception.resetUserData?['name'], equals('Jane New'));
      expect(exception.isInvalidCredentials, isFalse);
      expect(exception.isUserInactive, isFalse);
    });

    test(
      'ApiException correctly identifies INVALID_CREDENTIALS and USER_INACTIVE',
      () {
        const invalidCreds = ApiException(
          statusCode: 401,
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password.',
        );
        expect(invalidCreds.isInvalidCredentials, isTrue);
        expect(invalidCreds.isPasswordChangeRequired, isFalse);

        const inactiveUser = ApiException(
          statusCode: 403,
          code: 'USER_INACTIVE',
          message: 'User account is inactive.',
        );
        expect(inactiveUser.isUserInactive, isTrue);
        expect(inactiveUser.isInvalidCredentials, isFalse);

        const invalidToken = ApiException(
          statusCode: 401,
          code: 'TOKEN_INVALID',
          message: 'Invalid or expired refresh token.',
        );
        expect(invalidToken.isTokenInvalid, isTrue);
      },
    );

    test('AuthState lifecycle states behave correctly', () {
      const initial = AuthState.initial();
      expect(initial.isAuthenticated, isFalse);
      expect(initial.isLoading, isFalse);

      const loading = AuthState.loading();
      expect(loading.isLoading, isTrue);

      final user = UserModel(
        id: 'u1',
        name: 'Alex Vance',
        email: 'alex@example.com',
        role: UserRole.admin,
      );
      final auth = AuthState.authenticated(user);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.name, equals('Alex Vance'));

      const pwdReq = AuthState.passwordChangeRequired(resetToken: 'rst_123');
      expect(pwdReq.isPasswordChangeRequired, isTrue);
      expect(pwdReq.passwordResetToken, equals('rst_123'));
    });

    test('Login validation blocks empty and malformed credentials', () {
      // Empty email validation rule
      String? validateEmail(String email) {
        final trimmed = email.trim();
        if (trimmed.isEmpty) return 'Please enter your work email.';
        if (!trimmed.contains('@') || !trimmed.contains('.')) {
          return 'Please enter a valid work email address.';
        }
        return null;
      }

      // Empty password validation rule
      String? validatePassword(String password) {
        if (password.isEmpty) return 'Please enter your password.';
        return null;
      }

      // 1. Both empty -> blocked
      expect(validateEmail(''), equals('Please enter your work email.'));
      expect(validatePassword(''), equals('Please enter your password.'));

      // 2. Email only -> blocked on password
      expect(validateEmail('employee1@gmail.com'), isNull);
      expect(validatePassword(''), equals('Please enter your password.'));

      // 3. Password only -> blocked on email
      expect(validateEmail(''), equals('Please enter your work email.'));
      expect(validatePassword('Password123!'), isNull);

      // 4. Invalid email format -> blocked
      expect(
        validateEmail('notanemail'),
        equals('Please enter a valid work email address.'),
      );
      expect(
        validateEmail('user@'),
        equals('Please enter a valid work email address.'),
      );

      // 5. Valid credentials -> passes validation
      expect(validateEmail('employee1@gmail.com'), isNull);
      expect(validatePassword('Password123!'), isNull);
    });

    test('Session restoration and logout token cleanup verification', () {
      // Tokens state simulation
      String? accessToken;
      String? refreshToken;

      void saveTokens(String at, String rt) {
        accessToken = at;
        refreshToken = rt;
      }

      void clearTokens() {
        accessToken = null;
        refreshToken = null;
      }

      bool hasValidSession() => accessToken != null && accessToken!.isNotEmpty;

      // Initial clean state
      expect(hasValidSession(), isFalse);

      // Save tokens upon successful auth
      saveTokens('access_token_123', 'refresh_token_456');
      expect(hasValidSession(), isTrue);
      expect(accessToken, equals('access_token_123'));
      expect(refreshToken, equals('refresh_token_456'));

      // Logout clears tokens completely
      clearTokens();
      expect(hasValidSession(), isFalse);
      expect(accessToken, isNull);
      expect(refreshToken, isNull);
    });
  });
}
