import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'app_avatar.dart';

class AvatarGroupItem {
  final String name;
  final String? imageUrl;

  const AvatarGroupItem({required this.name, this.imageUrl});
}

class AvatarGroup extends StatelessWidget {
  final List<AvatarGroupItem> items;
  final int maxVisible;
  final double avatarSize;

  const AvatarGroup({
    super.key,
    required this.items,
    this.maxVisible = 3,
    this.avatarSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleItems = items.take(maxVisible).toList();
    final remainingCount = items.length - maxVisible;

    return SizedBox(
      height: avatarSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width:
                (visibleItems.length * (avatarSize * 0.7)) + (avatarSize * 0.3),
            child: Stack(
              children: [
                for (int i = 0; i < visibleItems.length; i++)
                  Positioned(
                    left: i * (avatarSize * 0.7),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                          width: 2,
                        ),
                      ),
                      child: AppAvatar(
                        name: visibleItems[i].name,
                        imageUrl: visibleItems[i].imageUrl,
                        size: avatarSize - 4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (remainingCount > 0) ...[
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '+$remainingCount',
                  style: TextStyle(
                    fontSize: avatarSize * 0.35,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
