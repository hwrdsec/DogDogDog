import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../game/dogdogdog_game.dart';
import 'game_over_overlay.dart';
import 'hud_overlay.dart';
import 'physics_tuning_overlay.dart';

/// Named Flame overlays owned by the game package.
abstract final class DogDogDogOverlays {
  static const String hud = 'hud';
  static const String gameOver = 'gameOver';
  static const String physicsTuning = 'physicsTuning';

  /// True in debug and profile. Release builds have no tuning panel.
  static bool get physicsTuningAvailable => !kReleaseMode;

  /// Ready-made overlay builders for [GameWidget.overlayBuilderMap].
  static Map<String, OverlayWidgetBuilder<DogDogDogGame>> builders() {
    final builders = <String, OverlayWidgetBuilder<DogDogDogGame>>{
      hud: (context, game) => HudOverlay(game: game),
      gameOver: (context, game) => GameOverOverlay(game: game),
    };
    if (physicsTuningAvailable) {
      builders[physicsTuning] = (context, game) =>
          PhysicsTuningOverlay(game: game);
    }
    return builders;
  }
}
