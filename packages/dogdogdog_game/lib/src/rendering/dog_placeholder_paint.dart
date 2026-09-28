import 'package:flutter/painting.dart';

import '../models/dog_definition.dart';

/// Draws a colored circle with emoji + level digit centered in a square of
/// side [diameter] (local coords, top-left origin).
void paintDogPlaceholder(
  Canvas canvas,
  DogDefinition definition, {
  required double diameter,
  double fillAlpha = 1.0,
  bool showRing = false,
}) {
  final radius = diameter / 2;
  final center = Offset(radius, radius);
  final fill = Paint()..color = definition.color.withValues(alpha: fillAlpha);
  canvas.drawCircle(center, radius, fill);

  if (showRing) {
    final ring = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = diameter * 0.06;
    canvas.drawCircle(center, radius, ring);
  }

  final emojiSize = diameter * 0.55;
  final emojiPainter = TextPainter(
    text: TextSpan(
      text: definition.emoji,
      style: TextStyle(fontSize: emojiSize, height: 1),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  emojiPainter.paint(
    canvas,
    Offset(
      center.dx - emojiPainter.width / 2,
      center.dy - emojiPainter.height / 2 - diameter * 0.06,
    ),
  );

  final labelPainter = TextPainter(
    text: TextSpan(
      text: '${definition.level}',
      style: TextStyle(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
        fontSize: diameter * 0.28,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  labelPainter.paint(
    canvas,
    Offset(center.dx - labelPainter.width / 2, center.dy + diameter * 0.12),
  );
}
