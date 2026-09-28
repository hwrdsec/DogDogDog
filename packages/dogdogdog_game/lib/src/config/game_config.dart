import 'physics_config.dart';

/// High-level game defaults that hosts and future HUD layers can share.
class GameConfig {
  const GameConfig({
    this.physics = PhysicsConfig.defaults,
    this.startingLevel = 1,
    this.maxDogLevel = 11,
    this.dropCooldownSeconds = 0.35,
  });

  final PhysicsConfig physics;

  /// Lowest dog merge level the player can drop.
  final int startingLevel;

  /// Highest merge level currently defined.
  final int maxDogLevel;

  /// Minimum delay between drops.
  final double dropCooldownSeconds;

  static const GameConfig defaults = GameConfig();
}
