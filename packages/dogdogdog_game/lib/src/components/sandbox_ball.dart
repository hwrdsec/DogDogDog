import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../config/physics_config.dart';
import '../models/dog_definition.dart';
import '../rendering/dog_placeholder_paint.dart';

/// Circular dog body with a merge [level] from [DogDefinition].
class SandboxBall extends BodyComponent with ContactCallbacks {
  SandboxBall({
    required Vector2 position,
    required this.definition,
    required this.onMergeContact,
    PhysicsConfig physics = PhysicsConfig.defaults,
    this.isDropping = false,
  }) : _spawnPosition = position.clone(),
       _physics = physics,
       super(
         renderBody: false,
         paint: Paint()..color = definition.color,
         bodyDef: BodyDef(
           type: BodyType.dynamic,
           position: position.clone(),
           angularDamping: physics.ballAngularDamping,
           linearDamping: physics.ballLinearDamping,
         ),
         shapeSpecs: [
           ShapeSpec(
             Circle(radius: definition.radius),
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

  final DogDefinition definition;
  final void Function(SandboxBall self, SandboxBall other, Vector2 contactPoint)
  onMergeContact;

  final Vector2 _spawnPosition;
  final PhysicsConfig _physics;

  /// True once this body is claimed by a merge (queued or applied).
  bool isMerging = false;

  /// Player drop that has not contacted anything yet — skipped by danger checks.
  bool isDropping;

  /// World-space spawn position used when this ball was created.
  Vector2 get spawnPosition => _spawnPosition;

  int get level => definition.level;

  double get radius => definition.radius;

  PhysicsConfig get physics => _physics;

  /// True when any part of the circle sits above [dangerLineY] (smaller Y).
  bool isAboveDangerLine(double dangerLineY) {
    return position.y - radius < dangerLineY;
  }

  @override
  Body createBody() {
    bodyDef!.userData = this;
    return super.createBody();
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (isDropping) {
      isDropping = false;
    }
    if (isMerging || other is! SandboxBall || other.isMerging) {
      return;
    }
    // Report each unordered pair once; MergeRules also dedupes.
    if (identityHashCode(this) > identityHashCode(other)) {
      return;
    }

    final points = contact.points;
    final Vector2 contactPoint;
    if (points != null && points.isNotEmpty) {
      contactPoint = points.first.point.clone();
    } else {
      contactPoint = Vector2(
        (position.x + other.position.x) / 2,
        (position.y + other.position.y) / 2,
      );
    }
    onMergeContact(this, other, contactPoint);
  }

  @override
  void render(Canvas canvas) {
    final diameter = radius * 2;
    canvas.save();
    canvas.translate(-radius, -radius);
    paintDogPlaceholder(canvas, definition, diameter: diameter);
    canvas.restore();
  }
}
