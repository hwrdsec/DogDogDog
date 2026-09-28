# Architecture

DogDogDog splits into a reusable game package and a thin host app. The goal is to keep gameplay portable while letting different shells present HUD, navigation, and platform services.

## Packages

| Package | Role |
| --- | --- |
| `dogdogdog_game` | Flame / Forge2D game, configs, persistence interfaces, public API |
| `dogdogdog` | Standalone Flutter host (`GameWidget` + overlays) |

The host depends on the game package via a path dependency inside a Dart pub workspace. No Melos — `flutter pub get` at the repo root resolves everything.

## Public API

Import the game package from a single barrel:

```dart
import 'package:dogdogdog_game/dogdogdog_game.dart';
```

Exported surface (Milestone 1):

- `DogDogDogGame` — Forge2D game with walls, gravity, and tap-to-drop sandbox circles
- `GameConfig` / `PhysicsConfig` — centralized defaults
- `DogDefinition` + `placeholderDogs` — stub merge catalog
- `HighScoreRepository` / `LocalHighScoreRepository` — persistence boundary

Hosts construct the game with optional callbacks:

- `onScoreChanged`
- `onGameStarted`
- `onGameOver`
- `onHighScoreChanged`

## Fixed world width

The playable Forge2D world uses a **fixed width** in world units (`PhysicsConfig.worldWidth`). The camera / viewport scales to fit the device, but simulation space does not stretch horizontally with screen size. That keeps drop aiming, merge radii, and difficulty consistent across phones and tablets.

Vertical visible height may vary by aspect ratio; gameplay systems should treat width as the stable axis.

## HUD via Flutter overlays

Score, next-dog preview, pause, and game-over UI live in **Flutter widgets**, not canvas-drawn Flame components. The host uses:

```dart
GameWidget(
  game: game,
  overlayBuilderMap: {
    // 'hud': ...,
    // 'gameOver': ...,
  },
)
```

Milestone 1 leaves `overlayBuilderMap` empty but ready. Later milestones add named overlays and call `game.overlays.add` / `remove` from game code when state changes.

## Persistence

High scores go through `HighScoreRepository` so the standalone app and any future embed can swap storage:

- `LocalHighScoreRepository` — `shared_preferences` (default for the host)
- Custom implementations — e.g. cloud sync or a parent app’s datastore

The game package owns the interface and the local implementation. It does not assume a specific host.

## Tracker App embed (future)

`dogdogdog_game` is meant to drop into a larger “Tracker App” (or any Flutter shell) the same way the standalone host embeds it today:

1. Depend on `dogdogdog_game`
2. Mount `GameWidget` (or a thin wrapper) with overlay builders supplied by the parent
3. Optionally inject a custom `HighScoreRepository`

The standalone `apps/dogdogdog` app remains the day-to-day development host and a shippable store build target.

## Milestone 2 physics sandbox

The game package owns walls (left, right, floor), tap/click drop for placeholder circles, and all material values via `PhysicsConfig`. The host stays a thin `GameWidget` shell. No merge rules, score loop, lose line, or dog theme in this milestone.

## What later milestones still skip

No merge rules, lose line, full dog catalog, or art pipeline yet. Configs, callbacks, and persistence stubs remain ready for those systems.
