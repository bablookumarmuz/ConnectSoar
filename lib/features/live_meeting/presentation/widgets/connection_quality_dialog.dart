import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_button.dart';

class ConnectionQualityDialog extends StatelessWidget {
  final int latencyMs;
  final double packetLossPercent;
  final String networkState; // 'Excellent', 'Good', 'Poor'

  const ConnectionQualityDialog({
    super.key,
    this.latencyMs = 24,
    this.packetLossPercent = 0.1,
    this.networkState = 'Excellent',
  });

  static Future<void> show(
    BuildContext context, {
    int latency = 24,
    double loss = 0.1,
    String state = 'Excellent',
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConnectionQualityDialog(
        latencyMs: latency,
        packetLossPercent: loss,
        networkState: state,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPoor = networkState.toLowerCase() == 'poor';

    final Color statusColor = isPoor
        ? AppColors.warning
        : (networkState.toLowerCase() == 'good'
              ? AppColors.info
              : AppColors.success);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusXl,
        side: BorderSide(
          color: isDark ? const Color(0xFF2E3446) : AppColors.lightBorder,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPoor ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                AppSpacing.gapWMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connection Diagnostics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Session Telemetry (Demo Simulation)',
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
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            AppSpacing.gapLg,

            // Overall Status Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    isPoor
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                  AppSpacing.gapWSm,
                  Expanded(
                    child: Text(
                      isPoor
                          ? 'Demo simulation: High latency detected.'
                          : 'Meeting simulation stream is running smoothly (Mock Mode).',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // Metric Items
            _buildMetricRow(
              context,
              'Status',
              networkState,
              statusColor,
              isDark,
            ),
            _buildMetricRow(
              context,
              'Latency (Ping)',
              '$latencyMs ms',
              isPoor ? AppColors.warning : AppColors.success,
              isDark,
            ),
            _buildMetricRow(
              context,
              'Packet Loss',
              '${packetLossPercent.toStringAsFixed(1)}%',
              isPoor ? AppColors.danger : AppColors.success,
              isDark,
            ),
            _buildMetricRow(
              context,
              'Incoming Resolution',
              '1080p @ 60 FPS (Simulated)',
              AppColors.primary,
              isDark,
            ),
            _buildMetricRow(
              context,
              'Outgoing Bitrate',
              '2.4 Mbps (HD)',
              AppColors.info,
              isDark,
            ),
            _buildMetricRow(
              context,
              'Video Codec',
              'VP9 (Hardware Accelerated)',
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              isDark,
            ),
            _buildMetricRow(
              context,
              'Audio Codec',
              'Opus 48kHz (High Fidelity)',
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              isDark,
            ),
            _buildMetricRow(
              context,
              'Gateway Status',
              'Local Mock Engine (API-Ready)',
              isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              isDark,
            ),

            AppSpacing.gapLg,

            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Done',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
