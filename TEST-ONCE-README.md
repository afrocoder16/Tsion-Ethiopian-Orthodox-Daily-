# iPhone Test Run Handoff Report

Date: 2026-07-05

Branch used before handoff: `codex/mezmur-library-player`

New handoff branch: `codex/iphone-test-run-report`

Project path on Mac:

```sh
/Users/tsi/Tsion-Ethiopian-Orthodox-Daily-
```

Flutter binary path:

```sh
/Users/tsi/flutter/bin/flutter
```

Connected iPhone:

```text
Sam's iphone
UDID: 00008140-001C7C180ABB801C
iOS: 26.5
```

## Goal

The goal was to run the Flutter app on a real iPhone. The first successful iPhone build/run showed the default Flutter Demo Home Page, which indicated that `flutter create` had overwritten the real app entry/dependency layer.

The next goal became:

1. Restore the real app source from `codex/mezmur-library-player`.
2. Keep the working iOS setup and signing.
3. Run the real app entry point on the iPhone.
4. Stop when it became clear the full missing app content/assets are required.

## Important Current State

The app no longer points at the default Flutter counter demo. `lib/main.dart` was restored from the branch and now starts the real app:

```dart
runApp(
  ProviderScope(
    overrides: [
      firebaseBootstrapProvider.overrideWithValue(firebaseBootstrap),
    ],
    child: const TsionApp(),
  ),
);
```

The iOS signing setup should be preserved. The Xcode project locally currently has:

```text
DEVELOPMENT_TEAM = D8ZVP9436N
PRODUCT_BUNDLE_IDENTIFIER = com.samson.tsionOrthodoxDaily
IPHONEOS_DEPLOYMENT_TARGET = 15.0
```

Do not delete the iOS signing setup unless the user explicitly asks.

## What Was Done

### 1. Fixed Missing Podfile

The repo's `ios/` folder originally had no `Podfile`, so `pod install` failed with:

```text
[!] No `Podfile' found in the project directory.
```

Added locally:

```text
ios/Podfile
```

The Podfile is the standard Flutter iOS Podfile with the platform now set to iOS 15.0 locally.

### 2. Installed Flutter iOS Artifacts

The first `pod install` after adding the Podfile failed because Flutter's iOS engine artifacts were missing:

```text
/Users/tsi/flutter/bin/cache/artifacts/engine/ios/Flutter.xcframework must exist.
```

Fixed with:

```sh
/Users/tsi/flutter/bin/flutter precache --ios
```

### 3. Completed CocoaPods Setup

Ran:

```sh
cd /Users/tsi/Tsion-Ethiopian-Orthodox-Daily-/ios
pod install
```

`pod install` now succeeds locally. It may still print a Profile configuration warning, but Debug builds are wired.

### 4. Opened Xcode Workspace

Opened:

```sh
open ios/Runner.xcworkspace
```

Important: use `Runner.xcworkspace`, not `Runner.xcodeproj`.

### 5. Got iPhone Detected

At first, `flutter devices` did not show the iPhone. After reconnecting, unlocking, and trusting the Mac, Flutter detected it:

```text
Sam's iphone (mobile) • 00008140-001C7C180ABB801C • ios • iOS 26.5
```

Command:

```sh
/Users/tsi/flutter/bin/flutter devices --device-timeout 20
```

### 6. Signing Was Set in Xcode

Flutter later confirmed it could use the saved signing team:

```text
Automatically signing iOS for device deployment using specified development team in Xcode project: D8ZVP9436N
```

This means Xcode signing is currently working locally and should not be wiped.

### 7. Restored Real App Source

Because the iPhone showed the default Flutter Demo Home Page, the Flutter project had likely been overwritten by `flutter create`.

Restored app/dependency files from git:

```sh
git restore lib pubspec.yaml pubspec.lock test/widget_test.dart \
  linux/flutter/generated_plugin_registrant.cc linux/flutter/generated_plugins.cmake \
  macos/Flutter/GeneratedPluginRegistrant.swift \
  windows/flutter/generated_plugin_registrant.cc windows/flutter/generated_plugins.cmake
```

After this, `lib/main.dart` was the real app entry point again.

### 8. Restored Dependencies

Ran:

```sh
/Users/tsi/flutter/bin/flutter pub get
```

This restored the real dependency graph, including:

- Firebase
- Google Sign-In
- Riverpod
- GoRouter
- Drift/SQLite
- audio players
- notifications

Flutter reported package updates available, but those were not upgraded.

### 9. Fixed Firebase iOS Minimum Version

The first real-app iPhone build failed with:

```text
The package product 'cloud-firestore' requires minimum platform version 15.0
The package product 'firebase-auth' requires minimum platform version 15.0
The package product 'firebase-core' requires minimum platform version 15.0
```

Fixed locally by raising iOS deployment target from 13.0 to 15.0 in:

```text
ios/Podfile
ios/Runner.xcodeproj/project.pbxproj
```

This is safe for the test iPhone because it is on iOS 26.5.

### 10. Found Missing Full App Assets

After the deployment target fix, the real-app build failed during Flutter asset bundling:

```text
Error: unable to find directory entry in pubspec.yaml:
/Users/tsi/Tsion-Ethiopian-Orthodox-Daily-/assets/data/readings/

Error: unable to find directory entry in pubspec.yaml:
/Users/tsi/Tsion-Ethiopian-Orthodox-Daily-/assets/80-weahadu-main/data/am/

Error: unable to find directory entry in pubspec.yaml:
/Users/tsi/Tsion-Ethiopian-Orthodox-Daily-/assets/80-weahadu-main/data/en/

No file or variants found for asset:
assets/data/daily_verse_entries.json
```

The current branch references those assets in `pubspec.yaml`, but the assets were not committed to the repo.

Checked:

```sh
git ls-files | rg '80-weahadu|daily_verse|readings|verse/'
git log --all --name-status -- assets/data/daily_verse_entries.json assets/data/readings assets/80-weahadu-main
```

Result: the missing assets are not tracked in git history.

Also searched likely local locations, including:

```text
/Users/tsi/Documents/Tsion M
```

No full copy of those assets was found.

### 11. Added Minimal Placeholder Assets Locally for Test Bundling

Because Flutter cannot build when `pubspec.yaml` references missing assets, minimal placeholder JSON files were generated locally at:

```text
assets/data/daily_verse_entries.json
assets/data/readings/*.json
assets/80-weahadu-main/data/am/*.json
assets/80-weahadu-main/data/en/*.json
```

These are not the real app content. They are only valid placeholder JSON files so the asset bundler and startup seeding can get past missing-file errors.

Generated counts locally:

```text
12 monthly reading files
60 Amharic Bible placeholder files
60 English Bible placeholder files
1 daily verse placeholder file
```

The full real app still needs the real content assets.

## Last Run Attempt

Command used:

```sh
cd /Users/tsi/Tsion-Ethiopian-Orthodox-Daily-
/Users/tsi/flutter/bin/flutter run -d 00008140-001C7C180ABB801C
```

The run got as far as:

```text
Launching lib/main.dart on Sam's iphone in debug mode...
Automatically signing iOS for device deployment using specified development team in Xcode project: D8ZVP9436N
Running Xcode build...
```

The user then chose to stop because the app needs the full real content/assets for meaningful testing. The background Flutter/Xcode process was stopped.

## Current Blocker

The main blocker is not iOS signing anymore.

The main blocker is missing full app content assets that are referenced by `pubspec.yaml`:

```text
assets/data/daily_verse_entries.json
assets/data/readings/
assets/80-weahadu-main/data/am/
assets/80-weahadu-main/data/en/
```

The local branch includes placeholder assets, but they are not a substitute for the real app data.

## Git Push Note

A local commit was created on this Mac:

```text
9563d18 Add iPhone test run handoff report
```

Local `git push` over HTTPS failed because this Mac did not have command-line GitHub credentials stored:

```text
fatal: could not read Username for 'https://github.com': Device not configured
```

The connected GitHub app was used to create the remote branch and upload this report file so the handoff is accessible remotely. If the full local commit with iOS setup files and placeholder assets needs to be pushed exactly, authenticate command-line git on this Mac or install/use GitHub CLI, then run:

```sh
cd /Users/tsi/Tsion-Ethiopian-Orthodox-Daily-
git push -u origin codex/iphone-test-run-report
```

## Recommended Next Steps

1. Obtain the real missing asset folders/files from the original app author, old working machine, cloud storage, or backup.
2. Replace the placeholder files with the real assets.
3. Keep the current iOS signing values unless changing Apple account/device:

```text
DEVELOPMENT_TEAM = D8ZVP9436N
PRODUCT_BUNDLE_IDENTIFIER = com.samson.tsionOrthodoxDaily
IPHONEOS_DEPLOYMENT_TARGET = 15.0
```

4. Run:

```sh
cd /Users/tsi/Tsion-Ethiopian-Orthodox-Daily-
/Users/tsi/flutter/bin/flutter pub get
cd ios && pod install && cd ..
/Users/tsi/flutter/bin/flutter run -d 00008140-001C7C180ABB801C
```

5. If using Xcode, open:

```sh
open ios/Runner.xcworkspace
```

## Notes for the Next AI

- Do not run `flutter create --overwrite .` unless the user explicitly requests project regeneration. It can overwrite real app files.
- The real `lib/main.dart` is restored and should remain.
- Do not delete or reset iOS signing setup.
- The iPhone test path is working enough for Flutter/Xcode to identify the phone and use the saved development team.
- The full app cannot be meaningfully validated until the real missing assets are restored.
- `gh` is not installed on this Mac, so GitHub PR creation from CLI was not available.
- Use `/Users/tsi/flutter/bin/flutter` if `flutter` is not on PATH in a fresh terminal.
