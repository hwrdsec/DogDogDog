import 'package:flutter/material.dart';

import '../game/dogdogdog_game.dart';
import '../models/dog_definition.dart';

/// Top HUD: score, high score, next-dog preview, pause/resume.
class HudOverlay extends StatelessWidget {
  const HudOverlay({required this.game, super.key});

  final DogDogDogGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            game.scoreListenable,
            game.highScoreListenable,
            game.nextLevelListenable,
            game.isPausedListenable,
            game.isGameOverListenable,
          ]),
          builder: (context, _) {
            if (game.isGameOverListenable.value) {
              return const SizedBox.shrink();
            }
            final next =
                game.mergeRules.definitionFor(game.nextLevelListenable.value) ??
                placeholderDogs.first;
            final paused = game.isPausedListenable.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Score ${game.scoreListenable.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Best ${game.highScoreListenable.value}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _NextDogBadge(definition: next),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: paused ? 'Resume' : 'Pause',
                  onPressed: () {
                    if (paused) {
                      game.resumeGame();
                    } else {
                      game.pauseGame();
                    }
                  },
                  icon: Icon(
                    paused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NextDogBadge extends StatelessWidget {
  const _NextDogBadge({required this.definition});

  final DogDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Next',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: definition.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white54, width: 2),
          ),
          child: Text(
            definition.emoji,
            style: const TextStyle(fontSize: 18, height: 1),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          definition.name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
