import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

/// Static segment boundary for the play area (floor or side wall).
class Wall extends BodyComponent {
  Wall({
    required Vector2 start,
    required Vector2 end,
    required this.friction,
    required this.restitution,
  }) : _start = start.clone(),
       _end = end.clone(),
       super(
         paint: Paint()
           ..color = const Color(0xFF4A5568)
           ..strokeWidth = 0.08
           ..style = PaintingStyle.stroke,
       );

  final Vector2 _start;
  final Vector2 _end;
  final double friction;
  final double restitution;

  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2.zero(), type: BodyType.static);
    final shapeDef = ShapeDef(
      material: SurfaceMaterial(friction: friction, restitution: restitution),
    );

    return world.createBody(bodyDef)
      ..createShape(Segment(point1: _start, point2: _end), shapeDef);
  }
}
