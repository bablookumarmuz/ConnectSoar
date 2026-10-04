import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../providers/auth_providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  /// If [resetToken] is provided, operates in Mode A (First-time password setup).
  /// If null, operates in Mode B (Authenticated password change).
  final String? resetToken;
  final String? email;

  const ChangePasswordScreen({super.key, this.resetToken, this.email});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;

  bool get _isModeA =>
      widget.resetToken != null && widget.resetToken!.isNotEmpty;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final current = _currentPasswordController.text;
    final newPwd = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (!_isModeA && current.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please enter your current password.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (newPwd.isEmpty || confirm.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please enter and confirm your new password.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (newPwd != confirm) {
      AppSnackBar.show(
        context,
        message: 'Passwords do not match.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (newPwd.length < 8) {
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
      bool success = false;

      if (_isModeA) {
        // MODE A: First-time setup with reset_token
        success = await authRepo.changePasswordWithResetToken(
          newPassword: newPwd,
          confirmPassword: confirm,
          resetToken: widget.resetToken!,
        );
      } else {
        // MODE B: Authenticated session with current_password
        success = await authRepo.changePasswordAuthenticated(
          currentPassword: current,
          newPassword: newPwd,
          confirmPassword: confirm,
        );
      }

      if (!mounted) return;

      if (success) {
        setState(() => _isSuccess = true);
        AppSnackBar.show(
          context,
          message: 'Password changed successfully! You can now sign in.',
          type: AppSnackBarType.success,
        );
      } else {
        AppSnackBar.show(
          context,
          message: 'Failed to update password. Please check your inputs.',
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Failed to update password';
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
                  // Icon Header
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
                            : Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Text(
                    _isSuccess
                        ? 'Password Updated!'
                        : (_isModeA ? 'Set New Password' : 'Change Password'),
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
                        ? 'Your password has been changed successfully.'
                        : (_isModeA
                              ? 'A password change is required before accessing your workspace.'
                              : 'Enter your current password and your new password below.'),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapLg,

                  // Form Card
                  AppCard(
                    child: _isSuccess
                        ? Column(
                            children: [
                              const Icon(
                                Icons.verified_user_rounded,
                                color: AppColors.success,
                                size: 52,
                              ),
                              AppSpacing.gapMd,
                              const Text(
                                'All Set!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppSpacing.gapSm,
                              Text(
                                'Please sign in with your new password to continue.',
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
                                text: 'Back to Sign In',
                                isFullWidth: true,
                                icon: Icons.login_rounded,
                                onPressed: () => context.go(AppRoutes.login),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Mode B: Current password field
                              if (!_isModeA) ...[
                                AppTextField(
                                  label: 'Current Password',
                                  hint: 'Enter current password',
                                  controller: _currentPasswordController,
                                  obscureText: _obscureCurrentPassword,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureCurrentPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(
                                      () => _obscureCurrentPassword =
                                          !_obscureCurrentPassword,
                                    ),
                                  ),
                                ),
                                AppSpacing.gapMd,
                              ],

                              // New password
                              AppTextField(
                                label: 'New Password',
                                hint: 'At least 8 characters',
                                controller: _newPasswordController,
                                obscureText: _obscureNewPassword,
                                prefixIcon: Icons.lock_reset_rounded,
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

                              // Confirm password
                              AppTextField(
                                label: 'Confirm New Password',
                                hint: 'Re-enter new password',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                prefixIcon: Icons.check_circle_outline_rounded,
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

                              // Submit button
                              AppButton(
                                text: _isModeA
                                    ? 'Set Password & Continue'
                                    : 'Update Password',
                                isFullWidth: true,
                                isLoading: _isLoading,
                                icon: Icons.security_rounded,
                                onPressed: _handleSubmit,
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
