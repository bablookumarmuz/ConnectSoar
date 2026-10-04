import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_formatter.dart';
import '../../users/providers/user_providers.dart';
import '../providers/chat_providers.dart';
import '../../../shared/widgets/avatars/app_avatar.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_search_field.dart';
import '../../../shared/widgets/loading/app_spinner.dart';
import '../../../shared/widgets/states/empty_state_widget.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import '../domain/models/chat_message_model.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String threadId;
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final String? meetingId;

  const ConversationScreen({
    super.key,
    required this.threadId,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.meetingId,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false;
  String _searchQuery = '';

  // Reply state
  ChatMessageModel? _replyingTo;

  // Attachment state
  String? _attachedFileName;
  String? _attachedFileSize;

  // Pinned bar expansion state
  bool _showPinnedBanner = true;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(
    String currentUserId,
    String currentUserName,
    String currentUserAvatar,
  ) {
    final text = _messageController.text.trim();
    if (text.isEmpty && _attachedFileName == null) return;

    final mentions = <String>[];
    if (text.contains('@Sophia Chen')) mentions.add('Sophia Chen');
    if (text.contains('@Marcus Brody')) mentions.add('Marcus Brody');
    if (text.contains('@Alex Vance')) mentions.add('Alex Vance');
    if (text.contains('@Elena Rostova')) mentions.add('Elena Rostova');

    ref
        .read(activeChatNotifierProvider(widget.threadId).notifier)
        .sendMessage(
          senderId: currentUserId,
          senderName: currentUserName,
          senderAvatar: currentUserAvatar,
          message: text.isNotEmpty ? text : 'Shared attachment',
          type: _attachedFileName != null ? MessageType.file : MessageType.text,
          fileName: _attachedFileName,
          fileSize: _attachedFileSize,
          fileUrl: _attachedFileName != null
              ? 'https://connectsoar.io/docs/$_attachedFileName'
              : null,
          replyToMessageId: _replyingTo?.id,
          replyToSenderName: _replyingTo?.senderName,
          replyToMessageText: _replyingTo?.message,
          mentions: mentions,
        );

    _messageController.clear();
    setState(() {
      _replyingTo = null;
      _attachedFileName = null;
      _attachedFileSize = null;
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _simulateAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: AppSpacing.paddingMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attach Document or Image',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            AppSpacing.gapMd,
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_rounded,
                color: AppColors.danger,
              ),
              title: const Text('ConnectSoar_Architecture_v2.pdf'),
              subtitle: const Text('PDF Document • 4.2 MB'),
              onTap: () {
                setState(() {
                  _attachedFileName = 'ConnectSoar_Architecture_v2.pdf';
                  _attachedFileSize = '4.2 MB';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.image_rounded,
                color: AppColors.primary,
              ),
              title: const Text('UI_Mockup_DarkTheme.png'),
              subtitle: const Text('PNG Image • 1.8 MB'),
              onTap: () {
                setState(() {
                  _attachedFileName = 'UI_Mockup_DarkTheme.png';
                  _attachedFileSize = '1.8 MB';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.description_rounded,
                color: AppColors.info,
              ),
              title: const Text('AuditLog_Specs_v1.docx'),
              subtitle: const Text('Word Document • 850 KB'),
              onTap: () {
                setState(() {
                  _attachedFileName = 'AuditLog_Specs_v1.docx';
                  _attachedFileSize = '850 KB';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserAsync = ref.watch(currentUserProvider);
    final messagesAsync = ref.watch(
      activeChatNotifierProvider(widget.threadId),
    );

    final currentUserId = currentUserAsync.maybeWhen(
      data: (u) => u.id,
      orElse: () => 'usr_admin_1',
    );
    final currentUserName = currentUserAsync.maybeWhen(
      data: (u) => u.name,
      orElse: () => 'Alex Vance',
    );
    final currentUserAvatar = currentUserAsync.maybeWhen(
      data: (u) => u.avatarUrl,
      orElse: () => '',
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        title: Row(
          children: [
            AppAvatar(name: widget.title, imageUrl: widget.avatarUrl, size: 36),
            AppSpacing.gapSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            tooltip: 'Search Messages',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
          ),
          IconButton(
            icon: Icon(
              _showPinnedBanner
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined,
              color: _showPinnedBanner ? AppColors.primary : null,
            ),
            tooltip: 'Toggle Pinned Messages Banner',
            onPressed: () =>
                setState(() => _showPinnedBanner = !_showPinnedBanner),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Messages Sub-bar
          if (_isSearching)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
              child: AppSearchField(
                hintText: 'Search in conversation...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

          // Pinned Message UI Banner
          messagesAsync.when(
            data: (messages) {
              final pinned = messages.where((m) => m.isPinned).toList();
              if (!_showPinnedBanner || pinned.isEmpty) {
                return const SizedBox.shrink();
              }

              final firstPinned = pinned.first;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.push_pin_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    AppSpacing.gapSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PINNED MESSAGE (${pinned.length})',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${firstPinned.senderName}: ${firstPinned.message}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, st) => const SizedBox.shrink(),
          ),

          // Messages Timeline
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                var filtered = messages;
                if (_searchQuery.trim().isNotEmpty) {
                  filtered = messages
                      .where(
                        (m) =>
                            m.message.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            m.senderName.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                      )
                      .toList();
                }

                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.chat_outlined,
                    title: 'No Messages Yet',
                    description:
                        'Start the conversation by sending a message below!',
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: AppSpacing.paddingMd,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final msg = filtered[index];
                    if (msg.type == MessageType.system) {
                      return _buildSystemMessage(msg, isDark);
                    }
                    final isMe = msg.senderId == currentUserId;
                    return _buildMessageBubble(
                      msg,
                      isMe,
                      currentUserId,
                      isDark,
                    );
                  },
                );
              },
              loading: () => const Center(child: AppSpinner()),
              error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
            ),
          ),

          // Reply UI Preview Banner
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceElevated,
                border: const Border(
                  top: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.reply_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Replying to ${_replyingTo!.senderName}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          _replyingTo!.message,
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
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    onPressed: () => setState(() => _replyingTo = null),
                  ),
                ],
              ),
            ),

          // Attachment UI Preview Banner
          if (_attachedFileName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                border: const Border(top: BorderSide(color: AppColors.primary)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _attachedFileName!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          _attachedFileSize ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    onPressed: () => setState(() {
                      _attachedFileName = null;
                      _attachedFileSize = null;
                    }),
                  ),
                ],
              ),
            ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Attach File',
                    onPressed: _simulateAttachmentPicker,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message... (use @name to mention)',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(
                        currentUserId,
                        currentUserName,
                        currentUserAvatar,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.alternate_email_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Mention Someone',
                    onPressed: () {
                      _messageController.text += ' @Sophia Chen ';
                      _messageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _messageController.text.length),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: () => _sendMessage(
                      currentUserId,
                      currentUserName,
                      currentUserAvatar,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(ChatMessageModel msg, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceElevated
              : AppColors.lightSurfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.message,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessageModel msg,
    bool isMe,
    String currentUserId,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            AppAvatar(
              name: msg.senderName,
              imageUrl: msg.senderAvatar,
              size: 32,
            ),
            AppSpacing.gapSm,
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      msg.senderName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ),

                // Main Bubble
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkSurfaceElevated
                              : AppColors.lightSurfaceElevated),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isMe ? 14 : 2),
                      bottomRight: Radius.circular(isMe ? 2 : 14),
                    ),
                    border: isMe
                        ? null
                        : Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reply parent quote box
                      if (msg.replyToSenderName != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.black.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.replyToSenderName!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isMe
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                              Text(
                                msg.replyToMessageText ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isMe
                                      ? Colors.white70
                                      : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                      // File Attachment UI
                      if (msg.type == MessageType.file &&
                          msg.fileName != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                msg.fileName!.endsWith('.pdf')
                                    ? Icons.picture_as_pdf_rounded
                                    : Icons.insert_drive_file_rounded,
                                color: isMe ? Colors.white : AppColors.primary,
                                size: 28,
                              ),
                              AppSpacing.gapSm,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.fileName!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isMe
                                          ? Colors.white
                                          : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.lightTextPrimary),
                                    ),
                                  ),
                                  Text(
                                    msg.fileSize ?? '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white70
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.gapMd,
                              Icon(
                                Icons.download_rounded,
                                size: 18,
                                color: isMe ? Colors.white : AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.gapXs,
                      ],

                      // Message Body (with mention highlights)
                      _buildRichMessageText(msg.message, isMe, isDark),

                      AppSpacing.gapXXs,

                      // Time & Pin indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormatter.formatTime(msg.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe
                                  ? Colors.white70
                                  : (isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted),
                            ),
                          ),
                          if (msg.isPinned) ...[
                            AppSpacing.gapXXs,
                            Icon(
                              Icons.push_pin_rounded,
                              size: 10,
                              color: isMe ? Colors.white70 : AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Reaction Pills UI
                if (msg.reactions.isNotEmpty) ...[
                  AppSpacing.gapXXs,
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: msg.reactions.entries.map((entry) {
                      final emoji = entry.key;
                      final userIds = entry.value;
                      final hasReacted = userIds.contains(currentUserId);

                      return InkWell(
                        onTap: () {
                          ref
                              .read(
                                activeChatNotifierProvider(
                                  widget.threadId,
                                ).notifier,
                              )
                              .toggleReaction(msg.id, emoji, currentUserId);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: hasReacted
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : (isDark
                                      ? AppColors.darkSurfaceElevated
                                      : AppColors.lightSurfaceElevated),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasReacted
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$emoji ${userIds.length}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Action Row (Reply, React, Pin)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _replyingTo = msg),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    _buildReactionPickerMenu(msg.id, currentUserId),
                    InkWell(
                      onTap: () {
                        ref
                            .read(
                              activeChatNotifierProvider(
                                widget.threadId,
                              ).notifier,
                            )
                            .togglePinMessage(msg.id);
                        AppSnackBar.show(
                          context,
                          message: msg.isPinned
                              ? 'Message unpinned'
                              : 'Message pinned to thread',
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          msg.isPinned ? 'Unpin' : 'Pin',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionPickerMenu(String messageId, String currentUserId) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      tooltip: 'Add Reaction',
      icon: const Icon(
        Icons.add_reaction_outlined,
        size: 14,
        color: AppColors.primary,
      ),
      onSelected: (emoji) {
        ref
            .read(activeChatNotifierProvider(widget.threadId).notifier)
            .toggleReaction(messageId, emoji, currentUserId);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: '👍', child: Text('👍 Thumbs Up')),
        const PopupMenuItem(value: '❤️', child: Text('❤️ Love')),
        const PopupMenuItem(value: '🔥', child: Text('🔥 Fire')),
        const PopupMenuItem(value: '🚀', child: Text('🚀 Rocket')),
        const PopupMenuItem(value: '😂', child: Text('😂 Joy')),
      ],
    );
  }

  Widget _buildRichMessageText(String text, bool isMe, bool isDark) {
    if (!text.contains('@')) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          color: isMe
              ? Colors.white
              : (isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary),
        ),
      );
    }

    final words = text.split(' ');
    final spans = <InlineSpan>[];

    for (final word in words) {
      if (word.startsWith('@')) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                word,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        );
        spans.add(const TextSpan(text: ' '));
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: TextStyle(
              fontSize: 13.5,
              color: isMe
                  ? Colors.white
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
            ),
          ),
        );
      }
    }

    return Text.rich(TextSpan(children: spans));
  }
}
