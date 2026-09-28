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

/// Thin host shell: GameWidget plus package-provided HUD overlays.
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
    _game = DogDogDogGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<DogDogDogGame>(
        game: _game,
        overlayBuilderMap: DogDogDogOverlays.builders(),
      ),
    );
  }
}
