import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

class ConnectSoarFAB extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isExtended;

  const ConnectSoarFAB({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isExtended = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLg),
      child: Icon(icon, size: 22),
    );
  }
}
