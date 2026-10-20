import 'package:flutter/painting.dart';

/// Data-driven description of a single dog merge level.
///
/// Placeholders use [color] / [emoji] / [level]. Real sprites can later load
/// from [spriteAsset] without changing merge or physics code.
class DogDefinition {
  const DogDefinition({
    required this.level,
    required this.name,
    required this.radius,
    required this.color,
    required this.scoreValue,
    this.emoji = '🐶',
    this.spriteAsset,
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

  /// Placeholder glyph shown on balls / HUD until [spriteAsset] is used.
  final String emoji;

  /// Optional package-relative sprite path (e.g. `assets/dogs/dog_03.png`).
  ///
  /// Null means render the placeholder [emoji] / [color]. Files can be dropped
  /// into `assets/dogs/` later without schema changes.
  final String? spriteAsset;
}

/// Looks up a dog by [level] in [catalog], or `null` when missing.
DogDefinition? dogAtLevel(
  int level, [
  List<DogDefinition> catalog = placeholderDogs,
]) {
  for (final dog in catalog) {
    if (dog.level == level) {
      return dog;
    }
  }
  return null;
}

/// Highest level present in [catalog], or 0 when empty.
int maxCatalogLevel([List<DogDefinition> catalog = placeholderDogs]) {
  var max = 0;
  for (final dog in catalog) {
    if (dog.level > max) {
      max = dog.level;
    }
  }
  return max;
}

/// Conventional sprite path for [level] under `assets/dogs/`.
String dogSpriteAssetForLevel(int level) {
  final padded = level.toString().padLeft(2, '0');
  return 'assets/dogs/dog_$padded.png';
}

/// Placeholder merge catalog — scores grow with level.
///
/// Eight tiers. Radii are the current playtest sizes. Drops use levels 1–3
/// (`GameConfig.maxDropLevel`); higher dogs appear only via merges. Two
/// tier-8 dogs clear instead of spawning another tier.
const List<DogDefinition> placeholderDogs = [
  DogDefinition(
    level: 1,
    name: 'Puppy',
    radius: 0.24,
    color: Color(0xFFFFC107),
    scoreValue: 1,
    emoji: '🐾',
    spriteAsset: 'assets/dogs/dog_01.png',
  ),
  DogDefinition(
    level: 2,
    name: 'Mutt',
    radius: 0.57,
    color: Color(0xFFFF9800),
    scoreValue: 3,
    emoji: '🦴',
    spriteAsset: 'assets/dogs/dog_02.png',
  ),
  DogDefinition(
    level: 3,
    name: 'Buddy',
    radius: 0.7772,
    color: Color(0xFFFF5722),
    scoreValue: 7,
    emoji: '🐶',
    spriteAsset: 'assets/dogs/dog_03.png',
  ),
  DogDefinition(
    level: 4,
    name: 'Rover',
    radius: 1.027,
    color: Color(0xFFE91E63),
    scoreValue: 15,
    emoji: '🐕',
    spriteAsset: 'assets/dogs/dog_04.png',
  ),
  DogDefinition(
    level: 5,
    name: 'Scout',
    radius: 1.488,
    color: Color(0xFF9C27B0),
    scoreValue: 31,
    emoji: '🦮',
    spriteAsset: 'assets/dogs/dog_05.png',
  ),
  DogDefinition(
    level: 6,
    name: 'Bruno',
    radius: 1.87,
    color: Color(0xFF3F51B5),
    scoreValue: 63,
    emoji: '🐕‍🦺',
    spriteAsset: 'assets/dogs/dog_06.png',
  ),
  DogDefinition(
    level: 7,
    name: 'Rex',
    radius: 2.392,
    color: Color(0xFF03A9F4),
    scoreValue: 127,
    emoji: '🐺',
    spriteAsset: 'assets/dogs/dog_07.png',
  ),
  DogDefinition(
    level: 8,
    name: 'Duke',
    radius: 3.08,
    color: Color(0xFF009688),
    scoreValue: 255,
    emoji: '🦊',
    spriteAsset: 'assets/dogs/dog_08.png',
  ),
];
