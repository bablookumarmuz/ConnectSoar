import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/chat_providers.dart';
import '../../../shared/widgets/avatars/app_avatar.dart';
import '../../../shared/widgets/inputs/app_search_field.dart';
import '../../../shared/widgets/loading/skeleton_loader.dart';
import '../../../shared/widgets/states/empty_state_widget.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import '../domain/models/chat_thread_model.dart';
import 'conversation_screen.dart';

class ChatInboxScreen extends ConsumerStatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  ConsumerState<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends ConsumerState<ChatInboxScreen> {
  String _searchQuery = '';
  String _activeTab = 'all'; // "all", "direct", "meeting", "unread"
  String? _selectedThreadId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);
    final threadsAsync = ref.watch(chatThreadsProvider);

    final sidebarContent = Column(
      children: [
        // Header & Search
        Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Collaborate & Chat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.gapWSm,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Live Workspace',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapSm,
              AppSearchField(
                hintText: 'Search chats, people, or messages...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              AppSpacing.gapSm,
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Threads', 'all'),
                    AppSpacing.gapXXs,
                    _buildFilterChip('Direct Messages', 'direct'),
                    AppSpacing.gapXXs,
                    _buildFilterChip('Meeting Chats', 'meeting'),
                    AppSpacing.gapXXs,
                    _buildFilterChip('Unread', 'unread'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Thread List
        Expanded(
          child: threadsAsync.when(
            data: (threads) {
              var filtered = threads.where((t) {
                if (_activeTab == 'direct' && t.type != ChatThreadType.direct) {
                  return false;
                }
                if (_activeTab == 'meeting' &&
                    t.type != ChatThreadType.meeting) {
                  return false;
                }
                if (_activeTab == 'unread' && t.unreadCount == 0) {
                  return false;
                }
                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  return t.title.toLowerCase().contains(q) ||
                      t.lastMessage.toLowerCase().contains(q) ||
                      (t.subtitle != null &&
                          t.subtitle!.toLowerCase().contains(q));
                }
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No Discussions Found',
                  description:
                      'No chat threads match your current filter or search query.',
                );
              }

              return ListView.separated(
                padding: AppSpacing.paddingSm,
                itemCount: filtered.length,
                separatorBuilder: (_, _) => AppSpacing.gapXs,
                itemBuilder: (context, index) {
                  final thread = filtered[index];
                  final isSelected = _selectedThreadId == thread.id;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedThreadId = thread.id);
                      if (isMobile) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ConversationScreen(
                              threadId: thread.id,
                              title: thread.title,
                              subtitle: thread.subtitle,
                              avatarUrl: thread.avatarUrl,
                              meetingId: thread.meetingId,
                            ),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: AppSpacing.paddingSm,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              AppAvatar(
                                name: thread.title,
                                imageUrl: thread.avatarUrl,
                                size: 44,
                              ),
                              if (thread.type == ChatThreadType.direct &&
                                  thread.isOnline)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.darkBackground
                                            : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              if (thread.type == ChatThreadType.meeting)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.video_camera_front_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          AppSpacing.gapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        thread.title,
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
                                    ),
                                    Text(
                                      DateFormatter.formatTime(
                                        thread.lastMessageTime,
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                AppSpacing.gapXXs,
                                Text(
                                  thread.lastMessage,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: thread.unreadCount > 0
                                        ? (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary)
                                        : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary),
                                    fontWeight: thread.unreadCount > 0
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (thread.unreadCount > 0) ...[
                            AppSpacing.gapSm,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${thread.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (thread.isPinned && thread.unreadCount == 0) ...[
                            AppSpacing.gapSm,
                            Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: AppSpacing.paddingMd,
              child: SkeletonLoader(width: double.infinity, height: 300),
            ),
            error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(body: sidebarContent);
    }

    // Dual-pane layout for desktop / tablet
    final selectedId = _selectedThreadId ?? 'th_live_1';
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 360, child: sidebarContent),
          const VerticalDivider(width: 1),
          Expanded(
            child: ConversationScreen(
              threadId: selectedId,
              title: selectedId == 'th_live_1'
                  ? 'ConnectSoar Architecture Sync'
                  : 'Sophia Chen',
              subtitle: selectedId == 'th_live_1'
                  ? '4 participants active'
                  : 'Head of Product Design',
              avatarUrl:
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
              meetingId: selectedId == 'th_live_1' ? 'mtg_live_1' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _activeTab == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _activeTab = value),
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
}
