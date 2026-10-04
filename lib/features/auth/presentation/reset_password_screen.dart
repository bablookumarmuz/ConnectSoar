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
import '../providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetSubmit() async {
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (code.length != 6) {
      AppSnackBar.show(
        context,
        message: 'Please enter a valid 6-digit reset code.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please enter and confirm your new password.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      AppSnackBar.show(
        context,
        message: 'Passwords do not match.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (newPassword.length < 8) {
      AppSnackBar.show(
        context,
        message: 'Password must be at least 8 characters long.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final success = await authRepo.resetPassword(
        email: widget.email,
        code: code,
        newPassword: newPassword,
      );

      if (!mounted) return;
      if (success) {
        setState(() => _isSuccess = true);
        AppSnackBar.show(
          context,
          message: 'Password reset successfully! Please sign in.',
          type: AppSnackBarType.success,
        );
      } else {
        AppSnackBar.show(
          context,
          message: 'Failed to reset password. Check your code.',
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Password reset failed';
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isSuccess
                            ? AppColors.success
                            : AppColors.primary,
                        borderRadius: AppRadius.borderRadiusLg,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isSuccess
                                        ? AppColors.success
                                        : AppColors.primary)
                                    .withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSuccess
                            ? Icons.check_circle_rounded
                            : Icons.key_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Text(
                    _isSuccess ? 'Password Reset Complete' : 'Reset Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    _isSuccess
                        ? 'Your password has been reset successfully.'
                        : 'Enter the 6-digit reset code sent to:\n${widget.email}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapLg,

                  // Main Card
                  AppCard(
                    child: _isSuccess
                        ? Column(
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.success,
                                size: 56,
                              ),
                              AppSpacing.gapMd,
                              const Text(
                                'Ready to Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppSpacing.gapSm,
                              Text(
                                'You can now sign in with your new password.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              AppSpacing.gapLg,
                              AppButton(
                                text: 'Sign In Now',
                                isFullWidth: true,
                                icon: Icons.login_rounded,
                                onPressed: () => context.go(AppRoutes.login),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                label: '6-Digit Reset Code',
                                hint: 'e.g. 123456',
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.pin_outlined,
                              ),
                              AppSpacing.gapMd,
                              AppTextField(
                                label: 'New Password',
                                hint: 'At least 8 characters',
                                controller: _newPasswordController,
                                obscureText: _obscureNewPassword,
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureNewPassword =
                                        !_obscureNewPassword,
                                  ),
                                ),
                              ),
                              AppSpacing.gapMd,
                              AppTextField(
                                label: 'Confirm New Password',
                                hint: 'Re-enter new password',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                prefixIcon: Icons.lock_clock_outlined,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                              ),
                              AppSpacing.gapLg,
                              AppButton(
                                text: 'Update Password',
                                isFullWidth: true,
                                isLoading: _isLoading,
                                icon: Icons.security_rounded,
                                onPressed: _handleResetSubmit,
                              ),
                              AppSpacing.gapMd,
                              Center(
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Back to Login'),
                                  onPressed: () => context.go(AppRoutes.login),
                                ),
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
