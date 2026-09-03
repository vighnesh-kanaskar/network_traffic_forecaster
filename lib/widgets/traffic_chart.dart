import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TrafficChart extends StatelessWidget {
  const TrafficChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: CustomPaint(
        painter: TrafficChartPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class TrafficChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = AppTheme.cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = AppTheme.cyan.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    const horizontalLines = 4;

    for (int i = 0; i <= horizontalLines; i++) {
      final y = size.height * i / horizontalLines;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final values = [
      0.28,
      0.38,
      0.31,
      0.48,
      0.42,
      0.63,
      0.56,
      0.71,
      0.62,
      0.84,
      0.77,
      0.93,
    ];

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);

      final y = size.height - (values[i] * size.height);

      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final areaPath = Path.from(path);

    areaPath.lineTo(size.width, size.height);

    areaPath.lineTo(0, size.height);

    areaPath.close();

    canvas.drawPath(areaPath, glowPaint);

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = AppTheme.cyan;

    for (final point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
