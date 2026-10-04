import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/meeting_providers.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_bottom_sheet.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../users/providers/user_providers.dart';
import 'qr_code_placeholder.dart';

class JoinMeetingSheet extends ConsumerStatefulWidget {
  const JoinMeetingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      title: 'Join a Meeting',
      child: const JoinMeetingSheet(),
    );
  }

  @override
  ConsumerState<JoinMeetingSheet> createState() => _JoinMeetingSheetState();
}

class _JoinMeetingSheetState extends ConsumerState<JoinMeetingSheet> {
  final TextEditingController _codeOrLinkController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _showQrScanner = false;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Default preview name from auth state if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null && user.name.isNotEmpty) {
        _nameController.text = user.name;
      }
    });
  }

  void _handleJoin() async {
    final input = _codeOrLinkController.text.trim();
    if (input.isEmpty) {
      setState(() => _errorText = 'Please enter a valid meeting code or link');
      return;
    }
    setState(() => _errorText = null);

    // Extract code if user pasted a full URL
    String code = input;
    if (input.contains('/meeting/')) {
      code = input.split('/meeting/').last.split('?').first;
    } else if (input.contains('/j/')) {
      code = input.split('/j/').last.split('?').first;
    }
    code = code.trim();

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(meetingRepositoryProvider);
      final password = _passwordController.text.trim();
      final joinResult = await repo.joinMeetingByCode(
        code,
        password: password.isNotEmpty ? password : null,
      );
      final meetingId =
          (joinResult['meetingId'] ??
                  joinResult['meeting_id'] ??
                  joinResult['id'] ??
                  '')
              .toString();

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).pop();
      if (meetingId.isNotEmpty) {
        context.push('/meetings/pre-join/$meetingId');
      } else {
        context.push('/meetings/pre-join/$code');
      }

      AppSnackBar.show(
        context,
        message: 'Successfully joined room!',
        type: AppSnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('ApiException: ', '');
      setState(() {
        _isLoading = false;
        _errorText = msg;
      });
      AppSnackBar.show(context, message: msg, type: AppSnackBarType.error);
    }
  }

  @override
  void dispose() {
    _codeOrLinkController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingsAsync = ref.watch(meetingsNotifierProvider);
    final recentMeetings = meetingsAsync.value?.take(3).toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Meeting Code or Link Input
        AppTextField(
          label: 'Meeting Code or Link *',
          hint: 'e.g. RT7-GH3-4TU or https://connectsoar.com/meeting/...',
          controller: _codeOrLinkController,
          errorText: _errorText,
          prefixIcon: Icons.tag_rounded,
          onChanged: (val) {
            if (val.trim().isNotEmpty && _errorText != null) {
              setState(() => _errorText = null);
            }
          },
        ),
        AppSpacing.gapMd,

        // Optional Password Field
        AppTextField(
          label: 'Room Password (If password protected)',
          hint: 'Enter room password',
          controller: _passwordController,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        AppSpacing.gapMd,

        // Display Name Preview Field
        AppTextField(
          label: 'Your Display Name Preview',
          hint: 'How your name appears to participants',
          controller: _nameController,
          prefixIcon: Icons.badge_outlined,
        ),
        AppSpacing.gapLg,

        // Quick Action Row: Scan QR Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Join via QR Scanner',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _showQrScanner = !_showQrScanner),
              icon: Icon(
                _showQrScanner
                    ? Icons.keyboard_rounded
                    : Icons.qr_code_scanner_rounded,
                size: 16,
              ),
              label: Text(_showQrScanner ? 'Hide QR Code' : 'Scan QR Code'),
            ),
          ],
        ),

        if (_showQrScanner) ...[
          AppSpacing.gapSm,
          Center(
            child: Column(
              children: [
                QrCodePlaceholder(
                  data: _codeOrLinkController.text.isNotEmpty
                      ? _codeOrLinkController.text
                      : 'CONNECTSOAR-JOIN-QR',
                  size: 160,
                ),
                AppSpacing.gapSm,
                Text(
                  'Point camera at ConnectSoar QR Code to auto-fill code',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapLg,
        ],

        // Recent Meetings Quick Selection List
        if (recentMeetings.isNotEmpty) ...[
          Text(
            'Recent Meetings',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          AppSpacing.gapSm,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentMeetings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final m = recentMeetings[index];
              return AppCard(
                onTap: () {
                  setState(() {
                    _codeOrLinkController.text = m.joinCode;
                    _errorText = null;
                  });
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    AppSpacing.gapWMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Code: ${m.joinCode} • Host: ${m.hostName}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  ],
                ),
              );
            },
          ),
          AppSpacing.gapLg,
        ],

        // Submit Button Actions
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
              text: 'Join Room',
              isLoading: _isLoading,
              icon: Icons.login_rounded,
              onPressed: _handleJoin,
            ),
          ],
        ),
      ],
    );
  }
}
