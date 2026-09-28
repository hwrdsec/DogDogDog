import 'package:flame/game.dart';

import '../game/dogdogdog_game.dart';
import 'game_over_overlay.dart';
import 'hud_overlay.dart';

/// Named Flame overlays owned by the game package.
abstract final class DogDogDogOverlays {
  static const String hud = 'hud';
  static const String gameOver = 'gameOver';

  /// Ready-made overlay builders for [GameWidget.overlayBuilderMap].
  static Map<String, OverlayWidgetBuilder<DogDogDogGame>> builders() {
    return {
      hud: (context, game) => HudOverlay(game: game),
      gameOver: (context, game) => GameOverOverlay(game: game),
    };
  }
}
