import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/avatars/app_avatar.dart';
import '../../../../shared/widgets/buttons/app_icon_button.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../chat/domain/models/chat_message_model.dart';

class MeetingChatSheet extends StatefulWidget {
  final List<ChatMessageModel> messages;
  final VoidCallback onClose;
  final Function(String text) onSendMessage;
  final String? currentUserId;
  final double? width;

  const MeetingChatSheet({
    super.key,
    required this.messages,
    required this.onClose,
    required this.onSendMessage,
    this.currentUserId,
    this.width,
  });

  @override
  State<MeetingChatSheet> createState() => _MeetingChatSheetState();
}

class _MeetingChatSheetState extends State<MeetingChatSheet> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage(text);
    _chatController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = widget.width ?? 340.0;
    return Container(
      width: effectiveWidth,
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: const BoxDecoration(
        color: Color(0xFF13161F),
        border: Border(left: BorderSide(color: Color(0xFF262C3D), width: 1.5)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                AppSpacing.gapWSm,
                const Text(
                  'In-Meeting Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF262C3D)),

          // Messages List
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: widget.messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final msg = widget.messages[index];
                final isMe =
                    (widget.currentUserId != null &&
                        msg.senderId == widget.currentUserId) ||
                    msg.senderId == 'usr_admin_1';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      AppAvatar(
                        name: msg.senderName,
                        imageUrl: msg.senderAvatar,
                        size: 30,
                      ),
                      AppSpacing.gapWSm,
                    ],
                    Flexible(
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              msg.senderName,
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          AppSpacing.gapXXs,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AppColors.primary
                                  : const Color(0xFF1E2333),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: Radius.circular(isMe ? 12 : 2),
                                bottomRight: Radius.circular(isMe ? 2 : 12),
                              ),
                            ),
                            child: Text(
                              msg.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Quick Emoji Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xFF171B26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['👍', '❤️', '👏', '🎉', '🔥'].map((emoji) {
                return InkWell(
                  onTap: () {
                    widget.onSendMessage(emoji);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom Input Bar with dynamic keyboard insets
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: 12 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF161A25),
              border: Border(top: BorderSide(color: Color(0xFF262C3D))),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.attach_file_rounded,
                    color: Colors.white54,
                    size: 20,
                  ),
                  onPressed: () {
                    AppSnackBar.show(
                      context,
                      message: 'Attachment uploaded.',
                      type: AppSnackBarType.info,
                    );
                  },
                ),
                Expanded(
                  child: AppTextField(
                    hint: 'Send a message to everyone...',
                    controller: _chatController,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                AppSpacing.gapWSm,
                AppIconButton(
                  icon: Icons.send_rounded,
                  variant: AppIconButtonVariant.primary,
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
