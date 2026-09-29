import 'physics_config.dart';

/// High-level game defaults that hosts and HUD layers can share.
class GameConfig {
  const GameConfig({
    this.physics = PhysicsConfig.defaults,
    this.startingLevel = 1,
    this.maxDogLevel = 8,
    this.minDropLevel = 1,
    this.maxDropLevel = 3,
    this.maxLevelClearScore,
    this.dropCooldownSeconds = 0.35,
    this.dangerLineOffset = 1.8,
    this.dangerGraceSeconds = 1.5,
  });

  final PhysicsConfig physics;

  /// Lowest dog merge level present in the catalog.
  final int startingLevel;

  /// Highest merge level currently defined.
  final int maxDogLevel;

  /// Inclusive lower bound of the player spawn pool.
  final int minDropLevel;

  /// Inclusive upper bound of the player spawn pool.
  ///
  /// Higher levels appear only via merges.
  final int maxDropLevel;

  /// Points for clearing two max-level dogs.
  ///
  /// When null, the clear awards `maxDog.scoreValue * 2 + 1`, which is
  /// higher than a normal merge that creates the max dog. Set this to
  /// override that bonus.
  final int? maxLevelClearScore;

  /// Minimum delay between drops.
  final double dropCooldownSeconds;

  /// Distance below the top of the visible world for the danger line.
  final double dangerLineOffset;

  /// How long a landed dog may stay above the danger line before game over.
  final double dangerGraceSeconds;

  static const GameConfig defaults = GameConfig();
}
