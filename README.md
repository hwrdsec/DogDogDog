# DogDogDog

Casual merge game built with Flutter and Flame. Drop dogs, merge matching ones, chase a high score.

This repository is a Dart pub workspace: a thin Flutter host app plus a reusable game package so the same game can run standalone or inside another Flutter app later.

## Structure

```
DogDogDog/
  apps/dogdogdog/           # Standalone Flutter host (Android, iOS, macOS)
  packages/dogdogdog_game/  # Flame / Forge2D game package
  ARCHITECTURE.md           # Design notes
```

## Requirements

- Flutter 3.47+ (Dart 3.13+)
- Xcode for iOS / macOS builds
- Android SDK for Android builds

## Setup

From the repository root:

```bash
export PATH="/Users/hwrd/Documents/Development/SDKs/flutter/bin:$PATH"
flutter pub get
```

That resolves the workspace (host + game package) with a single lockfile at the root.

## How to play

1. Drag horizontally to aim the ghost dog at the top, then release to drop.
2. Matching levels merge into the next tier and add to your score. Two top-tier dogs clear for a larger bonus instead of creating another dog.
3. Drops are only levels 1–3; higher dogs come from merges.
4. Keep the pile below the red danger line — linger too long and it is game over.
5. Use pause / resume in the HUD, or Restart after a game over.

High score is stored locally via `shared_preferences`.

The play area is a fixed portrait box (letterboxed on wide desktop windows) so challenge stays consistent across sizes. See `ARCHITECTURE.md`.

## Run the host

```bash
cd apps/dogdogdog
flutter run -d macos
# or: flutter run -d <ios-simulator|android-device>
```

## Tests

Game package unit tests:

```bash
cd packages/dogdogdog_game
flutter test
```

Host widget smoke test:

```bash
cd apps/dogdogdog
flutter test
```

## Analyze

```bash
cd packages/dogdogdog_game && flutter analyze
cd ../../apps/dogdogdog && flutter analyze
```

## Platforms

Supported host targets: **Android**, **iOS**, and **macOS**. Web is intentionally not included.
