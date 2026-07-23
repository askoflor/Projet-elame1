import 'package:flutter/material.dart';

/// Line chart with a Y-axis stepped at a fixed increment (e.g. every 5 units
/// or every 10 000 FCFA) and an X-axis of dates.
class AxisLineChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> points;
  final Color color;
  final double yStep;
  final String Function(double value)? yLabelFormatter;
  final double height;

  const AxisLineChart({
    super.key,
    required this.points,
    required this.color,
    required this.yStep,
    this.yLabelFormatter,
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _AxisLineChartPainter(
          points: points,
          color: color,
          yStep: yStep,
          yLabelFormatter: yLabelFormatter ?? (v) => v.toStringAsFixed(0),
        ),
      ),
    );
  }
}

class _AxisLineChartPainter extends CustomPainter {
  final List<MapEntry<DateTime, double>> points;
  final Color color;
  final double yStep;
  final String Function(double) yLabelFormatter;

  _AxisLineChartPainter({
    required this.points,
    required this.color,
    required this.yStep,
    required this.yLabelFormatter,
  });

  static const _leftAxisWidth = 48.0;
  static const _bottomAxisHeight = 16.0;
  static const _labelStyle = TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontFamily: 'DM Sans');

  @override
  void paint(Canvas canvas, Size size) {
    final chartRect = Rect.fromLTWH(
      _leftAxisWidth,
      2,
      size.width - _leftAxisWidth,
      size.height - _bottomAxisHeight - 2,
    );

    if (points.isEmpty || chartRect.width <= 0) {
      _drawCentered(canvas, size, 'Aucune donnée sur cette période');
      return;
    }

    final maxVal = points.map((e) => e.value).fold<double>(0, (a, b) => b > a ? b : a);
    final niceMax = maxVal <= 0 ? yStep : (maxVal / yStep).ceil() * yStep;
    final tickCount = (niceMax / yStep).round().clamp(1, 999);
    final labelEvery = tickCount > 5 ? (tickCount / 5).ceil() : 1;

    final gridPaint = Paint()
      ..color = const Color(0xFFE8ECF2)
      ..strokeWidth = 1;

    for (var t = 0; t <= tickCount; t++) {
      final value = t * yStep;
      final y = chartRect.bottom - (value / niceMax) * chartRect.height;
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), gridPaint);
      if (t % labelEvery == 0) {
        _drawRightAligned(canvas, yLabelFormatter(value), y - 6, _leftAxisWidth - 6);
      }
    }

    final dx = points.length > 1 ? chartRect.width / (points.length - 1) : 0.0;
    final offsets = <Offset>[
      for (var i = 0; i < points.length; i++)
        Offset(
          chartRect.left + dx * i,
          chartRect.bottom - (niceMax == 0 ? 0 : (points[i].value / niceMax) * chartRect.height),
        ),
    ];

    if (offsets.length == 1) {
      canvas.drawCircle(offsets.first, 3, Paint()..color = color);
    } else {
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final o in offsets.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, linePaint);

      final fillPath = Path.from(path)
        ..lineTo(offsets.last.dx, chartRect.bottom)
        ..lineTo(offsets.first.dx, chartRect.bottom)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.22), color.withOpacity(0)],
          ).createShader(chartRect),
      );

      canvas.drawCircle(offsets.last, 3, Paint()..color = color);
    }

    for (final i in _xLabelIndices(points.length)) {
      final date = points[i].key;
      final label = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      _drawCenteredAt(canvas, label, offsets[i].dx, size.height - _bottomAxisHeight + 2);
    }
  }

  List<int> _xLabelIndices(int length) {
    if (length <= 1) return [0];
    const maxLabels = 4;
    if (length <= maxLabels) return List.generate(length, (i) => i);
    final step = (length - 1) / (maxLabels - 1);
    return List.generate(maxLabels, (i) => (i * step).round());
  }

  void _drawRightAligned(Canvas canvas, String text, double y, double width) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    painter.paint(canvas, Offset(width - painter.width, y));
  }

  void _drawCenteredAt(Canvas canvas, String text, double centerX, double y) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 60);
    painter.paint(canvas, Offset(centerX - painter.width / 2, y));
  }

  void _drawCentered(Canvas canvas, Size size, String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontFamily: 'DM Sans')),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    painter.paint(canvas, Offset((size.width - painter.width) / 2, (size.height - painter.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _AxisLineChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color || oldDelegate.yStep != yStep;
}
