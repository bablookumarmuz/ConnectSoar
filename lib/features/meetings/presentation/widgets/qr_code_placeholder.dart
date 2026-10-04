import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QrCodePlaceholder extends StatelessWidget {
  final String data;
  final double size;

  const QrCodePlaceholder({super.key, required this.data, this.size = 180.0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _QrPainter(isDark: isDark, seed: data.hashCode),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final bool isDark;
  final int seed;

  _QrPainter({required this.isDark, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white : AppColors.darkBackground
      ..style = PaintingStyle.fill;

    final primaryPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    const int gridCount = 9;
    final double cellSize = size.width / gridCount;

    // Draw Corner Position Detection Patterns (Finder Patterns)
    _drawFinderPattern(
      canvas,
      const Offset(0, 0),
      cellSize,
      primaryPaint,
      paint,
    );
    _drawFinderPattern(
      canvas,
      Offset((gridCount - 3) * cellSize, 0),
      cellSize,
      primaryPaint,
      paint,
    );
    _drawFinderPattern(
      canvas,
      Offset(0, (gridCount - 3) * cellSize),
      cellSize,
      primaryPaint,
      paint,
    );

    // Draw Pseudo Data Modules based on seed
    for (int r = 0; r < gridCount; r++) {
      for (int c = 0; c < gridCount; c++) {
        // Skip finder patterns areas
        if ((r < 3 && c < 3) ||
            (r < 3 && c >= gridCount - 3) ||
            (r >= gridCount - 3 && c < 3)) {
          continue;
        }

        final cellSeed = (seed + (r * 17) + (c * 31)) % 100;
        if (cellSeed % 2 == 0) {
          final rect = Rect.fromLTWH(
            c * cellSize + (cellSize * 0.1),
            r * cellSize + (cellSize * 0.1),
            cellSize * 0.8,
            cellSize * 0.8,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2)),
            (cellSeed % 3 == 0) ? primaryPaint : paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(
    Canvas canvas,
    Offset offset,
    double cellSize,
    Paint outerPaint,
    Paint innerPaint,
  ) {
    final outerRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      cellSize * 3,
      cellSize * 3,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, const Radius.circular(6)),
      outerPaint,
    );

    final midRect = Rect.fromLTWH(
      offset.dx + cellSize * 0.5,
      offset.dy + cellSize * 0.5,
      cellSize * 2,
      cellSize * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(midRect, const Radius.circular(4)),
      innerPaint,
    );

    final centerRect = Rect.fromLTWH(
      offset.dx + cellSize,
      offset.dy + cellSize,
      cellSize,
      cellSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(2)),
      outerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.seed != seed;
}
