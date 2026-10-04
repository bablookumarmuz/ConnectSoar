import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../../users/providers/user_providers.dart';
import '../../../shared/widgets/avatars/app_avatar.dart';
import '../../../shared/widgets/badges/role_badge.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../shared/widgets/loading/skeleton_loader.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import '../../../shared/widgets/tools/role_switcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _audioDevice = 'default';
  String _videoDevice = 'hd_cam';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App & Account Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            AppSpacing.gapLg,

            // Developer Role Switcher Tool Section (only in mock testing mode)
            if (ref.watch(appConfigProvider).useMockData) ...[
              const RoleSwitcher(compact: false),
              AppSpacing.gapLg,
            ],

            // Profile Info Card
            userAsync.when(
              data: (user) => AppCard(
                child: Row(
                  children: [
                    AppAvatar(
                      name: user.name,
                      imageUrl: user.avatarUrl,
                      size: 56,
                      status: user.status,
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              RoleBadge(role: user.role),
                            ],
                          ),
                          AppSpacing.gapXXs,
                          Text(
                            '${user.title} • ${user.department}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                          if (user.phone != null && user.phone!.isNotEmpty) ...[
                            AppSpacing.gapXXs,
                            Text(
                              user.phone!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              loading: () =>
                  const SkeletonLoader(width: double.infinity, height: 90),
              error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
            ),
            AppSpacing.gapLg,

            // Theme Preferences
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appearance & Theme',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.gapSm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Theme Mode (Light / Dark)'),
                      Switch(
                        value: themeMode == ThemeMode.dark,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {
                          ref.read(themeModeProvider.notifier).state = val
                              ? ThemeMode.dark
                              : ThemeMode.light;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // Hardware Audio/Video Preferences
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Audio & Video Hardware',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.gapMd,
                  AppDropdown<String>(
                    label: 'Microphone & Speaker',
                    value: _audioDevice,
                    items: const [
                      AppDropdownItem(
                        value: 'default',
                        label: 'System Default Microphone & Speaker',
                        icon: Icons.mic_rounded,
                      ),
                      AppDropdownItem(
                        value: 'headphones',
                        label: 'Bluetooth Headset Hands-Free',
                        icon: Icons.headphones_rounded,
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _audioDevice = val);
                    },
                  ),
                  AppSpacing.gapMd,
                  AppDropdown<String>(
                    label: 'Camera Source',
                    value: _videoDevice,
                    items: const [
                      AppDropdownItem(
                        value: 'hd_cam',
                        label: 'Integrated HD Web Camera (1080p)',
                        icon: Icons.videocam_rounded,
                      ),
                      AppDropdownItem(
                        value: 'obs_cam',
                        label: 'OBS Virtual Camera',
                        icon: Icons.camera_front_rounded,
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _videoDevice = val);
                    },
                  ),
                  AppSpacing.gapLg,
                  AppButton(
                    text: 'Save Preferences',
                    onPressed: () {
                      AppSnackBar.show(
                        context,
                        message: 'Settings saved successfully!',
                        type: AppSnackBarType.success,
                      );
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // Security & Password Section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Security & Authentication',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.gapSm,
                  Text(
                    'Manage your account credentials and security preferences.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                  AppSpacing.gapMd,
                  OutlinedButton.icon(
                    icon: const Icon(Icons.lock_reset_rounded, size: 18),
                    label: const Text('Change Password'),
                    onPressed: () => _showChangePasswordDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              AppSpacing.gapSm,
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.key_rounded),
                ),
              ),
              AppSpacing.gapSm,
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_clock_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final current = currentController.text;
                      final newPwd = newController.text;
                      final confirm = confirmController.text;

                      if (current.isEmpty ||
                          newPwd.isEmpty ||
                          confirm.isEmpty) {
                        AppSnackBar.show(
                          dialogCtx,
                          message: 'Please fill in all fields.',
                          type: AppSnackBarType.warning,
                        );
                        return;
                      }

                      if (newPwd != confirm) {
                        AppSnackBar.show(
                          dialogCtx,
                          message: 'New passwords do not match.',
                          type: AppSnackBarType.warning,
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);
                      try {
                        final authRepo = ref.read(authRepositoryProvider);
                        await authRepo.changePasswordAuthenticated(
                          currentPassword: current,
                          newPassword: newPwd,
                          confirmPassword: confirm,
                        );
                        if (!dialogCtx.mounted) return;
                        Navigator.pop(dialogCtx);
                        if (dialogCtx.mounted) {
                          AppSnackBar.show(
                            dialogCtx,
                            message: 'Password changed successfully!',
                            type: AppSnackBarType.success,
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (dialogCtx.mounted) {
                          AppSnackBar.show(
                            dialogCtx,
                            message: e.toString().replaceAll('Exception: ', ''),
                            type: AppSnackBarType.error,
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}
