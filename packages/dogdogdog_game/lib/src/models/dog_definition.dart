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

/// Placeholder merge catalog — radii and scores grow with level.
///
/// Eleven tiers: drops use the lower subset (`GameConfig.maxDropLevel`);
/// higher dogs appear only via merges. Sprites are optional later.
const List<DogDefinition> placeholderDogs = [
  DogDefinition(
    level: 1,
    name: 'Puppy',
    radius: 0.32,
    color: Color(0xFFFFC107),
    scoreValue: 1,
    emoji: '🐾',
    spriteAsset: 'assets/dogs/dog_01.png',
  ),
  DogDefinition(
    level: 2,
    name: 'Mutt',
    radius: 0.40,
    color: Color(0xFFFF9800),
    scoreValue: 3,
    emoji: '🦴',
    spriteAsset: 'assets/dogs/dog_02.png',
  ),
  DogDefinition(
    level: 3,
    name: 'Buddy',
    radius: 0.48,
    color: Color(0xFFFF5722),
    scoreValue: 7,
    emoji: '🐶',
    spriteAsset: 'assets/dogs/dog_03.png',
  ),
  DogDefinition(
    level: 4,
    name: 'Rover',
    radius: 0.56,
    color: Color(0xFFE91E63),
    scoreValue: 15,
    emoji: '🐕',
    spriteAsset: 'assets/dogs/dog_04.png',
  ),
  DogDefinition(
    level: 5,
    name: 'Scout',
    radius: 0.64,
    color: Color(0xFF9C27B0),
    scoreValue: 31,
    emoji: '🦮',
    spriteAsset: 'assets/dogs/dog_05.png',
  ),
  DogDefinition(
    level: 6,
    name: 'Bruno',
    radius: 0.74,
    color: Color(0xFF3F51B5),
    scoreValue: 63,
    emoji: '🐕‍🦺',
    spriteAsset: 'assets/dogs/dog_06.png',
  ),
  DogDefinition(
    level: 7,
    name: 'Rex',
    radius: 0.86,
    color: Color(0xFF03A9F4),
    scoreValue: 127,
    emoji: '🐺',
    spriteAsset: 'assets/dogs/dog_07.png',
  ),
  DogDefinition(
    level: 8,
    name: 'Duke',
    radius: 1.00,
    color: Color(0xFF009688),
    scoreValue: 255,
    emoji: '🦊',
    spriteAsset: 'assets/dogs/dog_08.png',
  ),
  DogDefinition(
    level: 9,
    name: 'Chief',
    radius: 1.16,
    color: Color(0xFF4CAF50),
    scoreValue: 511,
    emoji: '🐯',
    spriteAsset: 'assets/dogs/dog_09.png',
  ),
  DogDefinition(
    level: 10,
    name: 'Titan',
    radius: 1.34,
    color: Color(0xFF8BC34A),
    scoreValue: 1023,
    emoji: '🐻',
    spriteAsset: 'assets/dogs/dog_10.png',
  ),
  DogDefinition(
    level: 11,
    name: 'Legend',
    radius: 1.54,
    color: Color(0xFFCDDC39),
    scoreValue: 2047,
    emoji: '🐉',
    spriteAsset: 'assets/dogs/dog_11.png',
  ),
];
