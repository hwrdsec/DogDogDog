import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MergeRules rules;

  setUp(() {
    rules = const MergeRules(maxLevel: 11);
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

    test('max level cannot merge further', () {
      expect(rules.canMerge(11, 11), isFalse);
      expect(rules.nextLevel(11), isNull);
    });

    test('respects a lower configured maxLevel', () {
      const capped = MergeRules(maxLevel: 3);
      expect(capped.canMerge(2, 2), isTrue);
      expect(capped.canMerge(3, 3), isFalse);
      expect(capped.nextLevel(3), isNull);
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

    test('invalid merge (different levels) yields nothing', () {
      // canMerge is checked on pair.level alone after contact filtering;
      // pairs that somehow arrive with a non-mergeable level are dropped.
      final outcomes = rules.resolve([
        const MergePair(idA: 1, idB: 2, level: 11, contactX: 0, contactY: 0),
      ]);
      expect(outcomes, isEmpty);
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
      expect(dogAtLevel(11)?.name, 'Legend');
      expect(dogAtLevel(99), isNull);
    });
  });
}
