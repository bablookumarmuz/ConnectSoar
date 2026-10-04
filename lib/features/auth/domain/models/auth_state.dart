import 'user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  passwordChangeRequired,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? passwordResetToken;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.passwordResetToken,
    this.errorMessage,
  });

  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      passwordResetToken = null,
      errorMessage = null;

  const AuthState.loading()
    : status = AuthStatus.loading,
      user = null,
      passwordResetToken = null,
      errorMessage = null;

  const AuthState.authenticated(this.user)
    : status = AuthStatus.authenticated,
      passwordResetToken = null,
      errorMessage = null;

  const AuthState.unauthenticated({String? message})
    : status = AuthStatus.unauthenticated,
      user = null,
      passwordResetToken = null,
      errorMessage = message;

  const AuthState.passwordChangeRequired({
    required String resetToken,
    this.user,
  }) : status = AuthStatus.passwordChangeRequired,
       passwordResetToken = resetToken,
       errorMessage = null;

  const AuthState.error(String message)
    : status = AuthStatus.error,
      user = null,
      passwordResetToken = null,
      errorMessage = message;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isPasswordChangeRequired =>
      status == AuthStatus.passwordChangeRequired;
  bool get isLoading => status == AuthStatus.loading;
}
