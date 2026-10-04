import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/avatars/app_avatar.dart';
import '../../../meetings/domain/models/participant_model.dart';

class ParticipantTile extends StatelessWidget {
  final ParticipantModel participant;
  final bool isLocalUser;
  final bool isActiveSpeaker;
  final bool isThumbnail;
  final String
  virtualBackground; // 'none', 'blur', 'office', 'studio', 'sunset'
  final int signalBars; // 1 to 3
  final Function(String action, ParticipantModel participant)? onHostAction;

  const ParticipantTile({
    super.key,
    required this.participant,
    this.isLocalUser = false,
    this.isActiveSpeaker = false,
    this.isThumbnail = false,
    this.virtualBackground = 'none',
    this.signalBars = 3,
    this.onHostAction,
  });

  @override
  Widget build(BuildContext context) {
    final isMuted = participant.isMuted;
    final isVideoOff = participant.isVideoOff;
    final isHandRaised = participant.isHandRaised;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: isActiveSpeaker
              ? AppColors.success
              : (isHandRaised
                    ? AppColors.warning
                    : (participant.role == ParticipantRole.host
                          ? AppColors.primary
                          : const Color(0xFF2B3142))),
          width: isActiveSpeaker
              ? 2.5
              : (isHandRaised || participant.role == ParticipantRole.host
                    ? 2
                    : 1),
        ),
        boxShadow: isActiveSpeaker
            ? [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Video / Avatar Layer
          if (isVideoOff) _buildVideoOffView() else _buildVideoOnView(),

          // Virtual Background Effect Banner Badge
          if (!isVideoOff && virtualBackground != 'none')
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.warning,
                      size: 12,
                    ),
                    AppSpacing.gapWXs,
                    Text(
                      virtualBackground.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top Right Badges (Mute, Raised Hand, Signal)
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isHandRaised) ...[
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Text('✋', style: TextStyle(fontSize: 12)),
                  ),
                  AppSpacing.gapWXs,
                ],

                // Signal Bars
                _buildSignalIcon(signalBars),
                AppSpacing.gapWXs,

                // Mic State
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isMuted
                        ? AppColors.dangerContainerDark
                        : Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    size: isThumbnail ? 12 : 14,
                    color: isMuted ? AppColors.danger : AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          // Active Speaker Indicator Tag (Top Center)
          if (isActiveSpeaker && !isThumbnail)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.graphic_eq_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Speaking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Left Name Pill + Host Action Menu
          Positioned(
            left: 10,
            bottom: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '${participant.name}${isLocalUser ? ' (You)' : ''}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isThumbnail ? 11 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isThumbnail &&
                            participant.role == ParticipantRole.host) ...[
                          AppSpacing.gapWXs,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 0.8,
                              ),
                            ),
                            child: const Text(
                              'HOST',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (!isThumbnail && !isLocalUser && onHostAction != null)
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    onSelected: (action) => onHostAction!(action, participant),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'mute',
                        child: Row(
                          children: [
                            Icon(
                              isMuted
                                  ? Icons.mic_rounded
                                  : Icons.mic_off_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isMuted ? 'Ask to Unmute' : 'Mute Participant',
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'video',
                        child: Row(
                          children: [
                            Icon(
                              isVideoOff
                                  ? Icons.videocam_rounded
                                  : Icons.videocam_off_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isVideoOff ? 'Ask to Start Video' : 'Stop Video',
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(Icons.push_pin_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Pin Tile'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_remove_rounded,
                              color: AppColors.danger,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Remove Participant',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          ],
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

  Widget _buildVideoOffView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAvatar(
            name: participant.name,
            imageUrl: participant.avatarUrl,
            size: isThumbnail ? 36 : 64,
          ),
          if (!isThumbnail) ...[
            AppSpacing.gapXs,
            Text(
              'Camera Off',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoOnView() {
    return ClipRRect(
      borderRadius: AppRadius.borderRadiusLg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            participant.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Center(
              child: AppAvatar(
                name: participant.name,
                size: isThumbnail ? 36 : 64,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalIcon(int bars) {
    Color color = AppColors.success;
    if (bars <= 1) {
      color = AppColors.danger;
    } else if (bars == 2) {
      color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final active = index < bars;
          return Container(
            margin: const EdgeInsets.only(right: 2),
            width: 3,
            height: 6.0 + (index * 3.0),
            decoration: BoxDecoration(
              color: active ? color : Colors.white24,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }
}
