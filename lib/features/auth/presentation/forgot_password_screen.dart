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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String _successMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please enter your work email address.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final msg = await authRepo.forgotPassword(email: email);

      if (!mounted) return;
      setState(() {
        _isSuccess = true;
        _successMessage = msg;
      });

      AppSnackBar.show(context, message: msg, type: AppSnackBarType.success);
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Failed to request password reset';
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
                  // Header Icon
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
                            ? Icons.mark_email_read_rounded
                            : Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Text(
                    _isSuccess ? 'Instructions Sent' : 'Forgot Password',
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
                        ? _successMessage
                        : 'Enter your registered email address to receive password reset instructions.',
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
                                Icons.check_circle_outline_rounded,
                                color: AppColors.success,
                                size: 52,
                              ),
                              AppSpacing.gapMd,
                              const Text(
                                'Check Your Inbox',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppSpacing.gapSm,
                              Text(
                                _successMessage,
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
                              AppTextField(
                                label: 'Work Email Address',
                                hint: 'name@company.com',
                                controller: _emailController,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              AppSpacing.gapLg,
                              AppButton(
                                text: 'Send Instructions',
                                isFullWidth: true,
                                isLoading: _isLoading,
                                icon: Icons.send_rounded,
                                onPressed: _handleForgotSubmit,
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
