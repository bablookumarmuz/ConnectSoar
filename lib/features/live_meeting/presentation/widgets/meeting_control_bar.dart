import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';

class MeetingControlBar extends StatefulWidget {
  final bool isMicMuted;
  final bool isVideoOff;
  final bool isScreenSharing;
  final bool isHandRaised;
  final bool isChatOpen;
  final bool isParticipantsOpen;
  final int unreadChatCount;
  final int participantCount;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onToggleHandRaise;
  final VoidCallback onToggleChat;
  final VoidCallback onToggleParticipants;
  final Function(String emoji) onSendReaction;
  final VoidCallback onOpenSettings;
  final VoidCallback onLeaveMeeting;

  const MeetingControlBar({
    super.key,
    required this.isMicMuted,
    required this.isVideoOff,
    required this.isScreenSharing,
    required this.isHandRaised,
    required this.isChatOpen,
    required this.isParticipantsOpen,
    required this.unreadChatCount,
    required this.participantCount,
    required this.onToggleMic,
    required this.onToggleVideo,
    required this.onToggleScreenShare,
    required this.onToggleHandRaise,
    required this.onToggleChat,
    required this.onToggleParticipants,
    required this.onSendReaction,
    required this.onOpenSettings,
    required this.onLeaveMeeting,
  });

  @override
  State<MeetingControlBar> createState() => _MeetingControlBarState();
}

class _MeetingControlBarState extends State<MeetingControlBar> {
  bool _showReactionsPopover = false;

  final List<String> _emojis = ['❤️', '👏', '👍', '🎉', '🔥', '😂', '✋', '😮'];

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Floating Emoji Reaction Bar Popover
        if (_showReactionsPopover)
          Positioned(
            bottom: 75,
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(30),
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E222E),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF32384A),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _emojis.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        widget.onSendReaction(emoji);
                        setState(() => _showReactionsPopover = false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

        // Bottom Glassmorphic Floating Control Bar
        // Bottom Glassmorphic Floating Control Bar
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 24,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF13161F).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
            border: Border.all(color: const Color(0xFF282E3E), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mic Control
                _buildControlButton(
                  icon: widget.isMicMuted
                      ? Icons.mic_off_rounded
                      : Icons.mic_rounded,
                  tooltip: widget.isMicMuted ? 'Unmute' : 'Mute',
                  isActive: widget.isMicMuted,
                  activeColor: AppColors.danger,
                  onPressed: widget.onToggleMic,
                ),
                AppSpacing.gapWSm,

                // Camera Control
                _buildControlButton(
                  icon: widget.isVideoOff
                      ? Icons.videocam_off_rounded
                      : Icons.videocam_rounded,
                  tooltip: widget.isVideoOff ? 'Start Camera' : 'Stop Camera',
                  isActive: widget.isVideoOff,
                  activeColor: AppColors.danger,
                  onPressed: widget.onToggleVideo,
                ),
                AppSpacing.gapWSm,

                // Screen Share
                _buildControlButton(
                  icon: Icons.screen_share_rounded,
                  tooltip: widget.isScreenSharing
                      ? 'Stop Sharing'
                      : 'Share Screen',
                  isActive: widget.isScreenSharing,
                  activeColor: AppColors.primary,
                  onPressed: widget.onToggleScreenShare,
                ),
                AppSpacing.gapWSm,

                // Emoji Reactions Popover Trigger
                _buildControlButton(
                  icon: Icons.add_reaction_outlined,
                  tooltip: 'Reactions',
                  isActive: _showReactionsPopover,
                  activeColor: AppColors.warning,
                  onPressed: () {
                    setState(
                      () => _showReactionsPopover = !_showReactionsPopover,
                    );
                  },
                ),

                if (!isMobile) ...[
                  AppSpacing.gapWSm,
                  // Raise Hand Button
                  _buildControlButton(
                    icon: Icons.back_hand_rounded,
                    tooltip: 'Raise Hand',
                    isActive: widget.isHandRaised,
                    activeColor: AppColors.warning,
                    onPressed: widget.onToggleHandRaise,
                  ),
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    height: 24,
                    child: VerticalDivider(color: Color(0xFF2E3446), width: 1),
                  ),
                ),

                // Chat Drawer Button with Unread Badge
                _buildControlButtonWithBadge(
                  icon: Icons.chat_bubble_outline_rounded,
                  tooltip: 'Chat',
                  isActive: widget.isChatOpen,
                  activeColor: AppColors.primary,
                  badgeCount: widget.unreadChatCount,
                  onPressed: widget.onToggleChat,
                ),
                AppSpacing.gapWSm,

                // Participants Button with Badge
                _buildControlButtonWithBadge(
                  icon: Icons.people_outline_rounded,
                  tooltip: 'Participants',
                  isActive: widget.isParticipantsOpen,
                  activeColor: AppColors.primary,
                  badgeCount: widget.participantCount,
                  onPressed: widget.onToggleParticipants,
                ),
                AppSpacing.gapWSm,

                // Settings / More Options Button
                _buildControlButton(
                  icon: Icons.tune_rounded,
                  tooltip: 'Settings & Controls',
                  isActive: false,
                  onPressed: widget.onOpenSettings,
                ),
                AppSpacing.gapWMd,

                // Red Leave Button
                AppButton(
                  text: isMobile ? '' : 'Leave',
                  icon: Icons.call_end_rounded,
                  variant: AppButtonVariant.danger,
                  onPressed: widget.onLeaveMeeting,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    Color activeColor = AppColors.primary,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? activeColor : const Color(0xFF222736),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? activeColor : const Color(0xFF343B52),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : const Color(0xFFD1D5DB),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtonWithBadge({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    Color activeColor = AppColors.primary,
    required int badgeCount,
    required VoidCallback onPressed,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildControlButton(
          icon: icon,
          tooltip: tooltip,
          isActive: isActive,
          activeColor: activeColor,
          onPressed: onPressed,
        ),
        if (badgeCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF13161F), width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
