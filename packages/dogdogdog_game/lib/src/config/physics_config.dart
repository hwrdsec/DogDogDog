/// Centralized physics defaults for the Forge2D world.
///
/// Values are placeholders for Milestone 1; gameplay systems will consume
/// them in later milestones.
class PhysicsConfig {
  const PhysicsConfig({
    this.gravityY = 40.0,
    this.worldWidth = 10.0,
    this.timeStep = 1 / 60,
    this.velocityIterations = 8,
    this.positionIterations = 3,
  });

  /// Downward gravity in world units per second squared.
  final double gravityY;

  /// Fixed horizontal extent of the playable world (world units).
  final double worldWidth;

  /// Simulation step size in seconds.
  final double timeStep;

  final int velocityIterations;
  final int positionIterations;

  static const PhysicsConfig defaults = PhysicsConfig();
}
