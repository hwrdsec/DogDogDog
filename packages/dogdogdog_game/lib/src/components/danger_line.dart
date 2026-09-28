import 'dart:ui';

import 'package:flame/components.dart';

/// Horizontal line marking the lose threshold across the fixed world width.
class DangerLine extends PositionComponent {
  DangerLine({required double worldWidth, required double y})
    : _worldWidth = worldWidth,
      super(
        position: Vector2(-worldWidth / 2, y),
        size: Vector2(worldWidth, 0.05),
        anchor: Anchor.centerLeft,
      );

  final double _worldWidth;

  void moveToY(double y) {
    position.y = y;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.85)
      ..strokeWidth = 0.05
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(_worldWidth, 0), paint);
  }
}
