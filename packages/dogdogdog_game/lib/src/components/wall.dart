import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../config/physics_config.dart';

/// Static segment boundary for the play area (floor or side wall).
class Wall extends BodyComponent {
  Wall({required Vector2 start, required Vector2 end, PhysicsConfig? physics})
    : _start = start.clone(),
      _end = end.clone(),
      _physics = physics ?? PhysicsConfig.defaults,
      super(
        paint: Paint()
          ..color = const Color(0xFF4A5568)
          ..strokeWidth = 0.08
          ..style = PaintingStyle.stroke,
      );

  final Vector2 _start;
  final Vector2 _end;
  final PhysicsConfig _physics;

  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2.zero(), type: BodyType.static);
    final shapeDef = ShapeDef(
      material: SurfaceMaterial(
        friction: _physics.wallFriction,
        restitution: _physics.wallRestitution,
      ),
    );

    return world.createBody(bodyDef)
      ..createShape(Segment(point1: _start, point2: _end), shapeDef);
  }
}
