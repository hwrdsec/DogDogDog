import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MergeRules rules;

  setUp(() {
    rules = const MergeRules(maxLevel: 8);
  });

  group('canMerge', () {
    test('same level below max can merge when next definition exists', () {
      expect(rules.canMerge(1, 1), isTrue);
      expect(rules.nextLevel(1), 2);
    });

    test('different levels cannot merge', () {
      expect(rules.canMerge(1, 2), isFalse);
      expect(rules.canMerge(3, 2), isFalse);
    });

    test('max level merges as a clear with no next tier', () {
      expect(rules.canMerge(8, 8), isTrue);
      expect(rules.nextLevel(8), isNull);
    });

    test('levels above the cap cannot merge', () {
      expect(rules.canMerge(9, 9), isFalse);
      expect(rules.nextLevel(9), isNull);
    });

    test('configured max level clears instead of spawning past the cap', () {
      const capped = MergeRules(maxLevel: 3, maxLevelClearScore: 40);
      expect(capped.canMerge(2, 2), isTrue);
      expect(capped.nextLevel(2), 3);
      expect(capped.canMerge(3, 3), isTrue);
      expect(capped.nextLevel(3), isNull);
      expect(capped.canMerge(4, 4), isFalse);

      final outcomes = capped.resolve([
        const MergePair(idA: 1, idB: 2, level: 3, contactX: 0, contactY: 0),
      ]);
      expect(outcomes, hasLength(1));
      expect(outcomes.single.clearsPair, isTrue);
      expect(outcomes.single.resultingLevel, isNull);
      expect(outcomes.single.scoreAwarded, 40);
    });
  });

  group('scoreForResultingLevel', () {
    test('returns the resulting dog scoreValue', () {
      expect(rules.scoreForResultingLevel(2), placeholderDogs[1].scoreValue);
      expect(rules.scoreForResultingLevel(3), placeholderDogs[2].scoreValue);
      expect(rules.scoreForResultingLevel(1), placeholderDogs[0].scoreValue);
    });

    test('returns 0 for an unknown level', () {
      expect(rules.scoreForResultingLevel(99), 0);
    });

    test('max-level clear score is above a merge into the max dog', () {
      final intoMax = rules.scoreForResultingLevel(8);
      expect(intoMax, placeholderDogs.last.scoreValue);
      expect(rules.scoreForMaxLevelClear(), greaterThan(intoMax));
      expect(
        rules.scoreForMaxLevelClear(),
        placeholderDogs.last.scoreValue * 2 + 1,
      );

      const custom = MergeRules(maxLevel: 8, maxLevelClearScore: 800);
      expect(custom.scoreForMaxLevelClear(), 800);
    });
  });

  group('resolve', () {
    test('valid merge produces one outcome with next level and score', () {
      final outcomes = rules.resolve([
        const MergePair(
          idA: 10,
          idB: 20,
          level: 1,
          contactX: 1.5,
          contactY: 2.5,
        ),
      ]);

      expect(outcomes, hasLength(1));
      final outcome = outcomes.single;
      expect(outcome.idA, 10);
      expect(outcome.idB, 20);
      expect(outcome.resultingLevel, 2);
      expect(outcome.spawnX, 1.5);
      expect(outcome.spawnY, 2.5);
      expect(outcome.scoreAwarded, rules.scoreForResultingLevel(2));
    });

    test('merge into the max level still spawns that dog', () {
      final outcomes = rules.resolve([
        const MergePair(idA: 1, idB: 2, level: 7, contactX: 0, contactY: 0),
      ]);

      expect(outcomes, hasLength(1));
      expect(outcomes.single.clearsPair, isFalse);
      expect(outcomes.single.resultingLevel, 8);
      expect(outcomes.single.scoreAwarded, rules.scoreForResultingLevel(8));
      expect(
        outcomes.single.scoreAwarded,
        lessThan(rules.scoreForMaxLevelClear()),
      );
    });

    test('max-level merge clears both dogs and awards the bonus', () {
      final outcomes = rules.resolve([
        const MergePair(idA: 4, idB: 9, level: 8, contactX: 3, contactY: 4),
      ]);

      expect(outcomes, hasLength(1));
      final outcome = outcomes.single;
      expect(outcome.clearsPair, isTrue);
      expect(outcome.resultingLevel, isNull);
      expect(outcome.idA, 4);
      expect(outcome.idB, 9);
      expect(outcome.spawnX, 3);
      expect(outcome.spawnY, 4);
      expect(outcome.scoreAwarded, rules.scoreForMaxLevelClear());
    });

    test('duplicate max-level reports clear only once', () {
      final outcomes = rules.resolve([
        const MergePair(idA: 4, idB: 9, level: 8, contactX: 1, contactY: 2),
        const MergePair(idA: 9, idB: 4, level: 8, contactX: 5, contactY: 6),
        const MergePair(idA: 4, idB: 9, level: 8, contactX: 7, contactY: 8),
      ]);

      expect(outcomes, hasLength(1));
      expect(outcomes.single.clearsPair, isTrue);
      expect(outcomes.single.scoreAwarded, rules.scoreForMaxLevelClear());
      expect(outcomes.single.spawnX, 1);
      expect(outcomes.single.spawnY, 2);
    });

    test('one max-level dog cannot clear twice in the same pass', () {
      final outcomes = rules.resolve([
        const MergePair(idA: 1, idB: 2, level: 8, contactX: 0, contactY: 0),
        const MergePair(idA: 2, idB: 3, level: 8, contactX: 1, contactY: 1),
      ]);

      expect(outcomes, hasLength(1));
      expect(outcomes.single.idA, 1);
      expect(outcomes.single.idB, 2);
      expect(outcomes.single.clearsPair, isTrue);
    });

    test('a level above the catalog yields nothing', () {
      final outcomes = rules.resolve([
        const MergePair(idA: 1, idB: 2, level: 9, contactX: 0, contactY: 0),
      ]);
      expect(outcomes, isEmpty);
    });

    test('custom clear score is awarded on resolve', () {
      const custom = MergeRules(maxLevel: 8, maxLevelClearScore: 800);
      final outcomes = custom.resolve([
        const MergePair(idA: 1, idB: 2, level: 8, contactX: 0, contactY: 0),
      ]);
      expect(outcomes.single.scoreAwarded, 800);
      expect(outcomes.single.resultingLevel, isNull);
    });

    test('duplicate reports of the same pair spawn only once', () {
      final outcomes = rules.resolve([
        const MergePair(idA: 5, idB: 8, level: 2, contactX: 0, contactY: 0),
        const MergePair(idA: 8, idB: 5, level: 2, contactX: 1, contactY: 1),
        const MergePair(idA: 5, idB: 8, level: 2, contactX: 2, contactY: 2),
      ]);

      expect(outcomes, hasLength(1));
      expect(outcomes.single.idA, 5);
      expect(outcomes.single.idB, 8);
      expect(outcomes.single.resultingLevel, 3);
      // First normalized insert wins for contact position.
      expect(outcomes.single.spawnX, 0);
      expect(outcomes.single.spawnY, 0);
    });

    test('shared body across pairs participates in only one merge', () {
      final outcomes = rules.resolve([
        const MergePair(idA: 1, idB: 2, level: 1, contactX: 0, contactY: 0),
        const MergePair(idA: 2, idB: 3, level: 1, contactX: 4, contactY: 4),
        const MergePair(idA: 3, idB: 4, level: 1, contactX: 8, contactY: 8),
      ]);

      // Sorted by (idA, idB): (1,2) then (2,3) then (3,4).
      // (1,2) consumes 1 and 2; (2,3) skipped; (3,4) consumes 3 and 4.
      expect(outcomes, hasLength(2));
      expect(outcomes[0].idA, 1);
      expect(outcomes[0].idB, 2);
      expect(outcomes[1].idA, 3);
      expect(outcomes[1].idB, 4);
    });

    test('self-pair is ignored', () {
      final outcomes = rules.resolve([
        const MergePair(idA: 7, idB: 7, level: 1, contactX: 0, contactY: 0),
      ]);
      expect(outcomes, isEmpty);
    });
  });

  group('dogAtLevel', () {
    test('finds catalog entries by level', () {
      expect(dogAtLevel(1)?.name, 'Puppy');
      expect(dogAtLevel(8)?.name, 'Duke');
      expect(dogAtLevel(8)?.radius, 3.08);
      expect(dogAtLevel(11), isNull);
      expect(dogAtLevel(99), isNull);
    });
  });
}
