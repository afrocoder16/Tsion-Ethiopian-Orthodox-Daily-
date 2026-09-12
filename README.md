# Tsion Orthodox App

Tsion is an offline-first Ethiopian Orthodox daily companion for iOS and Android. It brings together Scripture, daily prayer, the Ethiopian calendar, appointed readings, the Synaxarium, and simple daily practice tracking in one Flutter app.

## Current status

Phase 1 is complete across all eight planned workstreams. Phase 2 content work and release preparation are in progress.

The current content bundle includes:

- 81 Amharic and 81 English Bible book files with local SQLite seeding and FTS5 search
- Seven standard prayers
- Wudase Mariam with 10 table-of-contents sections and 226 non-empty text blocks
- Twelve monthly daily-reading plans
- A 366-day Amharic Synaxarium, with 24 entries flagged for source review
- Two complete Explore articles, so Explore is intentionally thin

Wudase Mariam is available in Daily Prayer and Daily Prayers Books. Its source metadata reports 0 approved pages, 70 flagged pages, 55 missing transcript pages, and 2 missing named sections. Keep the in-app draft warning until the text has been checked against the scan.

Mezmur is temporarily hidden from every user entry point and guarded at the router. Its screens, player, metadata, and assets remain in the repository for later re-enabling.

Known release blockers are tracked in [documentation/STATUS.md](documentation/STATUS.md). The main ones are unconfigured Firebase, example Android and iOS bundle identifiers, missing Android release signing, readings data integrity errors, and content rights or proofreading work.

## Run the app

Requirements:

- Flutter 3.41 or newer on the stable channel
- Dart 3.11 or newer
- Android Studio or Xcode for the target platform

From the repository root:

```sh
flutter pub get
flutter run
```

List available devices when needed:

```sh
flutter devices
flutter run -d <device-id>
```

Run the project checks:

```sh
flutter analyze
flutter test
flutter build apk --debug
```

The Android debug APK is written to `build/app/outputs/flutter-apk/app-debug.apk`.

Firebase and account UI are deliberately disabled in this checkout. Settings and personal features use local device storage without asking the user to sign in. The authentication and cloud-sync code remains available for later re-enabling after `flutterfire configure` is run and `lib/firebase_options.dart` is replaced.

## Stack

- Flutter and Dart
- Riverpod
- go_router
- Drift with SQLite and FTS5
- Abushakir for Ethiopian date and Bahire Hasab calculations
- flutter_local_notifications and timezone for prayer reminders
- Firebase Auth and Firestore, currently disabled until configured
- audioplayers, retained for the hidden Mezmur implementation

## Documentation

Read the project docs in this order:

1. `README.md`: setup and orientation
2. `documentation/PRODUCT.md`: actual product scope and feature state
3. `documentation/ARCHITECTURE.md`: code organization and engineering rules
4. `documentation/STATUS.md`: latest health check, navigation fixes, and open problems
5. `CLAUDE.md`: concise handoff for the next coding session

## License and content rights

The repository license is not yet decided. Bible-source attribution, Synaxarium rights, Wudase proofreading, and Mezmur audio rights must be resolved before public release.
