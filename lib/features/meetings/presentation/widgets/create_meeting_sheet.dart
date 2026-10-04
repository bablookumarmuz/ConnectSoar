import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/meeting_providers.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/feedback/app_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../domain/models/meeting_model.dart';

class CreateMeetingSheet extends ConsumerStatefulWidget {
  const CreateMeetingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      title: 'Create Instant Meeting',
      child: const CreateMeetingSheet(),
    );
  }

  @override
  ConsumerState<CreateMeetingSheet> createState() => _CreateMeetingSheetState();
}

class _CreateMeetingSheetState extends ConsumerState<CreateMeetingSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();

  MeetingType _selectedType = MeetingType.instant;
  bool _isChatAllowed = true;
  bool _isScreenShareAllowed = true;
  bool _isMuteOnEntry = false;
  bool _isCameraAllowed = true;
  bool _isLoading = false;
  String? _titleError;

  void _handleCreate() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Please enter a meeting title');
      return;
    }
    setState(() => _titleError = null);

    setState(() => _isLoading = true);
    try {
      final password = _passwordController.text.trim();
      final newMeeting = await ref
          .read(meetingsNotifierProvider.notifier)
          .createMeeting(
            title: title,
            description: _descController.text.trim(),
            type: _selectedType,
            password: password.isNotEmpty ? password : null,
            isChatAllowed: _isChatAllowed,
            isScreenShareAllowed: _isScreenShareAllowed,
            isMuteOnEntry: _isMuteOnEntry,
            isCameraAllowed: _isCameraAllowed,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(
        context,
        message: 'Instant meeting "${newMeeting.title}" created successfully!',
        type: AppSnackBarType.success,
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(
        context,
        message: 'Failed to create meeting: $e',
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _passwordController.dispose();
    _participantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Field
          AppTextField(
            label: 'Meeting Title *',
            hint: 'e.g. Ad-hoc Architecture Sync',
            controller: _titleController,
            errorText: _titleError,
            prefixIcon: Icons.videocam_rounded,
            onChanged: (val) {
              if (val.trim().isNotEmpty && _titleError != null) {
                setState(() => _titleError = null);
              }
            },
          ),
          AppSpacing.gapMd,

          // Description Field
          AppTextField(
            label: 'Description / Agenda',
            hint: 'Describe topics to discuss...',
            controller: _descController,
            maxLines: 2,
            prefixIcon: Icons.description_outlined,
          ),
          AppSpacing.gapMd,

          // Meeting Type Dropdown
          AppDropdown<MeetingType>(
            label: 'Meeting Type',
            value: _selectedType,
            items: const [
              AppDropdownItem(
                value: MeetingType.instant,
                label: 'Instant Room',
                icon: Icons.flash_on_rounded,
              ),
              AppDropdownItem(
                value: MeetingType.teamSync,
                label: 'Team Sync',
                icon: Icons.group_rounded,
              ),
              AppDropdownItem(
                value: MeetingType.oneOnOne,
                label: '1-on-1 Session',
                icon: Icons.person_rounded,
              ),
              AppDropdownItem(
                value: MeetingType.webinar,
                label: 'Broadcast / Webinar',
                icon: Icons.campaign_rounded,
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
          AppSpacing.gapMd,

          // Optional Password
          AppTextField(
            label: 'Optional Password / Security Key',
            hint: 'e.g. secret123 (Leave blank for open room)',
            controller: _passwordController,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
          ),
          AppSpacing.gapMd,

          // Participants Invites Input
          AppTextField(
            label: 'Invite Participants (Emails / User IDs)',
            hint: 'alex@connectsoar.io, sophia@connectsoar.io',
            controller: _participantsController,
            prefixIcon: Icons.person_add_outlined,
          ),
          AppSpacing.gapLg,

          // Room Permissions Section
          Text(
            'Room Permissions Settings',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          AppSpacing.gapSm,

          _buildSwitchTile(
            title: 'Allow Participant Chat',
            subtitle: 'Enable text messaging during the call',
            value: _isChatAllowed,
            onChanged: (val) => setState(() => _isChatAllowed = val),
          ),
          _buildSwitchTile(
            title: 'Allow Screen Sharing',
            subtitle: 'Allow attendees to share screen',
            value: _isScreenShareAllowed,
            onChanged: (val) => setState(() => _isScreenShareAllowed = val),
          ),
          _buildSwitchTile(
            title: 'Mute Participants on Entry',
            subtitle: 'Automatically mute microphones when joining',
            value: _isMuteOnEntry,
            onChanged: (val) => setState(() => _isMuteOnEntry = val),
          ),
          _buildSwitchTile(
            title: 'Allow Participant Video Camera',
            subtitle: 'Enable video feeds for attendees',
            value: _isCameraAllowed,
            onChanged: (val) => setState(() => _isCameraAllowed = val),
          ),
          AppSpacing.gapLg,

          // Submit Actions
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(),
              ),
              AppButton(
                text: 'Create Room Now',
                isLoading: _isLoading,
                icon: Icons.video_call_rounded,
                onPressed: _handleCreate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeThumbColor: AppColors.primary,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}
