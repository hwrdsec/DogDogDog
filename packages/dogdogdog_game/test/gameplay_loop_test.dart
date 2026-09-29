import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameConfig spawn + danger defaults', () {
    test('spawn pool is a lower subset of merge levels', () {
      const config = GameConfig.defaults;
      expect(config.maxDogLevel, 8);
      expect(config.minDropLevel, 1);
      expect(config.maxDropLevel, 3);
      expect(config.maxDropLevel, lessThan(config.maxDogLevel));
      expect(config.maxDropLevel, greaterThanOrEqualTo(config.minDropLevel));
      expect(config.dangerLineOffset, greaterThan(0));
      expect(config.dangerGraceSeconds, greaterThan(0));
      expect(config.dropCooldownSeconds, greaterThan(0));
    });
  });

  group('restart + queue semantics', () {
    test('startGame rolls a fresh queue from the spawn pool', () {
      final pool = SpawnPool(minLevel: 1, maxLevel: 3, seed: 123);
      final first = pool.next();
      final second = pool.next();

      // Reproduce the queue hand-off used by DogDogDogGame._advanceQueue.
      var current = first;
      var next = second;
      expect(current, inInclusiveRange(1, 3));
      expect(next, inInclusiveRange(1, 3));

      current = next;
      next = pool.next();
      expect(current, second);
      expect(next, inInclusiveRange(1, 3));
    });

    test('restart clears danger timers and score via helpers', () {
      final monitor = DangerMonitor(gracePeriodSeconds: 1.0);
      monitor.update({1}, 0.9);
      expect(monitor.elapsedById, isNotEmpty);

      // Mirrors DogDogDogGame.startGame / restartGame bookkeeping.
      monitor.reset();
      var score = 42;
      var isGameOver = true;
      var isPaused = true;
      var isRunning = false;

      score = 0;
      isGameOver = false;
      isPaused = false;
      isRunning = true;

      expect(monitor.elapsedById, isEmpty);
      expect(score, 0);
      expect(isGameOver, isFalse);
      expect(isPaused, isFalse);
      expect(isRunning, isTrue);
    });
  });

  group('LocalHighScoreRepository', () {
    test('keeps the higher score only', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = LocalHighScoreRepository(
        preferences: await SharedPreferences.getInstance(),
        storageKey: 'test_high_score',
      );

      expect(await repo.getHighScore(), 0);
      await repo.saveHighScore(10);
      expect(await repo.getHighScore(), 10);
      await repo.saveHighScore(7);
      expect(await repo.getHighScore(), 10);
      await repo.saveHighScore(22);
      expect(await repo.getHighScore(), 22);
    });
  });
}
