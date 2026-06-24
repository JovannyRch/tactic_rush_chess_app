# AGENTS.md — Tactic Rush

## Project overview

Tactic Rush is a Flutter mobile game for fast chess puzzle rushes. It supports:

- Multiple timed modes (1 min / 3 min / 5 min / survival / marathon) with 3 lives for timed modes.
- Puzzles from a local bundle, lichess, and BlitzTactics.
- A "puzzle of the day" fetched from lichess.
- Chess move/capture/low-time sounds and haptic feedback.
- Light/dark theme with brand colors `#F88D04` (orange) and `#071120` (dark navy).

## Tech stack

- Flutter 3.x / Dart
- Riverpod for state management
- `chessground` + `dartchess` for board and logic
- `audioplayers` for sound effects
- `shared_preferences` for local scores
- `http` for remote puzzle sources
- `package_info_plus` for app version
- `supabase_flutter` (currently unused but wired for future backend/leaderboards)

## Common commands

```bash
# Install dependencies
flutter pub get

# Regenerate localizations
flutter gen-l10n

# Run tests
flutter test

# Run on a connected device
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK (requires a configured signing keystore)
flutter build apk --release

# Build release App Bundle for Google Play (requires a configured signing keystore)
flutter build appbundle --release
```

## Android release setup

1. Update `pubspec.yaml` `version` (e.g. `1.0.0+1`). `+1` is the Android `versionCode`.
2. Ensure `android/app/build.gradle.kts` uses the desired `applicationId` (default: `ww.jvz.tactic_rush_chess`).
3. Generate an upload keystore:

   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

4. Fill in `android/key.properties` with the keystore credentials.
5. Build the release bundle:

   ```bash
   flutter build appbundle --release
   ```

The generated bundle will be at:
`build/app/outputs/bundle/release/app-release.aab`

## Testing notes

- Widget and controller tests use a `_FakePuzzleRepository` to avoid network calls.
- `RushScreen` accepts `skipCountdown: true` and `RushController.start(skipCountdown: true)` to bypass the `3-2-1-GO` countdown in tests.
- `HomeScreen` accepts `debugSkipCountdown: true` for the same purpose.

## Important files

- `lib/main.dart` — App entry point, providers, and locale setup.
- `lib/src/ui/home_screen.dart` — Main menu with logo, modes, daily puzzle card, and "About" dialog.
- `lib/src/ui/rush_screen.dart` — In-game screen with board, countdown overlay, and HUD.
- `lib/src/rush/rush_controller.dart` — Game loop, scoring, timer, and puzzle loading.
- `lib/src/data/puzzle_repository.dart` — Puzzle loading from local bundle, lichess, and BlitzTactics.
- `lib/src/model/puzzle.dart` — Puzzle model with `source`, `setupFen`, and `setupMove`.
- `lib/l10n/` — English and Spanish localizations.
- `assets/audio/` — Sound effects (`move.mp3`, `capture.mp3`, `low_time.mp3`).

## MVP scope notes

- Leaderboards are hidden from the UI but `LeaderboardScreen` and Supabase wiring remain in the codebase for a future release.
