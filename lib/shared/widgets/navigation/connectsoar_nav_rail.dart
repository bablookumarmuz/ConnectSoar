import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'connectsoar_bottom_nav_bar.dart';

class ConnectSoarNavRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ConnectSoarNavItem> items;
  final Widget? header;
  final Widget? footer;

  const ConnectSoarNavRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          if (header != null) ...[header!, AppSpacing.gapLg],
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => AppSpacing.gapXs,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? AppColors.primaryContainerDark
                                : AppColors.primaryContainer)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 20,
                          color: isSelected
                              ? (isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary)
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                        ),
                        AppSpacing.gapWMd,
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? (isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary)
                                : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (footer != null) ...[AppSpacing.gapMd, footer!],
        ],
      ),
    );
  }
}
