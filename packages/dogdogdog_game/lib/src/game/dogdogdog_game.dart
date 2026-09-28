import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

import '../config/game_config.dart';
import '../persistence/high_score_repository.dart';
import '../persistence/local_high_score_repository.dart';

/// Core DogDogDog Flame / Forge2D game.
///
/// Milestone 1 ships an empty dark play area plus wiring for scores,
/// callbacks, and persistence. Gameplay arrives in later milestones.
class DogDogDogGame extends Forge2DGame {
  DogDogDogGame({
    GameConfig? config,
    HighScoreRepository? highScoreRepository,
    this.onScoreChanged,
    this.onGameStarted,
    this.onGameOver,
    this.onHighScoreChanged,
  }) : config = config ?? GameConfig.defaults,
       highScoreRepository = highScoreRepository ?? LocalHighScoreRepository(),
       super(
         gravity: Vector2(0, (config ?? GameConfig.defaults).physics.gravityY),
       );

  final GameConfig config;
  final HighScoreRepository highScoreRepository;

  final ValueChanged<int>? onScoreChanged;
  final VoidCallback? onGameStarted;
  final ValueChanged<int>? onGameOver;
  final ValueChanged<int>? onHighScoreChanged;

  int score = 0;
  int highScore = 0;
  bool isRunning = false;

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    highScore = await highScoreRepository.getHighScore();
    onHighScoreChanged?.call(highScore);
  }

  /// Starts a session. No gameplay yet — exists so hosts can wire UI early.
  void startGame() {
    score = 0;
    isRunning = true;
    onScoreChanged?.call(score);
    onGameStarted?.call();
  }

  /// Ends a session and persists a new high score when needed.
  Future<void> endGame() async {
    if (!isRunning) {
      return;
    }
    isRunning = false;
    onGameOver?.call(score);
    if (score > highScore) {
      highScore = score;
      await highScoreRepository.saveHighScore(highScore);
      onHighScoreChanged?.call(highScore);
    }
  }

  /// Updates the running score and notifies listeners.
  void setScore(int value) {
    score = value;
    onScoreChanged?.call(score);
  }
}
