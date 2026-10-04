import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../services/media/microphone_controller.dart';
import '../../../services/remote/auth_storage.dart';
import '../../../services/remote/realtime_signaling_service.dart';
import '../../../shared/widgets/badges/live_pulse_indicator.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_bottom_sheet.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import '../../chat/domain/models/chat_message_model.dart';
import '../../chat/providers/chat_providers.dart';
import '../../meetings/domain/models/participant_model.dart';
import '../../meetings/providers/meeting_providers.dart';
import '../../users/providers/user_providers.dart';

import 'widgets/connection_quality_dialog.dart';
import 'widgets/end_meeting_dialog.dart';
import 'widgets/floating_emoji_reaction.dart';
import 'widgets/floating_pip_tile.dart';
import 'widgets/meeting_chat_sheet.dart';
import 'widgets/meeting_control_bar.dart';
import 'widgets/meeting_settings_dialog.dart';
import 'widgets/participant_tile.dart';
import 'widgets/participants_sheet.dart';
import 'widgets/post_meeting_screen.dart';

enum MeetingLayoutMode { grid, spotlight, screenShare, largeGroup }

class LiveMeetingScreen extends ConsumerStatefulWidget {
  final String meetingId;

  const LiveMeetingScreen({super.key, required this.meetingId});

  @override
  ConsumerState<LiveMeetingScreen> createState() => _LiveMeetingScreenState();
}

class _LiveMeetingScreenState extends ConsumerState<LiveMeetingScreen> {
  // Local User Hardware & Control Controllers
  final MicrophoneController _micController = MicrophoneController();

  // Local User States
  bool _isMicMuted = false;
  bool _isVideoOff = false;
  bool _isHandRaised = false;
  bool _isScreenSharing = false;
  bool _isChatOpen = false;
  bool _isParticipantsOpen = false;
  bool _showPipTile = true;
  final bool _isHostPerspective = true;
  bool _simulatePoorNetwork = false;
  String _activeVirtualBackground = 'none';

  // Room Layout State
  MeetingLayoutMode _layoutMode = MeetingLayoutMode.grid;

  // Active Speaker State
  String _activeSpeakerId = 'usr_admin_1';

  // Timer Counter
  late Timer _meetingTimer;
  int _elapsedSeconds = 1458; // 24m 18s

  // Floating Emoji Reactions List
  final List<FloatingReactionItem> _activeReactions = [];

  // Participants & Messages List
  late List<ParticipantModel> _participants;

  // Large Group Mock Participants (for 8+ participants view)
  late List<ParticipantModel> _largeGroupParticipants;

  // Realtime Signaling & Participant State
  RealtimeSignalingService? _signalingService;
  StreamSubscription? _participantsSubscription;

  @override
  void initState() {
    super.initState();
    _participants = [
      const ParticipantModel(
        id: 'p_1',
        userId: 'usr_admin_1',
        name: 'Alex Vance (Host)',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        role: ParticipantRole.host,
      ),
      const ParticipantModel(
        id: 'p_2',
        userId: 'usr_mgr_1',
        name: 'Sophia Chen',
        avatarUrl:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        role: ParticipantRole.coHost,
      ),
      const ParticipantModel(
        id: 'p_3',
        userId: 'usr_emp_1',
        name: 'Marcus Brody',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        role: ParticipantRole.attendee,
      ),
      const ParticipantModel(
        id: 'p_4',
        userId: 'usr_emp_2',
        name: 'Elena Rostova',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        role: ParticipantRole.attendee,
        isMuted: true,
      ),
    ];

    _largeGroupParticipants = [
      ..._participants,
      const ParticipantModel(
        id: 'p_5',
        userId: 'usr_emp_3',
        name: 'David Kim',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        role: ParticipantRole.attendee,
      ),
      const ParticipantModel(
        id: 'p_6',
        userId: 'usr_emp_4',
        name: 'Priya Sharma',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        role: ParticipantRole.attendee,
      ),
      const ParticipantModel(
        id: 'p_7',
        userId: 'usr_emp_5',
        name: 'Carlos Mendez',
        avatarUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
        role: ParticipantRole.attendee,
      ),
      const ParticipantModel(
        id: 'p_8',
        userId: 'usr_emp_6',
        name: 'Sarah Connor',
        avatarUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150',
        role: ParticipantRole.attendee,
      ),
    ];

    // Start Live Clock Ticker
    _meetingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRealtimeSignaling();
    });
  }

  void _initRealtimeSignaling() async {
    final config = ref.read(appConfigProvider);
    if (!config.useMockData) {
      try {
        final remoteParts = await ref
            .read(participantRepositoryProvider)
            .getParticipants(widget.meetingId);
        if (remoteParts.isNotEmpty && mounted) {
          setState(() {
            _participants = remoteParts;
          });
        }
      } catch (_) {}

      _signalingService = RealtimeSignalingService(config);
      final authStorage = AuthStorage();
      final token = await authStorage.getToken();
      if (token != null) {
        final joined = await _signalingService!.connectAndJoin(
          meetingId: widget.meetingId,
          authToken: token,
        );
        if (joined && mounted) {
          _participantsSubscription = _signalingService!.participantsStream
              .listen((realtimeParts) {
                if (mounted) {
                  setState(() {
                    _participants = realtimeParts
                        .map(
                          (p) => ParticipantModel(
                            id: 'p_${p.userId}',
                            userId: p.userId,
                            name: p.name,
                            avatarUrl: p.avatarUrl,
                            role: ParticipantRole.attendee,
                            isMuted: p.isMuted,
                            isVideoOff: p.isVideoOff,
                          ),
                        )
                        .toList();
                  });
                }
              });
        }
      }
    }
  }

  @override
  void dispose() {
    _meetingTimer.cancel();
    _micController.dispose();
    _participantsSubscription?.cancel();
    _signalingService?.leaveMeeting(widget.meetingId);
    _signalingService?.dispose();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    final mStr = mins.toString().padLeft(2, '0');
    final sStr = secs.toString().padLeft(2, '0');
    return hrs > 0 ? '$hrs:$mStr:$sStr' : '$mStr:$sStr';
  }

  void _triggerReaction(String emoji) {
    final newReaction = FloatingReactionItem(
      id: 'react_${DateTime.now().millisecondsSinceEpoch}',
      emoji: emoji,
      senderName: 'Alex Vance',
      startXPercent: 0.3 + (0.4 * (DateTime.now().millisecond / 1000)),
    );

    setState(() => _activeReactions.add(newReaction));

    // Remove reaction after animation finishes
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(
          () => _activeReactions.removeWhere((r) => r.id == newReaction.id),
        );
      }
    });
  }

  Future<void> _toggleMic() async {
    if (_isMicMuted) {
      final success = await _micController.startMicrophone();
      if (!success) {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: 'Microphone permission denied or hardware unavailable.',
            type: AppSnackBarType.error,
          );
        }
        return;
      }
      if (mounted) {
        setState(() => _isMicMuted = false);
        _signalingService?.toggleMedia(
          meetingId: widget.meetingId,
          isMuted: _isMicMuted,
          isVideoOff: _isVideoOff,
        );
        AppSnackBar.show(
          context,
          message: 'Microphone Active',
          type: AppSnackBarType.success,
        );
      }
    } else {
      await _micController.stopMicrophone();
      if (mounted) {
        setState(() => _isMicMuted = true);
        _signalingService?.toggleMedia(
          meetingId: widget.meetingId,
          isMuted: _isMicMuted,
          isVideoOff: _isVideoOff,
        );
        AppSnackBar.show(
          context,
          message: 'Microphone Muted',
          type: AppSnackBarType.warning,
        );
      }
    }
  }

  void _toggleCamera() {
    setState(() => _isVideoOff = !_isVideoOff);
    _signalingService?.toggleMedia(
      meetingId: widget.meetingId,
      isMuted: _isMicMuted,
      isVideoOff: _isVideoOff,
    );
    AppSnackBar.show(
      context,
      message: _isVideoOff ? 'Camera Turned Off' : 'Camera Active',
      type: _isVideoOff ? AppSnackBarType.warning : AppSnackBarType.success,
    );
  }

  void _toggleHandRaise() {
    setState(() => _isHandRaised = !_isHandRaised);
    AppSnackBar.show(
      context,
      message: _isHandRaised ? 'Hand Raised ✋' : 'Hand Lowered',
      type: AppSnackBarType.info,
    );
  }

  void _toggleScreenShare() {
    setState(() {
      _isScreenSharing = !_isScreenSharing;
      _layoutMode = _isScreenSharing
          ? MeetingLayoutMode.screenShare
          : MeetingLayoutMode.grid;
    });
    AppSnackBar.show(
      context,
      message: _isScreenSharing
          ? 'Screen Sharing Started 🖥️'
          : 'Screen Sharing Stopped',
      type: _isScreenSharing ? AppSnackBarType.success : AppSnackBarType.info,
    );
  }

  void _sendMessage(String text) {
    final user = ref.read(currentUserProvider).value;
    final senderId = user?.id ?? 'usr_admin_1';
    final senderName = user?.name ?? 'Alex Vance';
    final senderAvatar = user?.avatarUrl ?? '';

    final repo = ref.read(chatRepositoryProvider);
    repo.sendMessage(
      threadId: widget.meetingId,
      meetingId: widget.meetingId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: text,
    );
    ref.invalidate(chatMessagesProvider(widget.meetingId));
  }

  void _inviteParticipant(String email) async {
    try {
      await ref
          .read(participantRepositoryProvider)
          .inviteParticipant(widget.meetingId, email: email, role: 'attendee');
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Invite sent to $email successfully!',
          type: AppSnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Failed to invite participant: $e',
          type: AppSnackBarType.error,
        );
      }
    }
  }

  void _handleHostAction(String action, ParticipantModel participant) async {
    if (action == 'mute') {
      setState(() {
        final idx = _participants.indexWhere((p) => p.id == participant.id);
        if (idx != -1) {
          _participants[idx] = _participants[idx].copyWith(
            isMuted: !_participants[idx].isMuted,
          );
        }
      });
      AppSnackBar.show(
        context,
        message: '${participant.name} mic status updated.',
        type: AppSnackBarType.info,
      );
    } else if (action == 'remove') {
      try {
        await ref
            .read(participantRepositoryProvider)
            .removeParticipant(widget.meetingId, participant.id);
      } catch (_) {}
      setState(() {
        _participants.removeWhere((p) => p.id == participant.id);
      });
      if (mounted) {
        AppSnackBar.show(
          context,
          message: '${participant.name} was removed from call.',
          type: AppSnackBarType.warning,
        );
      }
    }
  }

  void _handleLeaveMeeting() async {
    final choice = await EndMeetingDialog.show(
      context,
      isHost: _isHostPerspective,
    );
    if (choice != null && mounted) {
      if (choice == EndMeetingChoice.endForAll) {
        try {
          await ref
              .read(meetingRepositoryProvider)
              .endMeeting(widget.meetingId);
        } catch (_) {}
      } else {
        try {
          await ref
              .read(meetingRepositoryProvider)
              .leaveMeeting(widget.meetingId);
        } catch (_) {}
      }
      if (mounted) {
        ref.invalidate(meetingsNotifierProvider);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PostMeetingScreen(
              meetingId: widget.meetingId,
              meetingTitle: 'Meeting Ended',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final meetingsAsync = ref.watch(meetingsListProvider);
    final messagesAsync = ref.watch(chatMessagesProvider(widget.meetingId));

    final currentParticipants = _layoutMode == MeetingLayoutMode.largeGroup
        ? _largeGroupParticipants
        : _participants;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleLeaveMeeting();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0D13),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top Header Chrome
                  _buildTopHeaderBar(context, meetingsAsync),

                  // Poor Network Warning Banner (State I)
                  if (_simulatePoorNetwork) _buildPoorNetworkBanner(),

                  // Main Stage Video Grid Area
                  Expanded(
                    child: Row(
                      children: [
                        // Video Stage Viewport
                        Expanded(
                          child: _buildMainVideoStage(
                            currentParticipants,
                            isMobile,
                          ),
                        ),

                        // Desktop / Tablet Side Panels
                        if (!isMobile && _isChatOpen)
                          MeetingChatSheet(
                            messages: messagesAsync.value ?? [],
                            currentUserId: ref
                                .watch(currentUserProvider)
                                .value
                                ?.id,
                            onClose: () => setState(() => _isChatOpen = false),
                            onSendMessage: _sendMessage,
                          ),
                        if (!isMobile && _isParticipantsOpen)
                          ParticipantsSheet(
                            participants: currentParticipants,
                            isHost: _isHostPerspective,
                            currentUserId: ref
                                .watch(currentUserProvider)
                                .value
                                ?.id,
                            onClose: () =>
                                setState(() => _isParticipantsOpen = false),
                            onHostAction: _handleHostAction,
                            onInvite: _inviteParticipant,
                            onMuteAll: () {
                              setState(() {
                                _participants = _participants
                                    .map((p) => p.copyWith(isMuted: true))
                                    .toList();
                              });
                            },
                            onLowerAllHands: () {
                              setState(() {
                                _participants = _participants
                                    .map((p) => p.copyWith(isHandRaised: false))
                                    .toList();
                              });
                            },
                          ),
                      ],
                    ),
                  ),

                  // Bottom Control Toolbar Padding Anchor
                  const SizedBox(height: 76),
                ],
              ),

              // Floating Local User Picture-in-Picture Tile
              if (_showPipTile &&
                  !_isVideoOff &&
                  _layoutMode != MeetingLayoutMode.spotlight)
                FloatingPipTile(
                  name: 'Alex Vance',
                  avatarUrl:
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                  isVideoOff: _isVideoOff,
                  isMicMuted: _isMicMuted,
                  onToggleVideo: _toggleCamera,
                  onToggleMic: _toggleMic,
                  onClose: () => setState(() => _showPipTile = false),
                ),

              // Floating Emoji Overlay Animation Layer
              FloatingEmojiOverlay(reactions: _activeReactions),

              // Fixed Bottom Floating Control Toolbar
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: MeetingControlBar(
                    isMicMuted: _isMicMuted,
                    isVideoOff: _isVideoOff,
                    isScreenSharing: _isScreenSharing,
                    isHandRaised: _isHandRaised,
                    isChatOpen: _isChatOpen,
                    isParticipantsOpen: _isParticipantsOpen,
                    unreadChatCount: (messagesAsync.value?.length ?? 0),
                    participantCount: currentParticipants.length,
                    onToggleMic: _toggleMic,
                    onToggleVideo: _toggleCamera,
                    onToggleScreenShare: _toggleScreenShare,
                    onToggleHandRaise: _toggleHandRaise,
                    onToggleChat: () {
                      if (isMobile) {
                        _showMobileChatSheet(
                          context,
                          messagesAsync.value ?? [],
                        );
                      } else {
                        setState(() {
                          _isChatOpen = !_isChatOpen;
                          if (_isChatOpen) _isParticipantsOpen = false;
                        });
                      }
                    },
                    onToggleParticipants: () {
                      if (isMobile) {
                        _showMobileParticipantsSheet(
                          context,
                          currentParticipants,
                        );
                      } else {
                        setState(() {
                          _isParticipantsOpen = !_isParticipantsOpen;
                          if (_isParticipantsOpen) _isChatOpen = false;
                        });
                      }
                    },
                    onSendReaction: _triggerReaction,
                    onOpenSettings: () {
                      MeetingSettingsDialog.show(
                        context,
                        isHost: _isHostPerspective,
                        activeBackground: _activeVirtualBackground,
                        onBackgroundChanged: (bg) =>
                            setState(() => _activeVirtualBackground = bg),
                      );
                    },
                    onLeaveMeeting: _handleLeaveMeeting,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeaderBar(
    BuildContext context,
    AsyncValue<dynamic> meetingsAsync,
  ) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF10131B),
        border: Border(bottom: BorderSide(color: Color(0xFF222736))),
      ),
      child: Row(
        children: [
          const LivePulseIndicator(size: 10),
          AppSpacing.gapWSm,
          Expanded(
            child: meetingsAsync.when(
              data: (meetings) {
                final title = (meetings is List && meetings.isNotEmpty)
                    ? (meetings.first as dynamic).title as String
                    : 'Live Meeting Room';
                return Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
              loading: () => const Text(
                'Loading room...',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
            ),
          ),
          AppSpacing.gapWSm,
          // Clock Ticker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2C),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _formatTimer(_elapsedSeconds),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppSpacing.gapWSm,

          // Layout Switcher Popup Menu
          PopupMenuButton<MeetingLayoutMode>(
            tooltip: 'Change Stage Layout',
            icon: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1D2332),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF2E364A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  if (!isMobile) ...[
                    AppSpacing.gapWXs,
                    Text(
                      _layoutMode.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            onSelected: (mode) {
              setState(() {
                _layoutMode = mode;
                if (mode == MeetingLayoutMode.screenShare) {
                  _isScreenSharing = true;
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: MeetingLayoutMode.grid,
                child: Text('Grid View'),
              ),
              const PopupMenuItem(
                value: MeetingLayoutMode.spotlight,
                child: Text('Active Speaker Mode'),
              ),
              const PopupMenuItem(
                value: MeetingLayoutMode.screenShare,
                child: Text('Screen Sharing Mode'),
              ),
              const PopupMenuItem(
                value: MeetingLayoutMode.largeGroup,
                child: Text('Large Count (8+ Participants)'),
              ),
            ],
          ),
          AppSpacing.gapWSm,

          // Connection Quality Diagnostic Pill
          GestureDetector(
            onTap: () {
              ConnectionQualityDialog.show(
                context,
                latency: _simulatePoorNetwork ? 240 : 22,
                loss: _simulatePoorNetwork ? 4.2 : 0.1,
                state: _simulatePoorNetwork ? 'Poor' : 'Excellent',
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: _simulatePoorNetwork
                    ? AppColors.warning.withValues(alpha: 0.2)
                    : AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _simulatePoorNetwork
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _simulatePoorNetwork
                        ? Icons.wifi_off_rounded
                        : Icons.wifi_rounded,
                    color: _simulatePoorNetwork
                        ? AppColors.warning
                        : AppColors.success,
                    size: 13,
                  ),
                  if (!isMobile) ...[
                    AppSpacing.gapWXs,
                    Text(
                      _simulatePoorNetwork ? '240 ms' : '22 ms',
                      style: TextStyle(
                        color: _simulatePoorNetwork
                            ? AppColors.warning
                            : AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          AppSpacing.gapWSm,

          // Toggle Network Quality Simulation Action
          IconButton(
            icon: Icon(
              Icons.bolt_rounded,
              color: _simulatePoorNetwork ? AppColors.warning : Colors.grey,
              size: 20,
            ),
            tooltip: 'Simulate Network Lag',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {
              setState(() => _simulatePoorNetwork = !_simulatePoorNetwork);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPoorNetworkBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: AppColors.warning.withValues(alpha: 0.9),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.black,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Poor connection. Scaling video to preserve audio.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
            ),
            onPressed: () => ConnectionQualityDialog.show(
              context,
              latency: 240,
              loss: 4.2,
              state: 'Poor',
            ),
            child: const Text(
              'Diagnostics',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainVideoStage(
    List<ParticipantModel> participants,
    bool isMobile,
  ) {
    return Padding(
      padding: AppSpacing.paddingSm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (_layoutMode == MeetingLayoutMode.screenShare) {
            return _buildScreenSharingLayout(participants);
          }

          if (_layoutMode == MeetingLayoutMode.spotlight) {
            return _buildSpotlightSpeakerLayout(participants);
          }

          // Default Adaptive Grid View
          final int count = participants.length;
          int crossAxisCount = 2;
          if (isMobile) {
            crossAxisCount = count == 1 ? 1 : 2;
          } else {
            if (count == 1) {
              crossAxisCount = 1;
            } else if (count <= 4) {
              crossAxisCount = 2;
            } else if (count <= 9) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 4;
            }
          }

          double childAspectRatio = 1.4;
          if (constraints.maxHeight > 0 && constraints.maxWidth > 0) {
            final rows = (count / crossAxisCount).ceil();
            final itemWidth =
                (constraints.maxWidth - ((crossAxisCount - 1) * 10)) /
                crossAxisCount;
            final itemHeight =
                (constraints.maxHeight - ((rows - 1) * 10)) / rows;
            childAspectRatio = (itemWidth / itemHeight).clamp(0.7, 2.2);
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: count,
            itemBuilder: (context, index) {
              final p = participants[index];
              final isLocal = p.userId == 'usr_admin_1';
              final isActive = p.userId == _activeSpeakerId;

              return ParticipantTile(
                participant: isLocal
                    ? p.copyWith(
                        isMuted: _isMicMuted,
                        isVideoOff: _isVideoOff,
                        isHandRaised: _isHandRaised,
                      )
                    : p,
                isLocalUser: isLocal,
                isActiveSpeaker: isActive,
                virtualBackground: isLocal ? _activeVirtualBackground : 'none',
                onHostAction: _handleHostAction,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSpotlightSpeakerLayout(List<ParticipantModel> participants) {
    if (participants.isEmpty) {
      return const Center(
        child: Text(
          'Waiting for participants to join...',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    final activeSpeaker = participants.firstWhere(
      (p) => p.userId == _activeSpeakerId,
      orElse: () => participants.first,
    );

    return Column(
      children: [
        // Giant Spotlight Video
        Expanded(
          flex: 4,
          child: ParticipantTile(
            participant: activeSpeaker,
            isLocalUser: activeSpeaker.userId == 'usr_admin_1',
            isActiveSpeaker: true,
            onHostAction: _handleHostAction,
          ),
        ),
        AppSpacing.gapSm,
        // Bottom Participant Strip
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: participants.length,
            separatorBuilder: (_, _) => AppSpacing.gapSm,
            itemBuilder: (context, index) {
              final p = participants[index];
              return SizedBox(
                width: 140,
                child: GestureDetector(
                  onTap: () => setState(() => _activeSpeakerId = p.userId),
                  child: ParticipantTile(
                    participant: p,
                    isLocalUser: p.userId == 'usr_admin_1',
                    isActiveSpeaker: p.userId == _activeSpeakerId,
                    isThumbnail: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScreenSharingLayout(List<ParticipantModel> participants) {
    return Column(
      children: [
        // Top Screen Share Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainerDark,
            borderRadius: AppRadius.borderRadiusMd,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.screen_share_rounded,
                color: AppColors.primaryLight,
                size: 18,
              ),
              AppSpacing.gapWSm,
              const Expanded(
                child: Text(
                  'Alex Vance is presenting ConnectSoar System Architecture Diagram',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppButton(
                text: 'Stop Sharing',
                size: AppButtonSize.sm,
                variant: AppButtonVariant.danger,
                onPressed: _toggleScreenShare,
              ),
            ],
          ),
        ),
        AppSpacing.gapSm,

        // Main Shared Screen Presentation Area
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF141722),
              borderRadius: AppRadius.borderRadiusLg,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.architecture_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      AppSpacing.gapLg,
                      const Text(
                        'FastAPI WebRTC Gateway & Flutter Architecture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.gapXs,
                      const Text(
                        'Live code review session • High speed canvas streaming',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '1080p @ 60 FPS',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSpacing.gapSm,

        // Floating Horizontal Strip of Participant Thumbnails
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: participants.length,
            separatorBuilder: (_, _) => AppSpacing.gapSm,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 140,
                child: ParticipantTile(
                  participant: participants[index],
                  isThumbnail: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMobileChatSheet(
    BuildContext context,
    List<ChatMessageModel> messages,
  ) {
    final user = ref.read(currentUserProvider).value;
    AppBottomSheet.show(
      context: context,
      title: 'In-Meeting Chat',
      child: SizedBox(
        height: 440,
        child: MeetingChatSheet(
          messages: messages,
          width: double.infinity,
          currentUserId: user?.id,
          onClose: () => Navigator.of(context).pop(),
          onSendMessage: (txt) {
            _sendMessage(txt);
          },
        ),
      ),
    );
  }

  void _showMobileParticipantsSheet(
    BuildContext context,
    List<ParticipantModel> participants,
  ) {
    final user = ref.read(currentUserProvider).value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFF13161F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ParticipantsSheet(
                  participants: participants,
                  width: double.infinity,
                  currentUserId: user?.id,
                  isHost: _isHostPerspective,
                  onClose: () => Navigator.of(sheetContext).pop(),
                  onHostAction: _handleHostAction,
                  onInvite: _inviteParticipant,
                  isMobileSheet: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
