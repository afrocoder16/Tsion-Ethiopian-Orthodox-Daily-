# Tsion Orthodox App: Architecture

This document is the technical source of truth for the current Flutter codebase.

## 1. Stack

| Area | Choice |
|---|---|
| UI | Flutter and Dart |
| State | Riverpod 2 |
| Routing | go_router 14 |
| Local data | Drift and SQLite |
| Bible search | SQLite FTS5 |
| Ethiopian calendar | abushakir plus the local calendar engine |
| Notifications | flutter_local_notifications, timezone, flutter_timezone |
| Accounts | Firebase Auth with email/password and Google code paths |
| Sync | Cloud Firestore with local Drift as the device source of truth |
| Audio | audioplayers, currently retained for hidden Mezmur code |

The project currently targets Flutter 3.41 or newer and Dart 3.11 or newer. Riverpod 3 and the replacement path for the end-of-life `sqlite3_flutter_libs` package should be planned, not upgraded casually.

## 2. Runtime pipeline

Most feature screens follow this six-part flow:

```text
GoRouter route
  -> Consumer screen
  -> screen-state provider
  -> repository provider and real/fake switch
  -> Drift, JSON assets, or CalendarEngine
  -> adapter and rendered widget
```

The main wiring files are:

- `lib/app/app_router.dart`
- `lib/app/route_paths.dart`
- `lib/core/providers/repo_providers.dart`
- `lib/core/providers/screen_state_providers.dart`
- `lib/core/adapters/screen_state_adapters.dart`

`useDbReposProvider` defaults to true. It selects production `Db*Repository` implementations. Fake repositories support isolated UI tests and development but must not expose dead or misleading controls.

## 3. Routing and back behavior

`RoutePaths` is the only source for route templates and generated locations. Do not hand-write navigation strings in widgets.

The five bottom destinations share `AppShell`:

- `/today`
- `/books`
- `/prayers`
- `/calendar`
- `/explore`

Streak, Profile, and patron-saint routes live outside the shell. Legacy `/bible/*` routes remain for compatibility.

Navigation conventions:

- Use `context.go` for bottom-tab changes and intentional root replacement.
- Use `context.push` for leaf screens so back returns to the exact origin.
- Use `popOrGo(context, fallback)` for custom app-bar controls that may be reached directly.
- Wrap a top-level deep-link destination in `FallbackBackScope` when hardware back needs a safe root fallback.
- Unknown routes recover to `/today` through the router exception handler.
- Loading and error states for leaf pages must still expose normal back behavior.

The shared back helpers live in `lib/app/navigation_back.dart`.

### Mezmur route guard

`lib/core/config/feature_flags.dart` contains:

```dart
static const mezmurEnabled = false;
```

Prayers and Today check this flag before rendering any Mezmur entry point. The `/prayers/mezmur` route also redirects to `/prayers` while the flag is false. The Mezmur screens and player remain compiled and stored in the repository.

To re-enable Mezmur later:

1. Confirm the audio rights and content are release-ready.
2. Set `FeatureFlags.mezmurEnabled` to true.
3. Re-run `flutter analyze`, the full test suite, and device navigation tests.
4. Verify the Prayers card, Today entry, header shortcut, deep link, player, and sign-in gate.

No route or UI reconstruction should be required.

## 4. Data ownership

| Source | Owns |
|---|---|
| Drift | User state and seeded Bible content |
| JSON assets | Prayers, books other than the Bible, readings, daily verses, saints, Synaxarium, Explore, and Mezmur metadata |
| CalendarEngine | Computed Ethiopian dates, Bahire Hasab anchors, feasts, and fasts |

Rules:

- Do not store user state in assets.
- Do not add app content to Drift except Bible content required for FTS5.
- A repository joins data sources and returns a screen-state model.
- A screen reads that state through an adapter rather than querying Drift directly.

### Important content stores

- `BookContentStore` auto-discovers `assets/data/books/*.json` and adapts `assets/wudase_mariam.json`.
- `DailyReadingsRepository` reads the twelve files under `assets/data/readings/`.
- `ExploreContentStore` only exposes entries present in `assets/data/explore_content.json`.
- `DbSynaxariumRepository` joins Synaxarium indexes, entries, and local bookmark state.
- Bible JSON files under `assets/80-weahadu-main/data/am/` and `en/` seed Drift on first launch.

## 5. Drift schema

`AppDatabase.schemaVersion` is 5.

Tables:

- `meta`
- `saved_items`
- `reading_progress`
- `streak_tasks`
- `streak_events`
- `prayer_schedule`
- `prayer_completions`
- `personal_prayers`
- `bible_books`
- `bible_verses`
- `bible_verses_fts`

Database changes require a migration, a schema-version bump, migration tests, and preservation of existing user data.

## 6. Bible lifecycle

On first launch, the Bible seeder reads the bundled Amharic and English JSON files, inserts books and verses into Drift, and populates FTS5. A metadata key prevents unnecessary reseeding. Search, chapter reading, deep links, and continue-reading state all depend on this pipeline.

The bundle currently contains 81 files per language. Keep the asset directories in `pubspec.yaml` and tracked by Git.

## 7. Calendar and readings

The calendar engine lives in `lib/core/calendar/`. It owns Ethiopian and Gregorian conversion, fixed and movable observances, fast rules, month grids, and Bahire Hasab calculations. Calendar changes require golden-date tests.

Daily Readings are content data, not computed calendar truth. Their current JSON has a duplicated `11-02`, missing `03-06` and `12-25`, and Pagumen 6 in a non-leap-year source file. Correct these against an approved source rather than guessing.

Structured daily-reading models now carry the resolved Bible book ID and chapter into the screen adapter. The reading tile opens `RoutePaths.biblePassagePath(...)` only when those values exist.

## 8. Accounts and synchronization

`FirebaseBootstrap.initialize()` checks `DefaultFirebaseOptions.isConfigured`. The checked-in options intentionally report unconfigured, so account actions return a clear unavailable state instead of crashing.

When configured, Firebase Auth supplies identity and Firestore receives synchronized bookmarks, streak events, prayer completions, prayer schedules, and personal-prayer entries. Drift remains the immediate local source of truth. Firestore offline persistence and the local retry queue cover reconnection and startup retries.

Do not change sign-in boundaries in individual widgets. Use `SignInGuard` or `SignInGate`.

## 9. Prayer reminders

Prayer schedules are stored in Drift. Onboarding provides four-time, seven-time, and custom schedules. The notification service screen edits slots and reschedules local notifications.

Android uses an exact-alarm permission and boot receivers. iOS uses its notification-center delegate and requests alert, badge, and sound permissions. Physical-device notification timing still needs release QA.

## 10. Repository structure

```text
lib/
  app/                 router, paths, shell, back helpers
  core/
    actions/           user-state actions
    adapters/          screen-state to view-model mapping
    auth/              sign-in guard and Firebase account repository
    calendar/          Ethiopian calendar engine
    config/            temporary feature flags
    content/           JSON content stores
    db/                Drift database, tables, DAOs, migrations
    firebase/          safe Firebase bootstrap
    notifications/     prayer reminder scheduling
    providers/         Riverpod wiring
    readings/          daily content and reference parsing
    repos/             interfaces plus db and fake implementations
    sync/              Firestore synchronization and retry queue
    theme/             app theme
  features/
    bible/
    calendar/
    explore/
    onboarding/
    prayers/
    profile/
    streak/
    today/
test/
assets/
documentation/
```

## 11. Engineering rules

1. Use `RoutePaths` for every navigation destination.
2. Preserve one-level back behavior when opening a leaf screen.
3. Follow the real/fake repository switch for screen-state features.
4. Keep content and user state separate.
5. Read screen-state models through adapters.
6. Add safe loading, error, and retry states without removing back access.
7. Add migrations and tests for every database schema change.
8. Add golden-date tests for calendar logic.
9. Route sign-in behavior through the shared guard.
10. Do not add new hardcoded colors or user-facing strings. Use theme and string infrastructure as it becomes available.
11. Do not expose placeholder content, inactive buttons, or dead tap surfaces.
12. Preserve user work in a dirty working tree and avoid destructive Git operations.

## 12. Current technical debt

- Firebase configuration and live auth cannot be tested yet.
- Android and iOS application IDs are examples.
- Android release signing is not configured.
- Localization infrastructure is not present.
- The current theme seed is a placeholder.
- Large JSON parsing still occurs on the UI isolate in places.
- `screen_state_adapters.dart` is oversized.
- Mezmur player state remains coupled to the widget implementation.
- Prayer audio, Light a Candle persistence, Reflection journaling, and patron-saint persistence are incomplete.
- Settings are scattered under a sign-in-gated Profile flow.

See `STATUS.md` for current verification results and product-impact details.
