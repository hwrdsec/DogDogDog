import 'dart:ui';

import 'package:flame/components.dart';

import '../models/dog_definition.dart';
import '../rendering/dog_placeholder_paint.dart';

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
    paintDogPlaceholder(
      canvas,
      _definition,
      diameter: size.x,
      fillAlpha: 0.55,
      showRing: true,
    );
  }
}
