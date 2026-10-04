import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/audit_log_providers.dart';
import '../../../shared/widgets/avatars/app_avatar.dart';
import '../../../shared/widgets/badges/role_badge.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_search_field.dart';
import '../../../shared/widgets/loading/skeleton_loader.dart';
import '../../../shared/widgets/states/empty_state_widget.dart';
import '../../../shared/widgets/states/error_state_widget.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  String _searchQuery = '';
  String _selectedAction = 'ALL';
  final String _selectedUser = 'ALL';
  final ScrollController _filterScrollController = ScrollController();

  final Set<String> _expandedLogIds = {};

  @override
  void dispose() {
    _filterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = AuditLogFilter(
      query: _searchQuery,
      action: _selectedAction,
      user: _selectedUser,
    );
    final logsAsync = ref.watch(auditLogsProvider(filter));

    return Scaffold(
      body: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title & Export Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                            'Enterprise Audit Logs',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.roleAdmin.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ADMIN ONLY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.roleAdmin,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Real-time security telemetry, role changes, IP metadata, and meeting activity',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapWSm,
                AppButton(
                  text: 'Export CSV',
                  icon: Icons.download_rounded,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.sm,
                  onPressed: () {
                    AppSnackBar.show(
                      context,
                      message: 'Audit logs exported as CSV report.',
                      type: AppSnackBarType.success,
                    );
                  },
                ),
              ],
            ),
            AppSpacing.gapMd,

            // Search Bar & Filter Controls
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText:
                        'Search audit log by user, IP address, meeting title, or action...',
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ],
            ),
            AppSpacing.gapSm,

            // Filter Chips Bar
            SingleChildScrollView(
              controller: _filterScrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildActionChip('All Actions', 'ALL'),
                  AppSpacing.gapXXs,
                  _buildActionChip('Role Changes', 'ROLE_CHANGE'),
                  AppSpacing.gapXXs,
                  _buildActionChip('Screen Share', 'SCREEN_SHARE_START'),
                  AppSpacing.gapXXs,
                  _buildActionChip('Mute Events', 'MUTE_ALL'),
                  AppSpacing.gapXXs,
                  _buildActionChip('Policy Updates', 'POLICY_UPDATE'),
                  AppSpacing.gapXXs,
                  _buildActionChip('User Logins', 'USER_LOGIN'),
                ],
              ),
            ),
            AppSpacing.gapMd,

            // Audit Logs List Table
            Expanded(
              child: logsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.shield_outlined,
                      title: 'No Audit Logs Match',
                      description:
                          'No admin audit records match your current filter parameters.',
                    );
                  }

                  return ListView.separated(
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => AppSpacing.gapSm,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final isExpanded = _expandedLogIds.contains(log.id);

                      return AppCard(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedLogIds.remove(log.id);
                            } else {
                              _expandedLogIds.add(log.id);
                            }
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Bar: Action badge, timestamp, IP
                            Row(
                              children: [
                                _buildActionBadge(log.action),
                                AppSpacing.gapSm,
                                Text(
                                  DateFormatter.formatDateTime(log.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurfaceElevated
                                        : AppColors.lightSurfaceElevated,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.dns_rounded,
                                        size: 12,
                                        color: AppColors.info,
                                      ),
                                      AppSpacing.gapXXs,
                                      Text(
                                        log.ipAddress,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gapSm,

                            // User Info Row & Meeting Context
                            Row(
                              children: [
                                AppAvatar(
                                  name: log.userName,
                                  imageUrl: log.userAvatarUrl,
                                  size: 36,
                                ),
                                AppSpacing.gapSm,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            log.userName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.lightTextPrimary,
                                            ),
                                          ),
                                          AppSpacing.gapXXs,
                                          RoleBadge(role: log.userRole),
                                        ],
                                      ),
                                      Text(
                                        '${log.userEmail} • ${log.device} (${log.location})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ],
                            ),

                            if (log.meetingTitle != null) ...[
                              AppSpacing.gapSm,
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.video_camera_front_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    AppSpacing.gapSm,
                                    Expanded(
                                      child: Text(
                                        'Meeting Context: ${log.meetingTitle}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Expandable Metadata Payload Details
                            if (isExpanded) ...[
                              AppSpacing.gapMd,
                              const Divider(),
                              AppSpacing.gapSm,
                              Text(
                                'EVENT METADATA PAYLOAD',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              AppSpacing.gapXs,
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF090A0F)
                                      : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: log.metadata.entries.map((entry) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '"${entry.key}": ',
                                              style: const TextStyle(
                                                color: Color(0xFF818CF8),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '"${entry.value}"',
                                              style: const TextStyle(
                                                color: Color(0xFF34D399),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.separated(
                  itemCount: 4,
                  separatorBuilder: (_, _) => AppSpacing.gapSm,
                  itemBuilder: (_, _) =>
                      const SkeletonLoader(width: double.infinity, height: 80),
                ),
                error: (err, _) => ErrorStateWidget(
                  errorMessage: err.toString(),
                  onRetry: () => ref.invalidate(auditLogsProvider(filter)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(String label, String value) {
    final isSelected = _selectedAction == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedAction = value),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
      ),
      backgroundColor: isDark
          ? AppColors.darkSurfaceElevated
          : AppColors.lightSurfaceElevated,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
    );
  }

  Widget _buildActionBadge(String action) {
    Color color;
    switch (action) {
      case 'ROLE_CHANGE':
        color = AppColors.roleAdmin;
        break;
      case 'SCREEN_SHARE_START':
        color = AppColors.primary;
        break;
      case 'MUTE_ALL':
        color = AppColors.warning;
        break;
      case 'POLICY_UPDATE':
        color = AppColors.info;
        break;
      case 'USER_LOGIN':
        color = AppColors.success;
        break;
      case 'MEETING_ENDED':
        color = AppColors.danger;
        break;
      default:
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        action,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
