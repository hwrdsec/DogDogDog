import 'dart:math' as math;

import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('separatePackedCircles', () {
    test('a pair that cannot sit side by side stacks instead', () {
      const left = -5.0;
      const right = 5.0;
      const floor = 8.0;
      final lower = PackedCircle(x: -1, y: 4.9, radius: 3.08);
      final upper = PackedCircle(x: 1.2, y: 4.4, radius: 2.392);

      separatePackedCircles(
        [lower, upper],
        left: left,
        right: right,
        floor: floor,
      );

      _expectSeparated([lower, upper], tolerance: 1e-6);
      _expectInsideBucket(
        [lower, upper],
        left: left,
        right: right,
        floor: floor,
        tolerance: 1e-6,
      );
      expect(upper.y, lessThan(lower.y));
    });
  });

  group('resting dogs', () {
    setUpAll(() async {
      await initializeForge2D();
    });

    test('level 7 and level 8 do not stay overlapped in the bucket', () {
      final settled = _settle([
        (3.08, -1.0, -2.0),
        (2.392, 1.4, -3.0),
        (0.57, 4.0, 0.0),
        (0.57, -4.3, 4.0),
      ]);

      _expectSeparated(settled, tolerance: 0.02);
      _expectInsideBucket(
        settled,
        left: -PhysicsConfig.defaults.worldWidth / 2,
        right: PhysicsConfig.defaults.worldWidth / 2,
        floor: PhysicsConfig.defaults.visibleWorldHeight / 2,
        tolerance: 0.02,
      );
    });

    test('two level-8 dogs stack instead of sinking into each other', () {
      final settled = _settle([(3.08, -0.4, -1.0), (3.08, 0.4, -2.0)]);

      _expectSeparated(settled, tolerance: 0.02);
      _expectInsideBucket(
        settled,
        left: -PhysicsConfig.defaults.worldWidth / 2,
        right: PhysicsConfig.defaults.worldWidth / 2,
        floor: PhysicsConfig.defaults.visibleWorldHeight / 2,
        tolerance: 0.02,
      );
    });

    test('a pile of small dogs does not sink into the floor or walls', () {
      final drops = <(double, double, double)>[];
      for (var i = 0; i < 8; i++) {
        drops.add((0.57, -3.5 + i * 0.9, -6.0 - (i % 3) * 0.4));
      }
      final settled = _settle(drops);

      _expectSeparated(settled, tolerance: 0.02);
      _expectInsideBucket(
        settled,
        left: -PhysicsConfig.defaults.worldWidth / 2,
        right: PhysicsConfig.defaults.worldWidth / 2,
        floor: PhysicsConfig.defaults.visibleWorldHeight / 2,
        tolerance: 0.02,
      );
    });
  });
}

List<PackedCircle> _settle(List<(double, double, double)> specs) {
  const physics = PhysicsConfig.defaults;
  final halfW = physics.worldWidth / 2;
  final floorY = physics.visibleWorldHeight / 2;
  final topY = -floorY;
  final world = World(gravity: Vector2(0, physics.gravityY));
  final bounds = world.createBody(BodyDef());
  bounds
    ..createShape(
      Segment(point1: Vector2(-halfW, topY), point2: Vector2(-halfW, floorY)),
    )
    ..createShape(
      Segment(point1: Vector2(halfW, topY), point2: Vector2(halfW, floorY)),
    )
    ..createShape(
      Segment(point1: Vector2(-halfW, floorY), point2: Vector2(halfW, floorY)),
    );

  final bodies = <(Body, double)>[];
  for (final (radius, x, y) in specs) {
    final body = world.createBody(
      BodyDef(
        type: BodyType.dynamic,
        position: Vector2(x, y),
        linearDamping: physics.ballLinearDamping,
        angularDamping: physics.ballAngularDamping,
      ),
    );
    body.createShape(
      Circle(radius: radius),
      ShapeDef(
        density: physics.ballDensity,
        material: SurfaceMaterial(
          friction: physics.ballFriction,
          restitution: physics.ballRestitution,
        ),
      ),
    );
    bodies.add((body, radius));
  }

  for (var frame = 0; frame < 240; frame++) {
    world.step(physics.timeStep, subStepCount: 4);
    final packed = [
      for (final (body, radius) in bodies)
        PackedCircle(
          x: body.position.x,
          y: body.position.y,
          radius: radius,
          inverseMass: body.mass == 0 ? 0 : 1 / body.mass,
        ),
    ];
    separatePackedCircles(packed, left: -halfW, right: halfW, floor: floorY);
    for (var i = 0; i < bodies.length; i++) {
      final body = bodies[i].$1;
      final pose = packed[i];
      if ((body.position.x - pose.x).abs() < 1e-4 &&
          (body.position.y - pose.y).abs() < 1e-4) {
        continue;
      }
      body.setTransform(Vector2(pose.x, pose.y), Rot.fromAngle(body.angle));
      body.isAwake = true;
    }
  }

  final settled = [
    for (final (body, radius) in bodies)
      PackedCircle(
        x: body.position.x,
        y: body.position.y,
        radius: radius,
        inverseMass: body.mass == 0 ? 0 : 1 / body.mass,
      ),
  ];
  world.destroy();
  return settled;
}

void _expectSeparated(List<PackedCircle> circles, {required double tolerance}) {
  for (var i = 0; i < circles.length; i++) {
    for (var j = i + 1; j < circles.length; j++) {
      final a = circles[i];
      final b = circles[j];
      final dx = a.x - b.x;
      final dy = a.y - b.y;
      final distance = _hypot(dx, dy);
      final overlap = a.radius + b.radius - distance;
      expect(
        overlap,
        lessThanOrEqualTo(tolerance),
        reason:
            'circles $i and $j overlap by $overlap '
            '(centers ${a.x}, ${a.y} and ${b.x}, ${b.y})',
      );
    }
  }
}

void _expectInsideBucket(
  List<PackedCircle> circles, {
  required double left,
  required double right,
  required double floor,
  required double tolerance,
}) {
  for (final circle in circles) {
    expect(circle.x - circle.radius, greaterThanOrEqualTo(left - tolerance));
    expect(circle.x + circle.radius, lessThanOrEqualTo(right + tolerance));
    expect(circle.y + circle.radius, lessThanOrEqualTo(floor + tolerance));
  }
}

double _hypot(double x, double y) {
  return math.sqrt(x * x + y * y);
}
