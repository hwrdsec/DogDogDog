import 'dart:ui';

import 'package:flame/components.dart';

import '../models/dog_definition.dart';

/// Non-physics ghost showing where the next drop will land horizontally.
class AimPreview extends PositionComponent {
  AimPreview({required DogDefinition definition})
    : _definition = definition,
      super(anchor: Anchor.center) {
    size = Vector2.all(definition.radius * 2);
  }

  DogDefinition _definition;

  DogDefinition get definition => _definition;

  set definition(DogDefinition value) {
    _definition = value;
    size = Vector2.all(value.radius * 2);
  }

  @override
  void render(Canvas canvas) {
    final radius = _definition.radius;
    final fill = Paint()..color = _definition.color.withValues(alpha: 0.55);
    final ring = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.06;
    canvas.drawCircle(Offset(radius, radius), radius, fill);
    canvas.drawCircle(Offset(radius, radius), radius, ring);
  }
}
