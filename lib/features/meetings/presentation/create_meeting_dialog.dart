import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/meeting_providers.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_dialog.dart';
import '../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../domain/models/meeting_model.dart';

class CreateMeetingDialog extends ConsumerStatefulWidget {
  const CreateMeetingDialog({super.key});

  @override
  ConsumerState<CreateMeetingDialog> createState() =>
      _CreateMeetingDialogState();
}

class _CreateMeetingDialogState extends ConsumerState<CreateMeetingDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  void _handleCreate() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please enter a meeting title',
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final newMeeting = await ref
          .read(meetingsNotifierProvider.notifier)
          .createMeeting(
            title: title,
            description: _descController.text.trim(),
            type: MeetingType.instant,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(
        context,
        message: 'Meeting "${newMeeting.title}" created successfully!',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppDialog(
      title: 'Schedule / Instant Meeting',
      message: 'Create a new collaboration room for your team.',
      content: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Meeting Subject',
              hint: 'e.g. Q3 Sprint Planning Sync',
              controller: _titleController,
              prefixIcon: Icons.title_rounded,
            ),
            AppSpacing.gapMd,
            AppTextField(
              label: 'Description / Agenda',
              hint: 'Key topics to discuss...',
              controller: _descController,
              maxLines: 3,
            ),
            AppSpacing.gapMd,
            Container(
              padding: AppSpacing.paddingSm,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  AppSpacing.gapWSm,
                  Text(
                    'Duration: 45 minutes (Default)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          text: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppSpacing.gapWSm,
        AppButton(
          text: 'Create Room',
          isLoading: _isLoading,
          icon: Icons.video_call_rounded,
          onPressed: _handleCreate,
        ),
      ],
    );
  }
}
