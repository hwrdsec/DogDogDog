import '../models/dog_definition.dart';

/// A same-level contact that wants to merge, identified by stable body ids.
class MergePair {
  const MergePair({
    required this.idA,
    required this.idB,
    required this.level,
    required this.contactX,
    required this.contactY,
  });

  /// Opaque identity of the first body (e.g. [identityHashCode]).
  final int idA;

  /// Opaque identity of the second body.
  final int idB;

  /// Shared merge level of both bodies.
  final int level;

  /// Contact / midpoint X in world units.
  final double contactX;

  /// Contact / midpoint Y in world units.
  final double contactY;
}

/// One successful merge after conflict resolution.
class MergeOutcome {
  const MergeOutcome({
    required this.idA,
    required this.idB,
    required this.resultingLevel,
    required this.spawnX,
    required this.spawnY,
    required this.scoreAwarded,
  });

  final int idA;
  final int idB;
  final int resultingLevel;
  final double spawnX;
  final double spawnY;
  final int scoreAwarded;
}

/// Pure, testable merge policy for DogDogDog.
///
/// Same level + room to grow → remove both, spawn [level + 1] at the contact
/// point, award that dog's [DogDefinition.scoreValue]. Each body participates
/// in at most one merge per resolve pass.
class MergeRules {
  const MergeRules({required this.maxLevel, this.catalog = placeholderDogs});

  /// Highest level that may exist; that level cannot merge further.
  final int maxLevel;

  /// Dog catalog used for next-level lookup and scoring.
  final List<DogDefinition> catalog;

  /// Definition for [level], or `null` when the catalog has no entry.
  DogDefinition? definitionFor(int level) => dogAtLevel(level, catalog);

  /// Whether two dogs at [levelA] / [levelB] are allowed to merge.
  bool canMerge(int levelA, int levelB) {
    if (levelA != levelB) {
      return false;
    }
    if (levelA >= maxLevel) {
      return false;
    }
    return definitionFor(levelA + 1) != null;
  }

  /// Points awarded when a dog of [resultingLevel] is created by a merge.
  int scoreForResultingLevel(int resultingLevel) {
    return definitionFor(resultingLevel)?.scoreValue ?? 0;
  }

  /// Next merge tier after [level], or `null` when blocked / missing.
  int? nextLevel(int level) {
    if (!canMerge(level, level)) {
      return null;
    }
    return level + 1;
  }

  /// Deterministically pick a conflict-free set of merges from [candidates].
  ///
  /// - Pairs are normalized so `idA < idB`.
  /// - Duplicate pair reports collapse to one.
  /// - Pairs that fail [canMerge] are dropped.
  /// - Each body id is consumed by at most one outcome (first wins in sorted
  ///   order of `(idA, idB)`).
  List<MergeOutcome> resolve(Iterable<MergePair> candidates) {
    final normalized = <String, MergePair>{};

    for (final pair in candidates) {
      if (!canMerge(pair.level, pair.level)) {
        continue;
      }
      final low = pair.idA < pair.idB ? pair.idA : pair.idB;
      final high = pair.idA < pair.idB ? pair.idB : pair.idA;
      if (low == high) {
        continue;
      }
      final key = '$low:$high';
      normalized.putIfAbsent(
        key,
        () => MergePair(
          idA: low,
          idB: high,
          level: pair.level,
          contactX: pair.contactX,
          contactY: pair.contactY,
        ),
      );
    }

    final sorted = normalized.values.toList()
      ..sort((a, b) {
        final byA = a.idA.compareTo(b.idA);
        if (byA != 0) {
          return byA;
        }
        return a.idB.compareTo(b.idB);
      });

    final used = <int>{};
    final outcomes = <MergeOutcome>[];

    for (final pair in sorted) {
      if (used.contains(pair.idA) || used.contains(pair.idB)) {
        continue;
      }
      final resulting = pair.level + 1;
      used
        ..add(pair.idA)
        ..add(pair.idB);
      outcomes.add(
        MergeOutcome(
          idA: pair.idA,
          idB: pair.idB,
          resultingLevel: resulting,
          spawnX: pair.contactX,
          spawnY: pair.contactY,
          scoreAwarded: scoreForResultingLevel(resulting),
        ),
      );
    }

    return outcomes;
  }
}
