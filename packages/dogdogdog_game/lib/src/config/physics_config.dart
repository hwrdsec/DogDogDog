/// Centralized physics defaults for the Forge2D world.
class PhysicsConfig {
  const PhysicsConfig({
    this.gravityY = 40.0,
    this.worldWidth = 10.0,
    this.timeStep = 1 / 60,
    this.velocityIterations = 8,
    this.positionIterations = 3,
    this.ballRadius = 0.4,
    this.ballDensity = 1.0,
    this.ballRestitution = 0.45,
    this.ballFriction = 0.4,
    this.ballAngularDamping = 0.6,
    this.ballLinearDamping = 0.05,
    this.wallFriction = 0.35,
    this.wallRestitution = 0.2,
    this.spawnTopOffset = 0.75,
  });

  /// Downward gravity in world units per second squared.
  final double gravityY;

  /// Fixed horizontal extent of the playable world (world units).
  final double worldWidth;

  /// Simulation step size in seconds.
  final double timeStep;

  final int velocityIterations;
  final int positionIterations;

  /// Default radius for sandbox circles (world units).
  final double ballRadius;

  /// Mass density for sandbox circles (kg/m²).
  final double ballDensity;

  /// Bounciness of sandbox circles.
  final double ballRestitution;

  /// Surface friction of sandbox circles.
  final double ballFriction;

  /// Angular damping so spinning settles into rolling.
  final double ballAngularDamping;

  /// Light linear damping to keep stacks from jittering forever.
  final double ballLinearDamping;

  /// Friction applied to boundary walls / floor.
  final double wallFriction;

  /// Restitution applied to boundary walls / floor.
  final double wallRestitution;

  /// Distance below the top of the visible world where drops spawn.
  final double spawnTopOffset;

  static const PhysicsConfig defaults = PhysicsConfig();
}
