import 'dart:math' as math;

/// A circle being packed into the bucket.
///
/// [x] and [y] are updated in place. [inverseMass] is zero for a circle that
/// should not move.
class PackedCircle {
  PackedCircle({
    required this.x,
    required this.y,
    required this.radius,
    this.inverseMass = 1,
  });

  double x;
  double y;
  final double radius;
  final double inverseMass;
}

/// Pushes [circles] apart inside a bucket so they do not rest inside each
/// other or the walls.
///
/// Box2D only separates two circles along the line between their centers.
/// In a bucket narrower than those two diameters that line is horizontal and
/// the walls block it, so the circles fall asleep still overlapping. When a
/// wall rejects that sideways motion, the leftover overlap is taken upward
/// (smaller y) and the upper circle climbs onto the lower one.
void separatePackedCircles(
  List<PackedCircle> circles, {
  required double left,
  required double right,
  required double floor,
  int iterations = 12,
}) {
  for (var n = 0; n < iterations; n++) {
    for (final circle in circles) {
      _clampToBucket(circle, left: left, right: right, floor: floor);
    }
    for (var i = 0; i < circles.length; i++) {
      for (var j = i + 1; j < circles.length; j++) {
        _separatePair(
          circles[i],
          circles[j],
          left: left,
          right: right,
          floor: floor,
        );
      }
    }
  }
}

void _clampToBucket(
  PackedCircle circle, {
  required double left,
  required double right,
  required double floor,
}) {
  final minX = left + circle.radius;
  final maxX = right - circle.radius;
  if (minX <= maxX) {
    circle.x = circle.x.clamp(minX, maxX).toDouble();
  }
  final maxY = floor - circle.radius;
  if (circle.y > maxY) {
    circle.y = maxY;
  }
}

void _separatePair(
  PackedCircle a,
  PackedCircle b, {
  required double left,
  required double right,
  required double floor,
}) {
  var dx = b.x - a.x;
  var dy = b.y - a.y;
  var distance = math.sqrt(dx * dx + dy * dy);
  final minDistance = a.radius + b.radius;
  if (distance >= minDistance) {
    return;
  }
  if (distance < 1e-8) {
    dx = 0;
    dy = -1;
    distance = 1e-8;
  }
  final penetration = minDistance - distance;
  final nx = dx / distance;
  final ny = dy / distance;
  final inverse = a.inverseMass + b.inverseMass;
  if (inverse == 0) {
    return;
  }
  final moveA = penetration * (a.inverseMass / inverse);
  final moveB = penetration * (b.inverseMass / inverse);
  var ax = a.x - nx * moveA;
  var ay = a.y - ny * moveA;
  var bx = b.x + nx * moveB;
  var by = b.y + ny * moveB;

  ax = _clampX(ax, a.radius, left, right);
  bx = _clampX(bx, b.radius, left, right);

  final horizontal = bx - ax;
  final verticalGap = math.sqrt(
    math.max(0, minDistance * minDistance - horizontal * horizontal),
  );
  if ((by - ay).abs() < verticalGap) {
    if (ay <= by) {
      ay = by - verticalGap;
    } else {
      by = ay - verticalGap;
    }
  }

  ay = math.min(ay, floor - a.radius);
  by = math.min(by, floor - b.radius);
  if ((by - ay).abs() < verticalGap) {
    if (ay <= by) {
      ay = math.min(ay, by - verticalGap);
    } else {
      by = math.min(by, ay - verticalGap);
    }
  }

  a.x = ax;
  a.y = ay;
  b.x = bx;
  b.y = by;
}

double _clampX(double x, double radius, double left, double right) {
  final minX = left + radius;
  final maxX = right - radius;
  if (minX > maxX) {
    return x;
  }
  return x.clamp(minX, maxX).toDouble();
}
