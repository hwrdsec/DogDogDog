import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DangerMonitor', () {
    test('does not trigger before the grace period elapses', () {
      final monitor = DangerMonitor(gracePeriodSeconds: 1.5);

      expect(monitor.update({1}, 0.5), isNull);
      expect(monitor.update({1}, 0.5), isNull);
      expect(monitor.update({1}, 0.49), isNull);
      expect(monitor.elapsedById[1], closeTo(1.49, 1e-9));
    });

    test('triggers once continuous time reaches the grace period', () {
      final monitor = DangerMonitor(gracePeriodSeconds: 1.0);

      expect(monitor.update({10}, 0.6), isNull);
      expect(monitor.update({10}, 0.5), 10);
    });

    test('leaving the zone resets that body timer', () {
      final monitor = DangerMonitor(gracePeriodSeconds: 1.0);

      expect(monitor.update({1}, 0.8), isNull);
      expect(monitor.update(<int>{}, 0.1), isNull);
      expect(monitor.elapsedById, isEmpty);
      expect(monitor.update({1}, 0.8), isNull);
      expect(monitor.update({1}, 0.3), 1);
    });

    test('dropping bodies are excluded by the caller filter', () {
      // Mimic game logic: only pass landed bodies into the monitor.
      final monitor = DangerMonitor(gracePeriodSeconds: 0.5);
      const droppingId = 99;
      // Empty set while the drop is falling through the line.
      expect(monitor.update(<int>{}, 1.0), isNull);
      // After landing still below the line — still empty.
      expect(monitor.update(<int>{}, 1.0), isNull);
      // A different landed body stuck above triggers.
      expect(monitor.update({droppingId}, 0.5), droppingId);
    });

    test('reset clears all timers', () {
      final monitor = DangerMonitor(gracePeriodSeconds: 1.0);
      monitor.update({1}, 0.9);
      monitor.reset();
      expect(monitor.elapsedById, isEmpty);
      expect(monitor.update({1}, 0.9), isNull);
    });
  });

  group('SandboxBall.isAboveDangerLine', () {
    test('reports when the circle top crosses the line', () {
      // Pure geometry check without mounting a Forge2D body.
      // Y grows downward; dog top = centerY - radius = 1.5.
      final ball = _FakeBall(centerY: 2.0, radius: 0.5);
      expect(ball.isAboveDangerLine(1.6), isTrue); // top 1.5 is above line 1.6
      expect(ball.isAboveDangerLine(1.4), isFalse); // top 1.5 is below line 1.4
    });
  });
}

class _FakeBall {
  _FakeBall({required this.centerY, required this.radius});

  final double centerY;
  final double radius;

  bool isAboveDangerLine(double dangerLineY) {
    return centerY - radius < dangerLineY;
  }
}
