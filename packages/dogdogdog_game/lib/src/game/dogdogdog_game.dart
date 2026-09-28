import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

import '../components/sandbox_ball.dart';
import '../components/wall.dart';
import '../config/game_config.dart';
import '../logic/merge_rules.dart';
import '../models/dog_definition.dart';
import '../persistence/high_score_repository.dart';
import '../persistence/local_high_score_repository.dart';

/// Core DogDogDog Flame / Forge2D game.
///
/// Milestone 3: leveled dogs, same-level merges with chain reactions, scoring.
class DogDogDogGame extends Forge2DGame with TapCallbacks {
  DogDogDogGame({
    GameConfig? config,
    HighScoreRepository? highScoreRepository,
    List<DogDefinition>? dogCatalog,
    this.onScoreChanged,
    this.onGameStarted,
    this.onGameOver,
    this.onHighScoreChanged,
  }) : config = config ?? GameConfig.defaults,
       highScoreRepository = highScoreRepository ?? LocalHighScoreRepository(),
       dogCatalog = List.unmodifiable(dogCatalog ?? placeholderDogs),
       super(
         gravity: Vector2(0, (config ?? GameConfig.defaults).physics.gravityY),
       ) {
    mergeRules = MergeRules(
      maxLevel: this.config.maxDogLevel,
      catalog: this.dogCatalog,
    );
  }

  final GameConfig config;
  final HighScoreRepository highScoreRepository;
  final List<DogDefinition> dogCatalog;

  late final MergeRules mergeRules;

  final ValueChanged<int>? onScoreChanged;
  final VoidCallback? onGameStarted;
  final ValueChanged<int>? onGameOver;
  final ValueChanged<int>? onHighScoreChanged;

  int score = 0;
  int highScore = 0;
  bool isRunning = false;

  final List<Wall> _walls = [];
  final List<MergePair> _pendingMerges = [];
  double _lastDropTime = -1000;

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
  void update(double dt) {
    super.update(dt);
    _processMerges();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final worldPoint = screenToWorld(event.canvasPosition);
    tryDropBall(worldPoint.x);
  }

  /// Drops a leveled dog at [worldX] near the top of the play area.
  ///
  /// Defaults to [GameConfig.startingLevel]. Returns `true` when spawned.
  bool tryDropBall(double worldX, {int? level}) {
    final now = currentTime();
    if (now - _lastDropTime < config.dropCooldownSeconds) {
      return false;
    }

    final dropLevel = level ?? config.startingLevel;
    final definition = mergeRules.definitionFor(dropLevel);
    if (definition == null) {
      return false;
    }

    final physics = config.physics;
    final halfWidth = physics.worldWidth / 2;
    final radius = definition.radius;
    final maxX = halfWidth - radius;
    final clampedX = worldX.clamp(-maxX, maxX);

    final top = camera.visibleWorldRect.top;
    final spawnY = top + physics.spawnTopOffset + radius;

    _spawnDog(definition, Vector2(clampedX, spawnY));
    _lastDropTime = now;
    return true;
  }

  /// Starts a session. Drops and merges work without this; hosts can still wire UI.
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

  void _onMergeContact(
    SandboxBall self,
    SandboxBall other,
    Vector2 contactPoint,
  ) {
    if (self.isMerging || other.isMerging) {
      return;
    }
    if (!mergeRules.canMerge(self.level, other.level)) {
      return;
    }
    _pendingMerges.add(
      MergePair(
        idA: identityHashCode(self),
        idB: identityHashCode(other),
        level: self.level,
        contactX: contactPoint.x,
        contactY: contactPoint.y,
      ),
    );
  }

  void _processMerges() {
    if (_pendingMerges.isEmpty) {
      return;
    }
    final candidates = List<MergePair>.of(_pendingMerges);
    _pendingMerges.clear();

    final outcomes = mergeRules.resolve(candidates);
    if (outcomes.isEmpty) {
      return;
    }

    final ballsById = <int, SandboxBall>{};
    for (final child in world.children) {
      if (child is SandboxBall && !child.isMerging) {
        ballsById[identityHashCode(child)] = child;
      }
    }

    var scoreDelta = 0;
    for (final outcome in outcomes) {
      final a = ballsById[outcome.idA];
      final b = ballsById[outcome.idB];
      if (a == null || b == null) {
        continue;
      }
      if (a.isMerging || b.isMerging) {
        continue;
      }
      if (!mergeRules.canMerge(a.level, b.level)) {
        continue;
      }

      final next = mergeRules.definitionFor(outcome.resultingLevel);
      if (next == null) {
        continue;
      }

      a.isMerging = true;
      b.isMerging = true;
      a.removeFromParent();
      b.removeFromParent();

      _spawnDog(next, Vector2(outcome.spawnX, outcome.spawnY));
      scoreDelta += outcome.scoreAwarded;
    }

    if (scoreDelta > 0) {
      setScore(score + scoreDelta);
    }
  }

  void _spawnDog(DogDefinition definition, Vector2 position) {
    world.add(
      SandboxBall(
        position: position,
        definition: definition,
        physics: config.physics,
        onMergeContact: _onMergeContact,
      ),
    );
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
