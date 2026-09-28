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

  @override
  void initState() {
    super.initState();
    _game = DogDogDogGame(
      onScoreChanged: (_) {},
      onGameStarted: () {},
      onGameOver: (_) {},
      onHighScoreChanged: (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GameWidget<DogDogDogGame>(
          game: _game,
          // HUD overlays (score, next dog, game over) land here later.
          overlayBuilderMap:
              const <String, OverlayWidgetBuilder<DogDogDogGame>>{},
        ),
      ),
    );
  }
}
