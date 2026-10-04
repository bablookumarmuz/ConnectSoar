import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../feedback/app_bottom_sheet.dart';

class ConnectSoarNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ConnectSoarNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class ConnectSoarBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ConnectSoarNavItem> items;

  const ConnectSoarBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  void _showMoreMenu(BuildContext context, bool isDark) {
    AppBottomSheet.show(
      context: context,
      title: 'More Navigation',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length - 4, (offset) {
          final index = 4 + offset;
          final item = items[index];
          final isSelected = currentIndex == index;

          return ListTile(
            leading: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
            ),
            title: Text(
              item.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_rounded,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    size: 20,
                  )
                : null,
            onTap: () {
              Navigator.of(context).pop();
              HapticFeedback.selectionClick();
              onTap(index);
            },
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasMore = items.length > 5;

    final displayItems = hasMore ? items.sublist(0, 4) : items;
    final isMoreSelected = hasMore && currentIndex >= 4;
    final activeIndex = hasMore
        ? (currentIndex < 4 ? currentIndex : 4)
        : currentIndex.clamp(0, displayItems.length - 1);

    final navBarItems = [
      ...displayItems.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.activeIcon),
          label: item.label,
        );
      }),
      if (hasMore)
        const BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz_rounded),
          activeIcon: Icon(Icons.more_horiz_rounded),
          label: 'More',
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: activeIndex,
          onTap: (idx) {
            HapticFeedback.selectionClick();
            if (hasMore && idx == 4) {
              _showMoreMenu(context, isDark);
            } else {
              onTap(idx);
            }
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: isMoreSelected || activeIndex == 4
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : (isDark ? AppColors.primaryLight : AppColors.primary),
          unselectedItemColor: isDark
              ? AppColors.darkTextMuted
              : AppColors.lightTextMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: navBarItems,
        ),
      ),
    );
  }
}
