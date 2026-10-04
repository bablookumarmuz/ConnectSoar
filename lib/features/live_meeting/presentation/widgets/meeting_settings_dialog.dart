import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/inputs/app_dropdown.dart';

class MeetingSettingsDialog extends StatefulWidget {
  final bool isHost;
  final String activeBackground;
  final ValueChanged<String>? onBackgroundChanged;

  const MeetingSettingsDialog({
    super.key,
    this.isHost = true,
    this.activeBackground = 'none',
    this.onBackgroundChanged,
  });

  static Future<void> show(
    BuildContext context, {
    bool isHost = true,
    String activeBackground = 'none',
    ValueChanged<String>? onBackgroundChanged,
  }) {
    return showDialog(
      context: context,
      builder: (context) => MeetingSettingsDialog(
        isHost: isHost,
        activeBackground: activeBackground,
        onBackgroundChanged: onBackgroundChanged,
      ),
    );
  }

  @override
  State<MeetingSettingsDialog> createState() => _MeetingSettingsDialogState();
}

class _MeetingSettingsDialogState extends State<MeetingSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedCamera = 'default_cam';
  String _selectedMic = 'default_mic';
  String _selectedSpeaker = 'default_speaker';
  late String _selectedBackground;

  bool _noiseCancellation = true;
  bool _hdVideo = true;
  bool _lowDataSaver = false;

  // Host Controls
  bool _isMeetingLocked = false;
  bool _allowScreenShare = true;
  bool _allowChat = true;
  bool _muteOnEntry = false;

  final List<Map<String, String>> _backgrounds = [
    {'id': 'none', 'name': 'None', 'icon': '🚫'},
    {'id': 'blur', 'name': 'Blur', 'icon': '🌁'},
    {'id': 'office', 'name': 'Modern Office', 'icon': '🏢'},
    {'id': 'studio', 'name': 'Cyberpunk Studio', 'icon': '🏙️'},
    {'id': 'sunset', 'name': 'Sunset Beach', 'icon': '🌅'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.isHost ? 4 : 3, vsync: this);
    _selectedBackground = widget.activeBackground;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusXl,
        side: BorderSide(
          color: isDark ? const Color(0xFF2E3446) : AppColors.lightBorder,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.settings_rounded, color: AppColors.primary),
                  AppSpacing.gapWMd,
                  const Text(
                    'Meeting Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
              indicatorColor: AppColors.primary,
              tabs: [
                const Tab(text: 'Audio & Video'),
                const Tab(text: 'Virtual Background'),
                const Tab(text: 'Data Saver'),
                if (widget.isHost) const Tab(text: 'Host Controls'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAudioVideoTab(isDark),
                  _buildBackgroundsTab(isDark),
                  _buildDataSaverTab(isDark),
                  if (widget.isHost) _buildHostControlsTab(isDark),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Close',
                    variant: AppButtonVariant.primary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioVideoTab(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDropdown<String>(
            label: 'Camera Device',
            value: _selectedCamera,
            items: const [
              AppDropdownItem(
                value: 'default_cam',
                label: 'FaceTime HD WebCam (Integrated)',
                icon: Icons.videocam_rounded,
              ),
              AppDropdownItem(
                value: 'ext_cam',
                label: 'Logitech Brio 4K Pro',
                icon: Icons.camera_rounded,
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedCamera = val);
            },
          ),
          AppSpacing.gapMd,
          AppDropdown<String>(
            label: 'Microphone Input',
            value: _selectedMic,
            items: const [
              AppDropdownItem(
                value: 'default_mic',
                label: 'MacBook Pro Array Microphone',
                icon: Icons.mic_rounded,
              ),
              AppDropdownItem(
                value: 'ext_mic',
                label: 'Blue Yeti Pro USB Mic',
                icon: Icons.mic_external_on_rounded,
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedMic = val);
            },
          ),
          AppSpacing.gapMd,
          AppDropdown<String>(
            label: 'Speaker Output',
            value: _selectedSpeaker,
            items: const [
              AppDropdownItem(
                value: 'default_speaker',
                label: 'System Default Speakers',
                icon: Icons.volume_up_rounded,
              ),
              AppDropdownItem(
                value: 'headphones',
                label: 'AirPods Max (Bluetooth)',
                icon: Icons.headphones_rounded,
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedSpeaker = val);
            },
          ),
          AppSpacing.gapLg,
          SwitchListTile(
            title: const Text(
              'AI Noise Cancellation',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Suppress background keyboard clicks & room echoes',
              style: TextStyle(fontSize: 12),
            ),
            value: _noiseCancellation,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => setState(() => _noiseCancellation = val),
          ),
          SwitchListTile(
            title: const Text(
              'Enable HD 1080p Stream',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'High definition video quality mode',
              style: TextStyle(fontSize: 12),
            ),
            value: _hdVideo,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => setState(() => _hdVideo = val),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundsTab(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Virtual Background Effects',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          AppSpacing.gapXs,
          Text(
            'Select a background filter for your video camera preview',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
          AppSpacing.gapLg,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemCount: _backgrounds.length,
            itemBuilder: (context, index) {
              final bg = _backgrounds[index];
              final isSelected = bg['id'] == _selectedBackground;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedBackground = bg['id']!);
                  widget.onBackgroundChanged?.call(bg['id']!);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark
                              ? const Color(0xFF1F2432)
                              : Colors.grey.shade100),
                    borderRadius: AppRadius.borderRadiusLg,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? const Color(0xFF2E3446)
                                : AppColors.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(bg['icon']!, style: const TextStyle(fontSize: 24)),
                      AppSpacing.gapXXs,
                      Text(
                        bg['name']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? AppColors.primary : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSaverTab(bool isDark) {
    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text(
              'Low Bandwidth Data Saver',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Reduces incoming video resolution to conserve mobile data',
              style: TextStyle(fontSize: 12),
            ),
            value: _lowDataSaver,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => setState(() => _lowDataSaver = val),
          ),
        ],
      ),
    );
  }

  Widget _buildHostControlsTab(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Lock Meeting Room',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Prevent new participants from joining',
              style: TextStyle(fontSize: 12),
            ),
            value: _isMeetingLocked,
            activeTrackColor: AppColors.warning,
            onChanged: (val) => setState(() => _isMeetingLocked = val),
          ),
          SwitchListTile(
            title: const Text(
              'Allow Screen Sharing',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Allow attendees to share screen',
              style: TextStyle(fontSize: 12),
            ),
            value: _allowScreenShare,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => setState(() => _allowScreenShare = val),
          ),
          SwitchListTile(
            title: const Text(
              'Allow In-Meeting Chat',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Enable group chat messages',
              style: TextStyle(fontSize: 12),
            ),
            value: _allowChat,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => setState(() => _allowChat = val),
          ),
          SwitchListTile(
            title: const Text(
              'Mute Participants on Entry',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Mute new participants when they join',
              style: TextStyle(fontSize: 12),
            ),
            value: _muteOnEntry,
            activeTrackColor: AppColors.primary,
            onChanged: (val) => setState(() => _muteOnEntry = val),
          ),
        ],
      ),
    );
  }
}
