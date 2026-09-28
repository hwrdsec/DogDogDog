import 'dart:math';

import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpawnPool', () {
    test('draws only within the configured inclusive range', () {
      final pool = SpawnPool(minLevel: 1, maxLevel: 5, seed: 42);
      final seen = <int>{};
      for (var i = 0; i < 200; i++) {
        final level = pool.next();
        expect(level, inInclusiveRange(1, 5));
        seen.add(level);
      }
      expect(seen, containsAll([1, 2, 3, 4, 5]));
    });

    test('same seed produces the same sequence', () {
      final a = SpawnPool(minLevel: 1, maxLevel: 5, seed: 7);
      final b = SpawnPool(minLevel: 1, maxLevel: 5, seed: 7);
      final seqA = List.generate(20, (_) => a.next());
      final seqB = List.generate(20, (_) => b.next());
      expect(seqA, seqB);
    });

    test('injected Random is used', () {
      final pool = SpawnPool(minLevel: 2, maxLevel: 4, random: Random(99));
      for (var i = 0; i < 50; i++) {
        expect(pool.next(), inInclusiveRange(2, 4));
      }
    });

    test('single-level pool always returns that level', () {
      final pool = SpawnPool(minLevel: 3, maxLevel: 3, seed: 1);
      expect(List.generate(10, (_) => pool.next()), everyElement(3));
    });
  });
}
