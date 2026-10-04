import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/feedback/app_bottom_sheet.dart';
import '../../../../shared/widgets/inputs/app_dropdown.dart';
import '../../domain/models/meeting_model.dart';

class MeetingFilterOptions {
  final MeetingType? type;
  final bool? requiresPassword;
  final String? selectedHost;

  const MeetingFilterOptions({
    this.type,
    this.requiresPassword,
    this.selectedHost,
  });

  MeetingFilterOptions copyWith({
    MeetingType? type,
    bool? requiresPassword,
    String? selectedHost,
  }) {
    return MeetingFilterOptions(
      type: type,
      requiresPassword: requiresPassword,
      selectedHost: selectedHost,
    );
  }

  bool get isEmpty =>
      type == null &&
      requiresPassword == null &&
      (selectedHost == null || selectedHost!.isEmpty);
}

class MeetingFilterSheet extends StatefulWidget {
  final MeetingFilterOptions initialOptions;

  const MeetingFilterSheet({super.key, required this.initialOptions});

  static Future<MeetingFilterOptions?> show(
    BuildContext context,
    MeetingFilterOptions currentOptions,
  ) {
    return AppBottomSheet.show<MeetingFilterOptions>(
      context: context,
      title: 'Filter Meetings',
      child: MeetingFilterSheet(initialOptions: currentOptions),
    );
  }

  @override
  State<MeetingFilterSheet> createState() => _MeetingFilterSheetState();
}

class _MeetingFilterSheetState extends State<MeetingFilterSheet> {
  MeetingType? _selectedType;
  bool? _requiresPassword;
  String? _selectedHost;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialOptions.type;
    _requiresPassword = widget.initialOptions.requiresPassword;
    _selectedHost = widget.initialOptions.selectedHost;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Filter by Meeting Type
        Text(
          'Meeting Category / Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        AppSpacing.gapSm,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChoiceChip(
              label: 'All Types',
              selected: _selectedType == null,
              onSelected: (_) => setState(() => _selectedType = null),
            ),
            ...MeetingType.values.map((t) {
              return _buildChoiceChip(
                label: t.name.toUpperCase(),
                selected: _selectedType == t,
                onSelected: (_) => setState(() => _selectedType = t),
              );
            }),
          ],
        ),
        AppSpacing.gapLg,

        // Security / Password Filter Dropdown
        AppDropdown<bool?>(
          label: 'Security Protection',
          value: _requiresPassword,
          items: const [
            AppDropdownItem(
              value: null,
              label: 'All Meetings (Password & Open)',
            ),
            AppDropdownItem(value: true, label: 'Password Protected Only'),
            AppDropdownItem(value: false, label: 'Open Access (No Password)'),
          ],
          onChanged: (val) => setState(() => _requiresPassword = val),
        ),
        AppSpacing.gapLg,

        // Reset & Apply Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _requiresPassword = null;
                  _selectedHost = null;
                });
              },
              child: const Text('Reset Filters'),
            ),
            Row(
              children: [
                AppButton(
                  text: 'Cancel',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                AppSpacing.gapWSm,
                AppButton(
                  text: 'Apply Filters',
                  icon: Icons.filter_alt_rounded,
                  onPressed: () {
                    final options = MeetingFilterOptions(
                      type: _selectedType,
                      requiresPassword: _requiresPassword,
                      selectedHost: _selectedHost,
                    );
                    Navigator.of(context).pop(options);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark
          ? AppColors.darkSurfaceElevated
          : AppColors.lightSurfaceElevated,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected
            ? Colors.white
            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ),
    );
  }
}
