import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../services/remote/api_client.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../users/providers/user_providers.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getSessionUser();
      if (user != null && mounted) {
        ref.invalidate(currentUserProvider);
        context.go(AppRoutes.dashboard);
      }
    } catch (_) {}
  }

  void _handleLoginSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailErr;
    String? passwordErr;

    if (email.isEmpty) {
      emailErr = 'Please enter your work email.';
    } else if (!email.contains('@') || !email.contains('.')) {
      emailErr = 'Please enter a valid work email address.';
    }

    if (password.isEmpty) {
      passwordErr = 'Please enter your password.';
    }

    if (emailErr != null || passwordErr != null) {
      setState(() {
        _emailError = emailErr;
        _passwordError = passwordErr;
      });
      AppSnackBar.show(
        context,
        message: 'Please provide both a valid email and password.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() {
      _emailError = null;
      _passwordError = null;
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.login(email: email, password: password);
      ref.invalidate(currentUserProvider);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Signed in successfully as ${user.name}',
        type: AppSnackBarType.success,
      );
      context.go(AppRoutes.dashboard);
    } catch (e) {
      if (!mounted) return;

      if (e is ApiException) {
        if (e.isPasswordChangeRequired) {
          final resetToken = e.passwordResetToken;
          AppSnackBar.show(
            context,
            message:
                'Password change is required before accessing the application.',
            type: AppSnackBarType.warning,
          );
          context.go(
            AppRoutes.changePassword,
            extra: {'token': resetToken, 'email': email},
          );
          return;
        } else if (e.isInvalidCredentials) {
          AppSnackBar.show(
            context,
            message: 'Invalid email or password.',
            type: AppSnackBarType.error,
          );
          return;
        } else if (e.isUserInactive) {
          AppSnackBar.show(
            context,
            message:
                'User account is inactive. Please contact your administrator.',
            type: AppSnackBarType.error,
          );
          return;
        }
      }

      String errorMsg = 'Authentication failed';
      if (e is ApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }

      AppSnackBar.show(context, message: errorMsg, type: AppSnackBarType.error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Header
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.borderRadiusLg,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Text(
                    'ConnectSoar',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    'Sign in to your enterprise workspace',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapXl,

                  // Main Auth Form Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        AppSpacing.gapMd,
                        AppTextField(
                          label: 'Work Email',
                          hint: 'name@company.com',
                          controller: _emailController,
                          errorText: _emailError,
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        AppSpacing.gapMd,
                        AppTextField(
                          label: 'Password',
                          hint: '••••••••••••',
                          controller: _passwordController,
                          errorText: _passwordError,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        AppSpacing.gapSm,

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.go(AppRoutes.forgotPassword),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ),
                        AppSpacing.gapMd,

                        // Sign In Button
                        AppButton(
                          text: 'Sign In to Workspace',
                          isFullWidth: true,
                          isLoading: _isLoading,
                          icon: Icons.login_rounded,
                          onPressed: _handleLoginSubmit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
