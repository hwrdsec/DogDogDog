import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhysicsConfig', () {
    test('defaults expose a fixed playfield width, height, and gravity', () {
      const config = PhysicsConfig.defaults;

      expect(config.worldWidth, 10.0);
      expect(config.visibleWorldHeight, 16.0);
      expect(config.playAspectRatio, closeTo(10.0 / 16.0, 1e-9));
      expect(config.gravityY, 40.0);
      expect(config.timeStep, closeTo(1 / 60, 1e-9));
      expect(config.velocityIterations, 8);
      expect(config.positionIterations, 3);
    });

    test('defaults centralize ball and wall material values', () {
      const config = PhysicsConfig.defaults;

      expect(config.ballRadius, greaterThan(0));
      expect(config.ballDensity, greaterThan(0));
      expect(config.ballRestitution, inInclusiveRange(0, 1));
      expect(config.ballFriction, greaterThan(0));
      expect(config.wallFriction, greaterThan(0));
      expect(config.spawnTopOffset, greaterThan(0));
    });

    test('playfield stays portrait (taller than wide)', () {
      const config = PhysicsConfig.defaults;
      expect(config.visibleWorldHeight, greaterThan(config.worldWidth));
      expect(config.playAspectRatio, lessThan(1));
    });
  });

  group('DogDefinition', () {
    test(
      'placeholder catalog has eight unique levels with emoji and paths',
      () {
        expect(placeholderDogs, hasLength(8));
        expect(placeholderDogs.first.level, 1);
        expect(placeholderDogs.first.name, 'Puppy');
        expect(placeholderDogs.first.radius, 0.48);
        expect(placeholderDogs.first.emoji, isNotEmpty);
        expect(placeholderDogs.first.spriteAsset, 'assets/dogs/dog_01.png');
        expect(placeholderDogs.last.level, 8);
        expect(placeholderDogs.last.name, 'Duke');
        expect(placeholderDogs.last.radius, 1.54);
        expect(placeholderDogs.last.spriteAsset, 'assets/dogs/dog_08.png');
        expect(maxCatalogLevel(), GameConfig.defaults.maxDogLevel);
        expect(
          placeholderDogs.map((d) => d.level).toSet().length,
          placeholderDogs.length,
        );
        for (final dog in placeholderDogs) {
          expect(dog.emoji, isNotEmpty);
          expect(dog.spriteAsset, dogSpriteAssetForLevel(dog.level));
          expect(dog.scoreValue, greaterThan(0));
          expect(dog.radius, greaterThan(0));
        }
      },
    );

    test('radii grow monotonically with level', () {
      for (var i = 1; i < placeholderDogs.length; i++) {
        expect(
          placeholderDogs[i].radius,
          greaterThan(placeholderDogs[i - 1].radius),
        );
      }
    });
  });

  group('GameConfig', () {
    test('defaults wrap physics, spawn pool, cooldown, and danger', () {
      const config = GameConfig.defaults;

      expect(config.physics.worldWidth, PhysicsConfig.defaults.worldWidth);
      expect(
        config.physics.visibleWorldHeight,
        PhysicsConfig.defaults.visibleWorldHeight,
      );
      expect(config.startingLevel, 1);
      expect(config.maxDogLevel, 8);
      expect(config.maxDogLevel, greaterThanOrEqualTo(config.startingLevel));
      expect(config.minDropLevel, 1);
      expect(config.maxDropLevel, 3);
      expect(config.maxDropLevel, lessThan(config.maxDogLevel));
      expect(config.maxLevelClearScore, isNull);
      expect(config.dropCooldownSeconds, greaterThan(0));
      expect(config.dangerLineOffset, greaterThan(0));
      expect(config.dangerGraceSeconds, greaterThan(0));
    });
  });
}
