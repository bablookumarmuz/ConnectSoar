import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WeeklyActivityBarChart extends StatelessWidget {
  final List<int> data;
  final List<String> labels;
  final double height;

  const WeeklyActivityBarChart({
    super.key,
    required this.data,
    required this.labels,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          final val = data[index];
          final ratio = maxValue > 0 ? (val / maxValue).clamp(0.05, 1.0) : 0.05;
          final isHighlight = index == data.length - 1 || val == maxValue;
          final label = index < labels.length ? labels[index] : '';

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$val',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isHighlight
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isHighlight
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Tooltip(
                    message: '$label: $val meetings',
                    child: Container(
                      width: 14,
                      height: (height - 48) * ratio,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isHighlight
                              ? [AppColors.primary, AppColors.primaryLight]
                              : [
                                  AppColors.primary.withValues(alpha: 0.3),
                                  AppColors.primary.withValues(alpha: 0.5),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isHighlight
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class AttendanceTrendSparkline extends StatelessWidget {
  final List<double> values;
  final double height;

  const AttendanceTrendSparkline({
    super.key,
    required this.values,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _SparklinePainter(
          values: values,
          lineColor: AppColors.success,
          fillColor: AppColors.success.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y =
          size.height - ((values[i] - minVal) / range) * (size.height - 8) - 4;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()..color = fillColor;
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}
