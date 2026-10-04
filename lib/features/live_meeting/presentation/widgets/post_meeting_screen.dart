import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';

class PostMeetingScreen extends StatefulWidget {
  final String meetingId;
  final String meetingTitle;

  const PostMeetingScreen({
    super.key,
    required this.meetingId,
    required this.meetingTitle,
  });

  @override
  State<PostMeetingScreen> createState() => _PostMeetingScreenState();
}

class _PostMeetingScreenState extends State<PostMeetingScreen> {
  int _selectedRating = 5;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    setState(() => _submitted = true);
    AppSnackBar.show(
      context,
      message: 'Thank you! Your meeting quality feedback has been recorded.',
      type: AppSnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Header
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 44,
                    ),
                  ),
                  AppSpacing.gapLg,
                  const Text(
                    'You Left the Meeting',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    widget.meetingTitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapXl,

                  // Summary Card
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          'Duration',
                          '28 mins',
                          Icons.timer_outlined,
                          isDark,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        _buildStatColumn(
                          'Participants',
                          '4 Active',
                          Icons.people_outline_rounded,
                          isDark,
                        ),
                        Container(
                          height: 36,
                          width: 1,
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        _buildStatColumn(
                          'Quality',
                          'HD 1080p',
                          Icons.high_quality_rounded,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLg,

                  // Rating Card
                  AppCard(
                    child: Column(
                      children: [
                        const Text(
                          'How was your call quality?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.gapSm,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starNumber = index + 1;
                            final isSelected = starNumber <= _selectedRating;
                            return IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: isSelected ? Colors.amber : Colors.grey,
                                size: 32,
                              ),
                              onPressed: _submitted
                                  ? null
                                  : () => setState(
                                      () => _selectedRating = starNumber,
                                    ),
                            );
                          }),
                        ),
                        if (!_submitted) ...[
                          AppSpacing.gapSm,
                          TextField(
                            controller: _feedbackController,
                            decoration: InputDecoration(
                              hintText:
                                  'Optional feedback on audio/video quality...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightBackground,
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.borderRadiusMd,
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                          ),
                          AppSpacing.gapMd,
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              text: 'Submit Feedback',
                              variant: AppButtonVariant.secondary,
                              onPressed: _submitFeedback,
                            ),
                          ),
                        ] else ...[
                          AppSpacing.gapSm,
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                color: AppColors.success,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Feedback submitted. Thank you!',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  AppSpacing.gapXl,

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Re-join Meeting',
                          variant: AppButtonVariant.outline,
                          icon: Icons.replay_rounded,
                          onPressed: () {
                            context.go(
                              '/meetings/pre-join/${widget.meetingId}',
                            );
                          },
                        ),
                      ),
                      AppSpacing.gapWMd,
                      Expanded(
                        child: AppButton(
                          text: 'Back to Dashboard',
                          variant: AppButtonVariant.primary,
                          icon: Icons.dashboard_rounded,
                          onPressed: () {
                            context.go(AppRoutes.dashboard);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        AppSpacing.gapXXs,
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      ],
    );
  }
}
