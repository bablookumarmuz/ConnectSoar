import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/domain/models/user_model.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final UserStatus? status;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 36.0,
    this.status,
  });

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color get _statusColor {
    switch (status) {
      case UserStatus.online:
        return AppColors.success;
      case UserStatus.busy:
        return AppColors.danger;
      case UserStatus.away:
        return AppColors.warning;
      case UserStatus.offline:
      case null:
        return AppColors.darkTextMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget avatarCore;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarCore = SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.network(
            imageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallback(isDark),
          ),
        ),
      );
    } else {
      avatarCore = _buildFallback(isDark);
    }

    if (status == null) {
      return avatarCore;
    }

    final dotSize = (size * 0.28).clamp(8.0, 14.0);

    return Stack(
      children: [
        avatarCore,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
