import 'package:dogdogdog_game/dogdogdog_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DogDogDogApp());
}

class DogDogDogApp extends StatelessWidget {
  const DogDogDogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DogDogDog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9800),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

/// Thin host shell: GameWidget plus overlay hooks for a future HUD.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final DogDogDogGame _game;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _game = DogDogDogGame(
      onScoreChanged: (score) {
        if (!mounted) {
          return;
        }
        setState(() => _score = score);
      },
      onGameStarted: () {},
      onGameOver: (_) {},
      onHighScoreChanged: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget<DogDogDogGame>(
              game: _game,
              // HUD overlays (score, next dog, game over) land here later.
              overlayBuilderMap:
                  const <String, OverlayWidgetBuilder<DogDogDogGame>>{},
            ),
            // Temporary debug score until Milestone 4 HUD.
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Text(
                  'Score: $_score',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
