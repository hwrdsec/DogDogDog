import 'package:flutter/painting.dart';

/// Placeholder description of a single dog merge level.
class DogDefinition {
  const DogDefinition({
    required this.level,
    required this.name,
    required this.radius,
    required this.color,
    required this.scoreValue,
  });

  /// Merge tier, starting at 1.
  final int level;

  /// Display name for HUD / debug.
  final String name;

  /// Collision radius in world units.
  final double radius;

  /// Placeholder tint until real artwork lands.
  final Color color;

  /// Points awarded when this dog is created by a merge.
  final int scoreValue;
}

/// Short placeholder catalog — not the full gameplay roster.
const List<DogDefinition> placeholderDogs = [
  DogDefinition(
    level: 1,
    name: 'Puppy',
    radius: 0.35,
    color: Color(0xFFFFC107),
    scoreValue: 1,
  ),
  DogDefinition(
    level: 2,
    name: 'Mutt',
    radius: 0.45,
    color: Color(0xFFFF9800),
    scoreValue: 3,
  ),
  DogDefinition(
    level: 3,
    name: 'Buddy',
    radius: 0.55,
    color: Color(0xFFFF5722),
    scoreValue: 7,
  ),
];
