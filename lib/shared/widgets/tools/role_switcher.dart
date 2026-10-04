import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/domain/models/user_model.dart';
import '../../../features/users/providers/user_providers.dart';
import '../badges/role_badge.dart';

class RoleSwitcher extends ConsumerWidget {
  final bool compact;

  const RoleSwitcher({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedUserIndexProvider);
    final users = ref.watch(allUsersProvider).value ?? [];
    if (users.length <= 1) return const SizedBox.shrink();
    final clampedIndex = selectedIndex.clamp(0, users.length - 1);
    final currentUser = users[clampedIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (compact) {
      return PopupMenuButton<int>(
        tooltip: 'Switch Mock Role (Dev Tool)',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (int index) {
          ref.read(selectedUserIndexProvider.notifier).state = index;
        },
        itemBuilder: (context) {
          return List.generate(users.length, (index) {
            final user = users[index];
            return PopupMenuItem<int>(
              value: index,
              child: Row(
                children: [
                  RoleBadge(role: user.role),
                  AppSpacing.gapWSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: index == selectedIndex
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          user.title,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index == selectedIndex)
                    const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                ],
              ),
            );
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoleBadge(role: currentUser.role),
              AppSpacing.gapXXs,
              const Icon(
                Icons.swap_vert_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bug_report_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              AppSpacing.gapWSm,
              const Text(
                'Role Switcher (Developer Tool)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          AppSpacing.gapXs,
          Text(
            'Switch mock user to preview Admin, Manager, and Employee dashboards without re-logging in.',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
          AppSpacing.gapMd,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(users.length, (index) {
              final user = users[index];
              final isSelected = index == selectedIndex;
              Color roleColor = AppColors.roleEmployee;
              switch (user.role) {
                case UserRole.admin:
                  roleColor = AppColors.roleAdmin;
                  break;
                case UserRole.manager:
                  roleColor = AppColors.roleManager;
                  break;
                case UserRole.employee:
                  roleColor = AppColors.roleEmployee;
                  break;
              }

              final firstName = user.name.trim().isNotEmpty
                  ? (user.name.trim().split(RegExp(r'\s+')).firstOrNull ?? '')
                  : '';

              return ChoiceChip(
                selected: isSelected,
                avatar: CircleAvatar(
                  backgroundColor: roleColor,
                  radius: 8,
                  child: Text(
                    user.role.name.isNotEmpty
                        ? user.role.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                label: Text(
                  firstName.isNotEmpty
                      ? '${user.roleDisplayName} ($firstName)'
                      : user.roleDisplayName,
                ),
                selectedColor: roleColor.withValues(alpha: 0.2),
                side: BorderSide(
                  color: isSelected
                      ? roleColor
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                onSelected: (selected) {
                  if (selected) {
                    ref.read(selectedUserIndexProvider.notifier).state = index;
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
