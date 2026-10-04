import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/meeting_providers.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/feedback/app_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/inputs/app_dropdown.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../domain/models/meeting_model.dart';

class ScheduleMeetingSheet extends ConsumerStatefulWidget {
  const ScheduleMeetingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      title: 'Schedule Future Meeting',
      child: const ScheduleMeetingSheet(),
    );
  }

  @override
  ConsumerState<ScheduleMeetingSheet> createState() =>
      _ScheduleMeetingSheetState();
}

class _ScheduleMeetingSheetState extends ConsumerState<ScheduleMeetingSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _inviteController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 3));
  TimeOfDay _selectedTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 3)),
  );
  int _durationMinutes = 45;
  String _selectedTimezone = 'UTC+05:30 (IST)';
  int _reminderMinutes = 15;
  RepeatOption _repeatOption = RepeatOption.never;
  final MeetingType _meetingType = MeetingType.scheduled;
  bool _isLoading = false;
  String? _titleError;

  final List<String> _timezones = const [
    'UTC+05:30 (IST)',
    'UTC+00:00 (GMT)',
    'UTC-05:00 (EST)',
    'UTC-08:00 (PST)',
    'UTC+01:00 (CET)',
    'UTC+03:00 (MSK)',
    'UTC+09:00 (JST)',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _handleSchedule() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Please enter a meeting title');
      return;
    }
    setState(() => _titleError = null);

    final combinedStart = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (combinedStart.isBefore(
      DateTime.now().subtract(const Duration(minutes: 5)),
    )) {
      AppSnackBar.show(
        context,
        message: 'Scheduled start time must be in the future',
        type: AppSnackBarType.warning,
      );
      return;
    }

    final emails = _inviteController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() => _isLoading = true);
    try {
      final scheduledMeeting = await ref
          .read(meetingsNotifierProvider.notifier)
          .scheduleMeeting(
            title: title,
            description: _descController.text.trim(),
            startTime: combinedStart,
            durationMinutes: _durationMinutes,
            type: _meetingType,
            repeatOption: _repeatOption,
            timezone: _selectedTimezone,
            reminderMinutes: _reminderMinutes,
            participantEmails: emails,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop();

      AppSnackBar.show(
        context,
        message:
            'Meeting "${scheduledMeeting.title}" scheduled for ${DateFormat('MMM dd, hh:mm a').format(combinedStart)}!',
        type: AppSnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(
        context,
        message: 'Failed to schedule meeting: $e',
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormat('EEE, MMM dd, yyyy').format(_selectedDate);
    final formattedTime = _selectedTime.format(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Input
          AppTextField(
            label: 'Meeting Title *',
            hint: 'e.g. Q4 Product Roadmap & Sprint Planning',
            controller: _titleController,
            errorText: _titleError,
            prefixIcon: Icons.event_note_rounded,
            onChanged: (val) {
              if (val.trim().isNotEmpty && _titleError != null) {
                setState(() => _titleError = null);
              }
            },
          ),
          AppSpacing.gapMd,

          // Description Input
          AppTextField(
            label: 'Agenda / Description',
            hint: 'Outline topics and objectives...',
            controller: _descController,
            maxLines: 2,
            prefixIcon: Icons.notes_rounded,
          ),
          AppSpacing.gapMd,

          // Responsive Date, Time, Duration, Timezone, Reminder, Repeat
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 420;

              Widget buildDateWidget() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  AppSpacing.gapXs,
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.lightSurfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          AppSpacing.gapWSm,
                          Expanded(
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              Widget buildTimeWidget() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Time *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  AppSpacing.gapXs,
                  InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.lightSurfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          AppSpacing.gapWSm,
                          Expanded(
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              Widget buildDurationWidget() => AppDropdown<int>(
                label: 'Duration',
                value: _durationMinutes,
                items: const [
                  AppDropdownItem(value: 15, label: '15 Mins'),
                  AppDropdownItem(value: 30, label: '30 Mins'),
                  AppDropdownItem(value: 45, label: '45 Mins'),
                  AppDropdownItem(value: 60, label: '1 Hour'),
                  AppDropdownItem(value: 90, label: '1.5 Hours'),
                  AppDropdownItem(value: 120, label: '2 Hours'),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _durationMinutes = val);
                },
              );

              Widget buildTimezoneWidget() => AppDropdown<String>(
                label: 'Timezone',
                value: _selectedTimezone,
                items: _timezones
                    .map((tz) => AppDropdownItem(value: tz, label: tz))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTimezone = val);
                },
              );

              Widget buildReminderWidget() => AppDropdown<int>(
                label: 'Reminder Notification',
                value: _reminderMinutes,
                items: const [
                  AppDropdownItem(value: 5, label: '5 Mins Before'),
                  AppDropdownItem(value: 10, label: '10 Mins Before'),
                  AppDropdownItem(value: 15, label: '15 Mins Before'),
                  AppDropdownItem(value: 30, label: '30 Mins Before'),
                  AppDropdownItem(value: 60, label: '1 Hour Before'),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _reminderMinutes = val);
                },
              );

              Widget buildRepeatWidget() => AppDropdown<RepeatOption>(
                label: 'Repeat / Recurrence',
                value: _repeatOption,
                items: const [
                  AppDropdownItem(
                    value: RepeatOption.never,
                    label: 'Does Not Repeat',
                  ),
                  AppDropdownItem(
                    value: RepeatOption.daily,
                    label: 'Every Day',
                  ),
                  AppDropdownItem(
                    value: RepeatOption.weekly,
                    label: 'Every Week',
                  ),
                  AppDropdownItem(
                    value: RepeatOption.monthly,
                    label: 'Every Month',
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _repeatOption = val);
                },
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDateWidget(),
                    AppSpacing.gapMd,
                    buildTimeWidget(),
                    AppSpacing.gapMd,
                    buildDurationWidget(),
                    AppSpacing.gapMd,
                    buildTimezoneWidget(),
                    AppSpacing.gapMd,
                    buildReminderWidget(),
                    AppSpacing.gapMd,
                    buildRepeatWidget(),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: buildDateWidget()),
                      AppSpacing.gapMd,
                      Expanded(child: buildTimeWidget()),
                    ],
                  ),
                  AppSpacing.gapMd,
                  Row(
                    children: [
                      Expanded(child: buildDurationWidget()),
                      AppSpacing.gapMd,
                      Expanded(child: buildTimezoneWidget()),
                    ],
                  ),
                  AppSpacing.gapMd,
                  Row(
                    children: [
                      Expanded(child: buildReminderWidget()),
                      AppSpacing.gapMd,
                      Expanded(child: buildRepeatWidget()),
                    ],
                  ),
                ],
              );
            },
          ),
          AppSpacing.gapMd,

          // Invite Participants Input
          AppTextField(
            label: 'Invite Participants (Email Addresses)',
            hint: 'sophiac@connectsoar.io, elena@connectsoar.io',
            controller: _inviteController,
            prefixIcon: Icons.group_add_outlined,
          ),
          AppSpacing.gapLg,

          // Form Actions
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
                text: 'Schedule Meeting',
                isLoading: _isLoading,
                icon: Icons.calendar_month_rounded,
                onPressed: _handleSchedule,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
