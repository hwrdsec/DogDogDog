import 'dart:math' as math;

/// Centralized physics defaults for the Forge2D world.
class PhysicsConfig {
  const PhysicsConfig({
    this.gravityY = 48,
    this.worldWidth = 10.0,
    this.visibleWorldHeight = 16.0,
    this.timeStep = 1 / 60,
    this.subStepCount = 6,
    this.overlapIterations = 12,
    this.ballRadius = 0.4,
    this.ballDensity = 1.2,
    this.densityFalloff = 2,
    this.ballRestitution = 0.12,
    this.ballFriction = 0.55,
    this.ballAngularDamping = 1.5,
    this.ballLinearDamping = 0.35,
    this.wallFriction = 0.5,
    this.wallRestitution = 0.05,
    this.spawnTopOffset = 0.75,
  });

  /// Downward gravity in world units per second squared.
  final double gravityY;

  /// Fixed horizontal extent of the playable world (world units).
  ///
  /// 10 is clearly under two level-8 diameters (12.32), so two top dogs cannot
  /// rest side by side. One still has room to slide.
  final double worldWidth;

  /// Fixed vertical extent of the playable world (world units).
  ///
  /// Paired with [worldWidth] as a 10×16 portrait bucket. The camera
  /// letterboxes (pillarboxes) on wider windows so gameplay proportions stay
  /// the same across phones, tablets, and desktop.
  final double visibleWorldHeight;

  /// Width / height of the playfield (`worldWidth / visibleWorldHeight`).
  double get playAspectRatio => worldWidth / visibleWorldHeight;

  /// Simulation step size in seconds.
  final double timeStep;

  /// Box2D sub-steps per frame. Higher keeps stacks from sinking.
  final int subStepCount;

  /// How many passes the overlap correction runs after each physics step.
  final int overlapIterations;

  /// Default radius for sandbox circles (world units).
  final double ballRadius;

  /// Density of a level-1 dog, in kilograms per square meter.
  ///
  /// Higher levels use [densityForLevel].
  final double ballDensity;

  /// How quickly density drops as the merge level rises.
  ///
  /// `0` keeps every level at [ballDensity], so mass grows with area. `2`
  /// makes a level-8 dog only a few times heavier than a level-1 dog.
  final double densityFalloff;

  /// Bounciness of sandbox circles.
  final double ballRestitution;

  /// Surface friction of sandbox circles.
  final double ballFriction;

  /// Angular damping so spinning settles into rolling.
  final double ballAngularDamping;

  /// Linear damping. Higher values kill bounce and make dogs feel heavier.
  final double ballLinearDamping;

  /// Friction applied to boundary walls / floor.
  final double wallFriction;

  /// Restitution applied to boundary walls / floor.
  final double wallRestitution;

  /// Distance below the top of the visible world where drops spawn.
  final double spawnTopOffset;

  /// Density for a dog of [level].
  ///
  /// `ballDensity * level^(-densityFalloff)`.
  double densityForLevel(int level) {
    return densityFor(
      level: level,
      baseDensity: ballDensity,
      falloff: densityFalloff,
    );
  }

  static double densityFor({
    required int level,
    required double baseDensity,
    required double falloff,
  }) {
    if (falloff <= 0 || level <= 1) {
      return baseDensity;
    }
    return baseDensity * math.pow(level, -falloff).toDouble();
  }

  static const PhysicsConfig defaults = PhysicsConfig();
}
