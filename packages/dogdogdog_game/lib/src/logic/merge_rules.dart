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

  /// Dog level to spawn. Null when the pair is a max-level clear.
  final int? resultingLevel;

  final double spawnX;
  final double spawnY;
  final int scoreAwarded;

  /// True when both dogs are removed and nothing is spawned.
  bool get clearsPair => resultingLevel == null;
}

/// Pure, testable merge policy for DogDogDog.
///
/// Same level below [maxLevel] → remove both, spawn [level + 1] at the
/// contact point, award that dog's [DogDefinition.scoreValue]. Two dogs at
/// [maxLevel] clear (both removed, nothing spawned) and award
/// [scoreForMaxLevelClear]. Each body participates in at most one merge per
/// resolve pass.
class MergeRules {
  const MergeRules({
    required this.maxLevel,
    this.catalog = placeholderDogs,
    this.maxLevelClearScore,
  });

  /// Highest level that may exist.
  ///
  /// Merging two dogs at this level clears them instead of spawning a
  /// higher tier.
  final int maxLevel;

  /// Dog catalog used for next-level lookup and scoring.
  final List<DogDefinition> catalog;

  /// Override for [scoreForMaxLevelClear]. Null uses the default formula.
  final int? maxLevelClearScore;

  /// Definition for [level], or `null` when the catalog has no entry.
  DogDefinition? definitionFor(int level) => dogAtLevel(level, catalog);

  /// Whether two dogs at [levelA] / [levelB] are allowed to merge.
  ///
  /// Matching levels below [maxLevel] merge when the next dog exists. Two
  /// dogs already at [maxLevel] merge as a clear.
  bool canMerge(int levelA, int levelB) {
    if (levelA != levelB) {
      return false;
    }
    if (definitionFor(levelA) == null || levelA > maxLevel) {
      return false;
    }
    if (levelA == maxLevel) {
      return true;
    }
    return definitionFor(levelA + 1) != null;
  }

  /// Points awarded when a dog of [resultingLevel] is created by a merge.
  int scoreForResultingLevel(int resultingLevel) {
    return definitionFor(resultingLevel)?.scoreValue ?? 0;
  }

  /// Points awarded when two max-level dogs clear.
  ///
  /// Uses [maxLevelClearScore] when set. Otherwise continues the catalog
  /// series (`scoreValue * 2 + 1` of the max dog), which is higher than a
  /// normal merge into that dog.
  int scoreForMaxLevelClear() {
    final configured = maxLevelClearScore;
    if (configured != null) {
      return configured;
    }
    final base = definitionFor(maxLevel)?.scoreValue ?? 0;
    return base * 2 + 1;
  }

  /// Next merge tier after [level], or `null` for a clear or a blocked merge.
  int? nextLevel(int level) {
    if (level >= maxLevel || !canMerge(level, level)) {
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
      final int? resulting;
      final int score;
      if (pair.level == maxLevel) {
        resulting = null;
        score = scoreForMaxLevelClear();
      } else {
        resulting = pair.level + 1;
        score = scoreForResultingLevel(resulting);
      }
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
          scoreAwarded: score,
        ),
      );
    }

    return outcomes;
  }
}
