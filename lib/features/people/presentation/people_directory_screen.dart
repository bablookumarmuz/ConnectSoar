import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../users/providers/user_providers.dart';
import '../../../shared/widgets/avatars/app_avatar.dart';
import '../../../shared/widgets/badges/role_badge.dart';
import '../../../shared/widgets/badges/status_badge.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/inputs/app_search_field.dart';
import '../../../shared/widgets/loading/skeleton_loader.dart';
import '../../../shared/widgets/states/empty_state_widget.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import '../../auth/domain/models/user_model.dart';
import 'widgets/user_profile_dialog.dart';

class PeopleDirectoryScreen extends ConsumerStatefulWidget {
  const PeopleDirectoryScreen({super.key});

  @override
  ConsumerState<PeopleDirectoryScreen> createState() =>
      _PeopleDirectoryScreenState();
}

class _PeopleDirectoryScreenState extends ConsumerState<PeopleDirectoryScreen> {
  String _searchQuery = '';
  UserRole? _selectedRoleFilter;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & View Toggle Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'People & Directory',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Discover colleagues, teams & active status',
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
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.grid_view_rounded,
                              color: _isGridView
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted),
                            ),
                            tooltip: 'Grid View',
                            onPressed: () => setState(() => _isGridView = true),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.view_list_rounded,
                              color: !_isGridView
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted),
                            ),
                            tooltip: 'List View',
                            onPressed: () =>
                                setState(() => _isGridView = false),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppSpacing.gapMd,

                  // Search Field
                  AppSearchField(
                    hintText:
                        'Search people by name, email, role, or department...',
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  AppSpacing.gapSm,

                  // Role Filter Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildRoleChip('All Roles', null),
                      _buildRoleChip('Administrators', UserRole.admin),
                      _buildRoleChip('Managers', UserRole.manager),
                      _buildRoleChip('Employees', UserRole.employee),
                    ],
                  ),
                  AppSpacing.gapMd,

                  // Recently Contacted Section
                  Text(
                    'RECENTLY CONTACTED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                  AppSpacing.gapSm,
                  usersAsync.when(
                    data: (users) => SizedBox(
                      height: 84,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: users.length,
                        separatorBuilder: (_, _) => AppSpacing.gapSm,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return InkWell(
                            onTap: () => UserProfileDialog.show(context, user),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 76,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppAvatar(
                                    name: user.name,
                                    imageUrl: user.avatarUrl,
                                    size: 36,
                                    status: user.status,
                                  ),
                                  AppSpacing.gapXXs,
                                  Text(
                                    user.name.trim().isNotEmpty
                                        ? user.name
                                              .trim()
                                              .split(RegExp(r'\s+'))
                                              .first
                                        : 'User',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    loading: () => const SkeletonLoader(
                      width: double.infinity,
                      height: 80,
                    ),
                    error: (err, st) => const SizedBox.shrink(),
                  ),

                  AppSpacing.gapLg,

                  Text(
                    'TEAM DIRECTORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                  AppSpacing.gapSm,
                ],
              ),
            ),
          ),

          // Main Directory Content
          usersAsync.when(
            data: (users) {
              var filtered = users.where((u) {
                if (_selectedRoleFilter != null &&
                    u.role != _selectedRoleFilter) {
                  return false;
                }
                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  return u.name.toLowerCase().contains(q) ||
                      u.email.toLowerCase().contains(q) ||
                      u.department.toLowerCase().contains(q) ||
                      u.title.toLowerCase().contains(q);
                }
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    icon: Icons.people_outline_rounded,
                    title: 'No People Found',
                    description:
                        'No team members match your current role filter or search query.',
                  ),
                );
              }

              if (_isGridView) {
                return SliverPadding(
                  padding: AppSpacing.paddingMd,
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveLayout.isMobile(context)
                          ? 1
                          : (ResponsiveLayout.isTablet(context) ? 2 : 3),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final user = filtered[index];
                      return _buildUserGridCard(user, isDark);
                    }, childCount: filtered.length),
                  ),
                );
              }

              return SliverPadding(
                padding: AppSpacing.paddingMd,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildUserListItem(user, isDark),
                    );
                  }, childCount: filtered.length),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: AppSpacing.paddingMd,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SkeletonLoader(width: double.infinity, height: 72),
                  ),
                  childCount: 4,
                ),
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: ErrorStateWidget(
                  errorMessage: err.toString(),
                  onRetry: () => ref.invalidate(allUsersProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String label, UserRole? role) {
    final isSelected = _selectedRoleFilter == role;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedRoleFilter = role),
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

  Widget _buildUserGridCard(UserModel user, bool isDark) {
    return AppCard(
      onTap: () => UserProfileDialog.show(context, user),
      child: Row(
        children: [
          AppAvatar(
            name: user.name,
            imageUrl: user.avatarUrl,
            size: 52,
            status: user.status,
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${user.title} • ${user.department}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.gapXs,
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    RoleBadge(role: user.role),
                    StatusBadge(status: user.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(UserModel user, bool isDark) {
    return AppCard(
      onTap: () => UserProfileDialog.show(context, user),
      child: Row(
        children: [
          AppAvatar(
            name: user.name,
            imageUrl: user.avatarUrl,
            size: 40,
            status: user.status,
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${user.title} • ${user.email}',
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
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              RoleBadge(role: user.role),
              StatusBadge(status: user.status),
            ],
          ),
        ],
      ),
    );
  }
}
