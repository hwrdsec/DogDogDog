import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

import '../components/aim_preview.dart';
import '../components/danger_line.dart';
import '../components/sandbox_ball.dart';
import '../components/wall.dart';
import '../config/game_config.dart';
import '../logic/danger_monitor.dart';
import '../logic/merge_rules.dart';
import '../logic/spawn_pool.dart';
import '../models/dog_definition.dart';
import '../overlays/overlay_ids.dart';
import '../persistence/high_score_repository.dart';
import '../persistence/local_high_score_repository.dart';

/// Core DogDogDog Flame / Forge2D game.
///
/// Aim-and-drop loop, spawn pool, HUD overlays, pause, game over, fixed playfield.
class DogDogDogGame extends Forge2DGame with MultiTouchDragDetector {
  DogDogDogGame({
    GameConfig? config,
    HighScoreRepository? highScoreRepository,
    List<DogDefinition>? dogCatalog,
    Random? random,
    int? seed,
    this.onScoreChanged,
    this.onGameStarted,
    this.onGameOver,
    this.onHighScoreChanged,
  }) : config = config ?? GameConfig.defaults,
       highScoreRepository = highScoreRepository ?? LocalHighScoreRepository(),
       dogCatalog = List.unmodifiable(dogCatalog ?? placeholderDogs),
       _random = random ?? (seed != null ? Random(seed) : Random()),
       super(
         gravity: Vector2(0, (config ?? GameConfig.defaults).physics.gravityY),
       ) {
    mergeRules = MergeRules(
      maxLevel: this.config.maxDogLevel,
      catalog: this.dogCatalog,
    );
    spawnPool = SpawnPool(
      minLevel: this.config.minDropLevel,
      maxLevel: this.config.maxDropLevel,
      random: _random,
    );
    dangerMonitor = DangerMonitor(
      gracePeriodSeconds: this.config.dangerGraceSeconds,
    );
  }

  final GameConfig config;
  final HighScoreRepository highScoreRepository;
  final List<DogDefinition> dogCatalog;
  final Random _random;

  late final MergeRules mergeRules;
  late final SpawnPool spawnPool;
  late final DangerMonitor dangerMonitor;

  final ValueChanged<int>? onScoreChanged;
  final VoidCallback? onGameStarted;
  final ValueChanged<int>? onGameOver;
  final ValueChanged<int>? onHighScoreChanged;

  final ValueNotifier<int> scoreListenable = ValueNotifier<int>(0);
  final ValueNotifier<int> highScoreListenable = ValueNotifier<int>(0);
  final ValueNotifier<int> currentLevelListenable = ValueNotifier<int>(1);
  final ValueNotifier<int> nextLevelListenable = ValueNotifier<int>(1);
  final ValueNotifier<bool> isPausedListenable = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isGameOverListenable = ValueNotifier<bool>(false);

  int get score => scoreListenable.value;
  int get highScore => highScoreListenable.value;
  bool get isPaused => isPausedListenable.value;
  bool get isGameOver => isGameOverListenable.value;

  bool isRunning = false;

  final List<Wall> _walls = [];
  final List<MergePair> _pendingMerges = [];
  double _lastDropTime = -1000;
  double _aimX = 0;
  bool _isAiming = false;
  AimPreview? _aimPreview;
  DangerLine? _dangerLine;

  /// World Y of the danger line (smaller Y = higher on screen).
  double get dangerLineY =>
      camera.visibleWorldRect.top + config.dangerLineOffset;

  bool get canDrop {
    if (!isRunning || isPaused || isGameOver) {
      return false;
    }
    return currentTime() - _lastDropTime >= config.dropCooldownSeconds;
  }

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final loaded = await highScoreRepository.getHighScore();
    highScoreListenable.value = loaded;
    onHighScoreChanged?.call(loaded);
    _fitCamera(size);
    _rebuildWalls();
    _rebuildDangerLine();
    overlays.add(DogDogDogOverlays.hud);
    startGame();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) {
      return;
    }
    _fitCamera(size);
    _rebuildWalls();
    _rebuildDangerLine();
    _syncAimPreview();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isRunning || isPaused || isGameOver) {
      return;
    }
    _processMerges();
    _checkDanger(dt);
    _syncAimPreview();
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    if (!canDrop) {
      return;
    }
    _isAiming = true;
    _setAimFromScreen(info.eventPosition.widget);
    _syncAimPreview();
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    if (!_isAiming || !canDrop) {
      return;
    }
    _setAimFromScreen(info.eventPosition.widget);
    _syncAimPreview();
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    if (!_isAiming) {
      return;
    }
    _isAiming = false;
    if (canDrop) {
      tryDropBall(_aimX);
    }
    _syncAimPreview();
  }

  @override
  void onDragCancel(int pointerId) {
    _isAiming = false;
    _syncAimPreview();
  }

  /// Drops the queued dog at [worldX] near the top of the play area.
  ///
  /// Returns `true` when spawned. Uses the current queue level unless [level]
  /// is provided (tests / debug).
  bool tryDropBall(double worldX, {int? level}) {
    if (!isRunning || isPaused || isGameOver) {
      return false;
    }
    final now = currentTime();
    if (now - _lastDropTime < config.dropCooldownSeconds) {
      return false;
    }

    final dropLevel = level ?? currentLevelListenable.value;
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

    _spawnDog(definition, Vector2(clampedX, spawnY), isDropping: true);
    _lastDropTime = now;
    _aimX = clampedX;

    if (level == null) {
      _advanceQueue();
    }
    _syncAimPreview();
    return true;
  }

  /// Starts a fresh session.
  void startGame() {
    _clearDogs();
    dangerMonitor.reset();
    _lastDropTime = -1000;
    _isAiming = false;
    setScore(0);
    isGameOverListenable.value = false;
    isPausedListenable.value = false;
    if (paused) {
      resumeEngine();
    }
    _rollInitialQueue();
    isRunning = true;
    overlays
      ..remove(DogDogDogOverlays.gameOver)
      ..add(DogDogDogOverlays.hud);
    _rebuildDangerLine();
    _syncAimPreview();
    onGameStarted?.call();
  }

  /// Alias used by the game-over overlay.
  void restartGame() => startGame();

  void pauseGame() {
    if (!isRunning || isGameOver || isPaused) {
      return;
    }
    isPausedListenable.value = true;
    pauseEngine();
    _isAiming = false;
    _syncAimPreview();
  }

  void resumeGame() {
    if (!isPaused) {
      return;
    }
    isPausedListenable.value = false;
    resumeEngine();
    _syncAimPreview();
  }

  /// Ends a session and persists a new high score when needed.
  Future<void> endGame() async {
    if (!isRunning || isGameOver) {
      return;
    }
    isRunning = false;
    isGameOverListenable.value = true;
    _isAiming = false;
    _removeAimPreview();
    onGameOver?.call(score);
    if (score > highScore) {
      highScoreListenable.value = score;
      await highScoreRepository.saveHighScore(score);
      onHighScoreChanged?.call(score);
    }
    overlays.add(DogDogDogOverlays.gameOver);
  }

  /// Updates the running score and notifies listeners.
  void setScore(int value) {
    scoreListenable.value = value;
    onScoreChanged?.call(value);
  }

  void _advanceQueue() {
    currentLevelListenable.value = nextLevelListenable.value;
    nextLevelListenable.value = spawnPool.next();
  }

  void _rollInitialQueue() {
    currentLevelListenable.value = spawnPool.next();
    nextLevelListenable.value = spawnPool.next();
  }

  void _setAimFromScreen(Vector2 screenPosition) {
    final worldPoint = screenToWorld(screenPosition);
    final definition = mergeRules.definitionFor(currentLevelListenable.value);
    final radius = definition?.radius ?? config.physics.ballRadius;
    final maxX = config.physics.worldWidth / 2 - radius;
    _aimX = worldPoint.x.clamp(-maxX, maxX);
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

  void _checkDanger(double dt) {
    final lineY = dangerLineY;
    final above = <int>{};
    for (final child in world.children) {
      if (child is! SandboxBall || child.isMerging || child.isDropping) {
        continue;
      }
      if (child.isAboveDangerLine(lineY)) {
        above.add(identityHashCode(child));
      }
    }
    if (dangerMonitor.update(above, dt) != null) {
      endGame();
    }
  }

  void _spawnDog(
    DogDefinition definition,
    Vector2 position, {
    bool isDropping = false,
  }) {
    world.add(
      SandboxBall(
        position: position,
        definition: definition,
        physics: config.physics,
        onMergeContact: _onMergeContact,
        isDropping: isDropping,
      ),
    );
  }

  void _clearDogs() {
    final dogs = world.children.whereType<SandboxBall>().toList();
    for (final dog in dogs) {
      dog.removeFromParent();
    }
    _pendingMerges.clear();
  }

  void _fitCamera(Vector2 canvasSize) {
    if (canvasSize.x <= 0 || canvasSize.y <= 0) {
      return;
    }
    final physics = config.physics;
    final playSize = Vector2(physics.worldWidth, physics.visibleWorldHeight);

    // Letterbox to a fixed portrait playfield so wide desktop windows do not
    // stretch the arena horizontally and collapse vertical challenge.
    if (camera.viewport is! FixedAspectRatioViewport) {
      camera.viewport = FixedAspectRatioViewport(
        aspectRatio: physics.playAspectRatio,
      );
    }

    camera.viewfinder.visibleGameSize = playSize;
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

  void _rebuildDangerLine() {
    _dangerLine?.removeFromParent();
    final line = DangerLine(
      worldWidth: config.physics.worldWidth,
      y: dangerLineY,
    );
    _dangerLine = line;
    world.add(line);
  }

  void _syncAimPreview() {
    if (!isRunning || isPaused || isGameOver || !canDrop) {
      _removeAimPreview();
      return;
    }

    final definition = mergeRules.definitionFor(currentLevelListenable.value);
    if (definition == null) {
      _removeAimPreview();
      return;
    }

    final top = camera.visibleWorldRect.top;
    final spawnY = top + config.physics.spawnTopOffset + definition.radius;
    final maxX = config.physics.worldWidth / 2 - definition.radius;
    final x = _aimX.clamp(-maxX, maxX);

    final existing = _aimPreview;
    if (existing == null || existing.parent == null) {
      final preview = AimPreview(definition: definition)
        ..position = Vector2(x, spawnY);
      _aimPreview = preview;
      world.add(preview);
    } else {
      existing.definition = definition;
      existing.position = Vector2(x, spawnY);
    }
  }

  void _removeAimPreview() {
    _aimPreview?.removeFromParent();
    _aimPreview = null;
  }
}
