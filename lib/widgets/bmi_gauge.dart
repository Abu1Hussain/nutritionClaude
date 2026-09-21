import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme.dart';

/// A semicircular BMI gauge: 4 yellow bands (low), 1 green band
/// (reference range), 4 red bands (high), with a marker at the current
/// BMI. Purely decorative -- callers must also render the numeric BMI and
/// status as real text nearby for accessibility (this widget is wrapped
/// with ExcludeSemantics by the caller).
///
/// The band hues themselves are intentionally theme-invariant (a data-
/// visualization convention, like the web app), but the marker uses the
/// active palette so it stays visible against either a light or dark card.
class BmiGauge extends StatelessWidget {
  final double bmi;

  const BmiGauge({super.key, required this.bmi});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AspectRatio(
      aspectRatio: 1.9,
      child: CustomPaint(
        painter: _BmiGaugePainter(bmi: bmi, markerFg: p.gaugeMarkerFg, markerRing: p.gaugeMarkerRing),
        child: Container(),
      ),
    );
  }
}

double _angleForValue(double v) {
  final clamped = v.clamp(gaugeMin, gaugeMax);
  final fraction = (clamped - gaugeMin) / (gaugeMax - gaugeMin);
  // pi (left/low) sweeping clockwise to 2*pi (right/high), through 1.5*pi (top).
  return math.pi + fraction * math.pi;
}

class _BmiGaugePainter extends CustomPainter {
  final double bmi;
  final Color markerFg;
  final Color markerRing;
  _BmiGaugePainter({required this.bmi, required this.markerFg, required this.markerRing});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.height * 0.22;
    final radius = (size.height - strokeWidth) * 0.92;
    final center = Offset(size.width / 2, size.height * 0.96);
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (final band in gaugeBands) {
      final start = _angleForValue(band.min);
      final sweep = _angleForValue(band.max) - start;
      final paint = Paint()
        ..color = band.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep, false, paint);
    }

    final markerAngle = _angleForValue(bmi);
    final outerR = radius + strokeWidth / 2 + 8;
    final innerR = radius - strokeWidth / 2 - 3;
    final outer = center + Offset(math.cos(markerAngle), math.sin(markerAngle)) * outerR;
    final inner = center + Offset(math.cos(markerAngle), math.sin(markerAngle)) * innerR;
    final dot = center + Offset(math.cos(markerAngle), math.sin(markerAngle)) * radius;

    final markerPaint = Paint()
      ..color = markerFg
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(inner, outer, markerPaint);
    canvas.drawCircle(dot, 7, Paint()..color = markerFg);
    canvas.drawCircle(dot, 7, Paint()
      ..color = markerRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _BmiGaugePainter oldDelegate) =>
      oldDelegate.bmi != bmi || oldDelegate.markerFg != markerFg || oldDelegate.markerRing != markerRing;
}
