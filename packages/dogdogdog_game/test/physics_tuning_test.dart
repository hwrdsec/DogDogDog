import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PhysicsTuning', () {
    test('level falloff makes larger dogs lighter than constant density', () {
      final tuning = PhysicsTuning();
      expect(tuning.densityForLevel(1), tuning.baseDensity);
      expect(tuning.densityForLevel(8), lessThan(tuning.densityForLevel(2)));
      expect(tuning.restitution, lessThan(0.2));
      expect(tuning.linearDamping, greaterThan(0.2));
    });

    test('reset returns the code defaults', () {
      final tuning = PhysicsTuning();
      tuning.setGravityY(12);
      tuning.setRestitution(0.9);
      tuning.reset();
      expect(tuning.gravityY, PhysicsConfig.defaults.gravityY);
      expect(tuning.restitution, PhysicsConfig.defaults.ballRestitution);
    });

    test('json and the copied snippet round-trip the live values', () {
      final tuning = PhysicsTuning()
        ..setGravityY(33)
        ..setDensityFalloff(1.5)
        ..setSubStepCount(8);
      final copy = PhysicsTuning()..applyJson(tuning.toJson());
      expect(copy.gravityY, 33);
      expect(copy.densityFalloff, 1.5);
      expect(copy.subStepCount, 8);
      expect(tuning.toDartSnippet(), contains('gravityY: 33'));
      expect(tuning.toDartSnippet(), contains('densityFalloff: 1.5'));
      expect(tuning.toDartSnippet(), contains('subStepCount: 8'));
    });
  });

  group('PhysicsTuningStore', () {
    test('saves, restores, and clears slider values', () async {
      SharedPreferences.setMockInitialValues({});
      final store = PhysicsTuningStore(
        preferences: await SharedPreferences.getInstance(),
        storageKey: 'test_physics_tuning',
      );
      final tuning = PhysicsTuning()..setLinearDamping(0.8);
      await store.save(tuning);

      final restored = PhysicsTuning();
      expect(await store.restore(restored), isTrue);
      expect(restored.linearDamping, 0.8);

      await store.clear();
      final fresh = PhysicsTuning()..setLinearDamping(0.1);
      expect(await store.restore(fresh), isFalse);
      expect(fresh.linearDamping, 0.1);
    });
  });

  test('the tuning panel is registered outside release builds', () {
    expect(DogDogDogOverlays.physicsTuningAvailable, isTrue);
    expect(
      DogDogDogOverlays.builders().containsKey(DogDogDogOverlays.physicsTuning),
      isTrue,
    );
  });
}
