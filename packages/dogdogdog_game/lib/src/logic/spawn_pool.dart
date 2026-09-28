import 'dart:math';

/// Picks drop levels from a configurable inclusive range.
///
/// Higher levels are intentionally excluded so they only appear via merges.
class SpawnPool {
  SpawnPool({
    required this.minLevel,
    required this.maxLevel,
    Random? random,
    int? seed,
  }) : assert(minLevel >= 1, 'minLevel must be >= 1'),
       assert(maxLevel >= minLevel, 'maxLevel must be >= minLevel'),
       _random = random ?? (seed != null ? Random(seed) : Random());

  /// Inclusive lower bound.
  final int minLevel;

  /// Inclusive upper bound.
  final int maxLevel;

  final Random _random;

  /// Next drop level in `[minLevel, maxLevel]`.
  int next() {
    final span = maxLevel - minLevel + 1;
    return minLevel + _random.nextInt(span);
  }
}
