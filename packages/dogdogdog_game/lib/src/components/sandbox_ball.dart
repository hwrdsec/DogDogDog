import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../config/physics_config.dart';

/// Placeholder circular body for the Milestone 2 physics sandbox.
class SandboxBall extends BodyComponent {
  SandboxBall({
    required Vector2 position,
    required Color color,
    PhysicsConfig physics = PhysicsConfig.defaults,
    double? radius,
  }) : _spawnPosition = position.clone(),
       _physics = physics,
       _radius = radius ?? physics.ballRadius,
       super(
         paint: Paint()..color = color,
         bodyDef: BodyDef(
           type: BodyType.dynamic,
           position: position.clone(),
           angularDamping: physics.ballAngularDamping,
           linearDamping: physics.ballLinearDamping,
         ),
         shapeSpecs: [
           ShapeSpec(
             Circle(radius: radius ?? physics.ballRadius),
             ShapeDef(
               density: physics.ballDensity,
               material: SurfaceMaterial(
                 restitution: physics.ballRestitution,
                 friction: physics.ballFriction,
               ),
             ),
           ),
         ],
       );

  final Vector2 _spawnPosition;
  final PhysicsConfig _physics;
  final double _radius;

  /// World-space spawn position used when this ball was created.
  Vector2 get spawnPosition => _spawnPosition;

  double get radius => _radius;

  PhysicsConfig get physics => _physics;
}
