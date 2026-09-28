import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhysicsConfig', () {
    test('defaults expose a fixed world width and gravity', () {
      const config = PhysicsConfig.defaults;

      expect(config.worldWidth, 10.0);
      expect(config.gravityY, 40.0);
      expect(config.timeStep, closeTo(1 / 60, 1e-9));
      expect(config.velocityIterations, 8);
      expect(config.positionIterations, 3);
    });
  });

  group('DogDefinition', () {
    test('placeholder catalog starts at level 1', () {
      expect(placeholderDogs, isNotEmpty);
      expect(placeholderDogs.first.level, 1);
      expect(placeholderDogs.first.name, 'Puppy');
      expect(placeholderDogs.first.radius, greaterThan(0));
    });
  });

  group('GameConfig', () {
    test('defaults wrap physics defaults', () {
      const config = GameConfig.defaults;

      expect(config.physics.worldWidth, PhysicsConfig.defaults.worldWidth);
      expect(config.startingLevel, 1);
      expect(config.maxDogLevel, greaterThanOrEqualTo(config.startingLevel));
    });
  });
}
