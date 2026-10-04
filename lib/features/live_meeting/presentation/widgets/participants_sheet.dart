import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/avatars/app_avatar.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/inputs/app_search_field.dart';
import '../../../meetings/domain/models/participant_model.dart';

class ParticipantsSheet extends StatefulWidget {
  final List<ParticipantModel> participants;
  final bool isHost;
  final VoidCallback onClose;
  final Function(String action, ParticipantModel participant)? onHostAction;
  final VoidCallback? onMuteAll;
  final VoidCallback? onLowerAllHands;
  final Function(String email)? onInvite;
  final double? width;
  final String? currentUserId;
  final bool isMobileSheet;

  const ParticipantsSheet({
    super.key,
    required this.participants,
    this.isHost = true,
    required this.onClose,
    this.onHostAction,
    this.onMuteAll,
    this.onLowerAllHands,
    this.onInvite,
    this.width,
    this.currentUserId,
    this.isMobileSheet = false,
  });

  @override
  State<ParticipantsSheet> createState() => _ParticipantsSheetState();
}

class _ParticipantsSheetState extends State<ParticipantsSheet> {
  String _searchQuery = '';

  void _showInviteDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B202D),
        title: const Text(
          'Invite Participant',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter participant email',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.of(ctx).pop();
                widget.onInvite?.call(email);
              }
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.participants.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final effectiveWidth = widget.width ?? 340.0;

    return Container(
      width: effectiveWidth,
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: const Color(0xFF13161F),
        border: widget.isMobileSheet
            ? null
            : const Border(
                left: BorderSide(color: Color(0xFF262C3D), width: 1.5),
              ),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                AppSpacing.gapWSm,
                Expanded(
                  child: Text(
                    'Participants (${widget.participants.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.isHost && widget.onInvite != null)
                  IconButton(
                    icon: const Icon(
                      Icons.person_add_rounded,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                    tooltip: 'Invite Participant',
                    onPressed: () => _showInviteDialog(context),
                  ),
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

          // Host Quick Action Toolbar
          if (widget.isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF181C28),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Mute All',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.sm,
                      icon: Icons.mic_off_rounded,
                      onPressed: () {
                        widget.onMuteAll?.call();
                        AppSnackBar.show(
                          context,
                          message: 'All participants muted.',
                          type: AppSnackBarType.info,
                        );
                      },
                    ),
                  ),
                  AppSpacing.gapWSm,
                  Expanded(
                    child: AppButton(
                      text: 'Lower Hands',
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.sm,
                      icon: Icons.front_hand_rounded,
                      onPressed: () {
                        widget.onLowerAllHands?.call();
                        AppSnackBar.show(
                          context,
                          message: 'All hands lowered.',
                          type: AppSnackBarType.info,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(12),
            child: AppSearchField(
              hint: 'Search participants...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Participants List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final p = filtered[index];
                final isLocal =
                    (widget.currentUserId != null &&
                        p.userId == widget.currentUserId) ||
                    p.userId == 'usr_admin_1';

                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B202D),
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(color: const Color(0xFF282F42)),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(name: p.name, imageUrl: p.avatarUrl, size: 36),
                      AppSpacing.gapWSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${p.name}${isLocal ? ' (You)' : ''}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (p.role == ParticipantRole.host) ...[
                                  AppSpacing.gapWXs,
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.25,
                                      ),
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
                            AppSpacing.gapXXs,
                            Row(
                              children: [
                                if (p.isHandRaised)
                                  const Text(
                                    '✋ Raised Hand  • ',
                                    style: TextStyle(
                                      color: AppColors.warning,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  p.isVideoOff ? 'Video Off' : 'Video Active',
                                  style: TextStyle(
                                    color: p.isVideoOff
                                        ? Colors.grey
                                        : AppColors.success,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Indicators & Controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            p.isMuted
                                ? Icons.mic_off_rounded
                                : Icons.mic_rounded,
                            size: 18,
                            color: p.isMuted
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                          if (widget.isHost && !isLocal)
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.white54,
                                size: 18,
                              ),
                              onSelected: (act) =>
                                  widget.onHostAction?.call(act, p),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'mute',
                                  child: Text(
                                    p.isMuted ? 'Unmute Mic' : 'Mute Mic',
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'video',
                                  child: Text(
                                    p.isVideoOff
                                        ? 'Turn On Camera'
                                        : 'Turn Off Camera',
                                  ),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text(
                                    'Remove from Call',
                                    style: TextStyle(color: AppColors.danger),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
