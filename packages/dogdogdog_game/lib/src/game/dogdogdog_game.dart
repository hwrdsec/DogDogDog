import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

import '../components/sandbox_ball.dart';
import '../components/wall.dart';
import '../config/game_config.dart';
import '../persistence/high_score_repository.dart';
import '../persistence/local_high_score_repository.dart';

/// Core DogDogDog Flame / Forge2D game.
///
/// Milestone 2: bounded play area with gravity, walls, and tap-to-drop
/// placeholder circles. Merge gameplay arrives later.
class DogDogDogGame extends Forge2DGame with TapCallbacks {
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

  final List<Wall> _walls = [];
  double _lastDropTime = -1000;
  int _spawnCount = 0;

  static const List<Color> _ballColors = [
    Color(0xFFFFC107),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF03A9F4),
    Color(0xFF4CAF50),
  ];

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    highScore = await highScoreRepository.getHighScore();
    onHighScoreChanged?.call(highScore);
    _fitCamera(size);
    _rebuildWalls();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) {
      return;
    }
    _fitCamera(size);
    _rebuildWalls();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final worldPoint = screenToWorld(event.canvasPosition);
    tryDropBall(worldPoint.x);
  }

  /// Drops a sandbox circle at [worldX] near the top of the play area.
  ///
  /// Returns `true` when a ball was spawned. Honors [GameConfig.dropCooldownSeconds].
  bool tryDropBall(double worldX) {
    final now = currentTime();
    if (now - _lastDropTime < config.dropCooldownSeconds) {
      return false;
    }

    final physics = config.physics;
    final halfWidth = physics.worldWidth / 2;
    final radius = physics.ballRadius;
    final maxX = halfWidth - radius;
    final clampedX = worldX.clamp(-maxX, maxX);

    final top = camera.visibleWorldRect.top;
    final spawnY = top + physics.spawnTopOffset + radius;

    final color = _ballColors[_spawnCount % _ballColors.length];
    world.add(
      SandboxBall(
        position: Vector2(clampedX, spawnY),
        color: color,
        physics: physics,
      ),
    );

    _spawnCount++;
    _lastDropTime = now;
    return true;
  }

  /// Starts a session. Sandbox drops work without this; hosts can still wire UI.
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

  void _fitCamera(Vector2 canvasSize) {
    if (canvasSize.x <= 0 || canvasSize.y <= 0) {
      return;
    }
    final width = config.physics.worldWidth;
    final height = width * (canvasSize.y / canvasSize.x);
    camera.viewfinder.visibleGameSize = Vector2(width, height);
    camera.viewfinder.position = Vector2.zero();
  }

  void _rebuildWalls() {
    for (final wall in _walls) {
      wall.removeFromParent();
    }
    _walls.clear();

    final rect = camera.visibleWorldRect;
    final topLeft = rect.topLeft.toVector2();
    final topRight = rect.topRight.toVector2();
    final bottomLeft = rect.bottomLeft.toVector2();
    final bottomRight = rect.bottomRight.toVector2();
    final physics = config.physics;

    final walls = [
      Wall(start: topLeft, end: bottomLeft, physics: physics),
      Wall(start: topRight, end: bottomRight, physics: physics),
      Wall(start: bottomLeft, end: bottomRight, physics: physics),
    ];

    _walls.addAll(walls);
    world.addAll(walls);
  }
}
