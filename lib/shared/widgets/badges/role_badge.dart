import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../features/auth/domain/models/user_model.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (role) {
      case UserRole.admin:
        color = AppColors.roleAdmin;
        label = 'ADMIN';
        break;
      case UserRole.manager:
        color = AppColors.roleManager;
        label = 'MANAGER';
        break;
      case UserRole.employee:
        color = AppColors.roleEmployee;
        label = 'EMPLOYEE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderRadiusSm,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }
}
