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

Exported surface:

- `DogDogDogGame` — Forge2D game with walls, aim-and-drop, merges, pause, game over
- `GameConfig` / `PhysicsConfig` — centralized defaults (spawn pool, danger line, cooldown)
- `DogDefinition` + `placeholderDogs` / `dogAtLevel` — merge catalog
- `MergeRules` / `MergePair` / `MergeOutcome` — pure merge + scoring policy
- `SpawnPool` — seedable drop-level picker for lower tiers only
- `DangerMonitor` — grace-period tracking for the lose line
- `SandboxBall` / `Wall` / `AimPreview` / `DangerLine` — world components
- `DogDogDogOverlays` / `HudOverlay` / `GameOverOverlay` — Flutter HUD
- `HighScoreRepository` / `LocalHighScoreRepository` — persistence boundary

Hosts construct the game with optional callbacks:

- `onScoreChanged`
- `onGameStarted`
- `onGameOver`
- `onHighScoreChanged`

Pass `seed` or `random` for reproducible spawn sequences.

## Fixed world width

The playable Forge2D world uses a **fixed width** in world units (`PhysicsConfig.worldWidth`). The camera / viewport scales to fit the device, but simulation space does not stretch horizontally with screen size. That keeps drop aiming, merge radii, and difficulty consistent across phones and tablets.

Vertical visible height may vary by aspect ratio; gameplay systems should treat width as the stable axis.

## HUD via Flutter overlays

Score, next-dog preview, pause, and game-over UI live in **Flutter widgets**, not canvas-drawn Flame components. The host uses:

```dart
GameWidget(
  game: game,
  overlayBuilderMap: DogDogDogOverlays.builders(),
)
```

The game package owns the overlay widgets and names (`hud`, `gameOver`). Parents can replace builders if they need a custom shell.

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

The game package owns walls (left, right, floor), tap/click drop for placeholder circles, and all material values via `PhysicsConfig`.

## Milestone 3 merge mechanic

Bodies carry a level from `DogDefinition`. Same-level contacts queue a merge; `MergeRules.resolve` picks a conflict-free set (each body at most once) and the game removes both dogs, spawns the next level at the contact point, and awards that dog’s `scoreValue` via `onScoreChanged`. Max level cannot merge. New dogs can immediately chain-merge on later physics steps.

## Milestone 4 gameplay loop

- Drag horizontally to aim a ghost preview, release to drop (spawn cooldown enforced).
- Spawn pool (`GameConfig.minDropLevel`…`maxDropLevel`) feeds the drop queue; HUD shows the next dog.
- Danger line + `DangerMonitor` grace period ends the run; the active falling drop is ignored until first contact so it cannot false-trigger while falling through the line.
- Pause / resume, restart, score + local high score via package overlays and `LocalHighScoreRepository`.

## What later milestones still skip

No art pipeline or Tracker App integration yet. Configs, callbacks, and persistence remain ready for those systems.
