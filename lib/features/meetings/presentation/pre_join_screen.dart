import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../services/media/microphone_controller.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/buttons/app_icon_button.dart';
import '../../../shared/widgets/cards/app_card.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/loading/skeleton_loader.dart';
import '../../../shared/widgets/media/camera_preview_widget.dart';
import '../../../shared/widgets/navigation/connectsoar_app_bar.dart';
import '../../../shared/widgets/states/error_state_widget.dart';
import '../domain/models/meeting_model.dart';
import '../providers/meeting_providers.dart';
import '../../users/providers/user_providers.dart';

class PreJoinScreen extends ConsumerStatefulWidget {
  final String meetingId;

  const PreJoinScreen({super.key, required this.meetingId});

  @override
  ConsumerState<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends ConsumerState<PreJoinScreen>
    with SingleTickerProviderStateMixin {
  bool _isMicMuted = false;
  bool _isVideoOff = false;
  String _selectedCamera = 'facetime_hd';
  String _selectedMic = 'builtin_mic';
  String _selectedSpeaker = 'builtin_speaker';
  String _selectedBackground = 'none';

  final TextEditingController _userNameController = TextEditingController(
    text: 'Alex Vance',
  );
  late AnimationController _audioLevelController;
  final MicrophoneController _micController = MicrophoneController();
  double _liveAudioLevel = 0.0;
  bool _isPlayingTestSound = false;

  final List<Map<String, String>> _backgroundOptions = [
    {'id': 'none', 'name': 'None', 'icon': '🚫'},
    {'id': 'blur', 'name': 'Blur', 'icon': '🌁'},
    {'id': 'office', 'name': 'Office', 'icon': '🏢'},
    {'id': 'studio', 'name': 'Studio', 'icon': '🏙️'},
    {'id': 'sunset', 'name': 'Sunset', 'icon': '🌅'},
  ];

  @override
  void initState() {
    super.initState();
    _audioLevelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _micController.audioLevelStream.listen((lvl) {
      if (mounted) {
        setState(() {
          _liveAudioLevel = lvl;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null && user.name.isNotEmpty && mounted) {
        _userNameController.text = user.name;
      }
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _audioLevelController.dispose();
    _micController.dispose();
    super.dispose();
  }

  void _testSpeakerAudio() async {
    setState(() => _isPlayingTestSound = true);
    AppSnackBar.show(
      context,
      message: 'Playing test audio chime...',
      type: AppSnackBarType.info,
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isPlayingTestSound = false);
      AppSnackBar.show(
        context,
        message: 'Speaker test passed successfully! ✓',
        type: AppSnackBarType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingsAsync = ref.watch(meetingsListProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: const ConnectSoarAppBar(
        title: 'Pre-Join Check',
        subtitle: 'Configure your audio & video before entering room',
        showBackButton: true,
      ),
      body: meetingsAsync.when(
        data: (meetings) {
          final fallbackMeeting = MeetingModel(
            id: widget.meetingId,
            title: 'ConnectSoar Meeting Room',
            description: 'Live room session',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 1)),
            status: MeetingStatus.live,
            type: MeetingType.instant,
            joinCode: 'CS-${widget.meetingId.toUpperCase()}',
            hostId: 'usr_admin_1',
            hostName: 'Alex Vance',
            hostAvatarUrl:
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
            participantIds: const ['usr_admin_1', 'usr_mgr_1', 'usr_emp_1'],
          );
          final meeting = meetings.firstWhere(
            (m) => m.id == widget.meetingId,
            orElse: () =>
                meetings.isNotEmpty ? meetings.first : fallbackMeeting,
          );

          return SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meeting Header Details
                    _buildMeetingHeaderCard(meeting, isDark),
                    AppSpacing.gapLg,

                    // Main Layout: Camera Preview (Left/Top) + Settings & Device Check (Right/Bottom)
                    if (isMobile)
                      Column(
                        children: [
                          _buildCameraPreviewBox(isDark),
                          AppSpacing.gapMd,
                          _buildVirtualBackgroundSelector(isDark),
                          AppSpacing.gapLg,
                          _buildDeviceCheckSection(isDark),
                          AppSpacing.gapLg,
                          _buildDeviceSelectorsCard(isDark),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Box: Video Preview + Backgrounds
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                _buildCameraPreviewBox(isDark),
                                AppSpacing.gapMd,
                                _buildVirtualBackgroundSelector(isDark),
                              ],
                            ),
                          ),
                          AppSpacing.gapLg,
                          // Right Box: Device Checks + Devices + Join CTA
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _buildDeviceCheckSection(isDark),
                                AppSpacing.gapMd,
                                _buildDeviceSelectorsCard(isDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () =>
            const Center(child: SkeletonLoader(width: 600, height: 400)),
        error: (err, _) => ErrorStateWidget(errorMessage: err.toString()),
      ),
    );
  }

  Widget _buildMeetingHeaderCard(dynamic meeting, bool isDark) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return AppCard(
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.video_call_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              AppSpacing.gapWMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.gapXXs,
                    Text(
                      'Host: ${meeting.hostName}  •  Join Code: ${meeting.joinCode}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isMobile) AppSpacing.gapSm,
          // Network Quality Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_rounded, color: AppColors.success, size: 14),
                SizedBox(width: 4),
                Text(
                  '22 ms (Excellent)',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMicHardware() async {
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
        AppSnackBar.show(
          context,
          message: 'Microphone Muted',
          type: AppSnackBarType.warning,
        );
      }
    }
  }

  Widget _buildCameraPreviewBox(bool isDark) {
    return Container(
      constraints: const BoxConstraints(minHeight: 220, maxHeight: 340),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CameraPreviewWidget(
              isVideoOff: _isVideoOff,
              userName: _userNameController.text,
              borderRadius: 16.0,
            ),
          ),
          if (!_isVideoOff && _selectedBackground != 'none')
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.borderRadiusXl,
                ),
                child: Center(
                  child: Text(
                    'Virtual Background: ${_selectedBackground.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Top Left Overlay: Name Tag
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  AppSpacing.gapWXs,
                  Text(
                    '${_userNameController.text} (You)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls Bar (Mic Toggle & Video Toggle)
          Positioned(
            bottom: 14,
            right: 14,
            left: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Audio Level Indicator
                if (!_isMicMuted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mic_rounded,
                          color: AppColors.success,
                          size: 14,
                        ),
                        AppSpacing.gapWXs,
                        Row(
                          children: List.generate(4, (i) {
                            final h =
                                6 +
                                (i *
                                    3 *
                                    (_liveAudioLevel > 0
                                        ? _liveAudioLevel
                                        : _audioLevelController.value));
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
                              width: 3,
                              height: h,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Mic Muted',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                Row(
                  children: [
                    AppIconButton(
                      icon: _isMicMuted
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      isSelected: _isMicMuted,
                      activeColor: AppColors.danger,
                      tooltip: _isMicMuted ? 'Unmute Mic' : 'Mute Mic',
                      onPressed: _toggleMicHardware,
                    ),
                    AppSpacing.gapWSm,
                    AppIconButton(
                      icon: _isVideoOff
                          ? Icons.videocam_off_rounded
                          : Icons.videocam_rounded,
                      isSelected: _isVideoOff,
                      activeColor: AppColors.danger,
                      tooltip: _isVideoOff ? 'Turn Video On' : 'Turn Video Off',
                      onPressed: () =>
                          setState(() => _isVideoOff = !_isVideoOff),
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

  Widget _buildVirtualBackgroundSelector(bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Virtual Background',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          AppSpacing.gapSm,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _backgroundOptions.map((bg) {
                final isSelected = bg['id'] == _selectedBackground;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () =>
                        setState(() => _selectedBackground = bg['id']!),
                    borderRadius: AppRadius.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (isDark
                                  ? const Color(0xFF1F2432)
                                  : Colors.grey.shade100),
                        borderRadius: AppRadius.borderRadiusMd,
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
                          Text(bg['icon']!),
                          AppSpacing.gapWXs,
                          Text(
                            bg['name']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCheckSection(bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Device Diagnostics Check',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          AppSpacing.gapMd,
          _buildDiagnosticItem(
            'Camera',
            _isVideoOff
                ? 'Disabled (Click to test)'
                : 'FaceTime HD 1080p (Ready)',
            !_isVideoOff,
            isDark,
          ),
          _buildDiagnosticItem(
            'Microphone',
            _isMicMuted ? 'Muted' : 'Array Mic (Audio Input Active)',
            !_isMicMuted,
            isDark,
          ),
          _buildDiagnosticItemWithAction(
            'Speaker',
            _isPlayingTestSound
                ? 'Testing Speaker Chime...'
                : 'Stereo Speakers (Ready)',
            true,
            isDark,
            actionLabel: 'Test Audio',
            onTap: _testSpeakerAudio,
          ),
          _buildDiagnosticItem(
            'Network',
            'Ping: 22ms • Bandwidth: 25 Mbps (Optimal)',
            true,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticItem(
    String title,
    String subtitle,
    bool isOk,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: isOk ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          AppSpacing.gapWMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
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
    );
  }

  Widget _buildDiagnosticItemWithAction(
    String title,
    String subtitle,
    bool isOk,
    bool isDark, {
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: isOk ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          AppSpacing.gapWMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            text: actionLabel,
            size: AppButtonSize.sm,
            variant: AppButtonVariant.outline,
            icon: Icons.volume_up_rounded,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceSelectorsCard(bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Your Display Name',
            controller: _userNameController,
            onChanged: (val) => setState(() {}),
          ),
          AppSpacing.gapMd,
          AppDropdown<String>(
            label: 'Camera Selector',
            value: _selectedCamera,
            items: const [
              AppDropdownItem(
                value: 'facetime_hd',
                label: 'FaceTime HD Camera (Built-in)',
                icon: Icons.videocam_rounded,
              ),
              AppDropdownItem(
                value: 'logitech_brio',
                label: 'Logitech Brio 4K WebCam',
                icon: Icons.camera_alt_rounded,
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedCamera = val);
            },
          ),
          AppSpacing.gapMd,
          AppDropdown<String>(
            label: 'Microphone Selector',
            value: _selectedMic,
            items: const [
              AppDropdownItem(
                value: 'builtin_mic',
                label: 'Built-in Array Microphone',
                icon: Icons.mic_rounded,
              ),
              AppDropdownItem(
                value: 'usb_mic',
                label: 'Blue Yeti USB Microphone',
                icon: Icons.mic_external_on_rounded,
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedMic = val);
            },
          ),
          AppSpacing.gapMd,
          AppDropdown<String>(
            label: 'Speaker Output Selector',
            value: _selectedSpeaker,
            items: const [
              AppDropdownItem(
                value: 'builtin_speaker',
                label: 'System Default Speakers',
                icon: Icons.volume_up_rounded,
              ),
              AppDropdownItem(
                value: 'airpods',
                label: 'AirPods Max (Bluetooth)',
                icon: Icons.headphones_rounded,
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedSpeaker = val);
            },
          ),
          AppSpacing.gapLg,

          // Join CTA
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Join Meeting Now',
              size: AppButtonSize.lg,
              icon: Icons.video_call_rounded,
              onPressed: () async {
                try {
                  await ref
                      .read(meetingRepositoryProvider)
                      .joinMeeting(widget.meetingId);
                } catch (_) {}
                if (mounted) {
                  context.push('/meetings/live/${widget.meetingId}');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
