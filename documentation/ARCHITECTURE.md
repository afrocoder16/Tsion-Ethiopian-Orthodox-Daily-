# Tsion Orthodox App: Architecture

This document explains how the code is organized, how data flows through the app, and the conventions any new code must follow. It is the source of truth for technical decisions.

If code in the repo does not match this document, either the code should be corrected or this document should be updated. Do not let them drift.

---

## 1. Stack

| Layer | Choice | Notes |
|---|---|---|
| Language | Dart | via Flutter |
| UI framework | Flutter | Single codebase, iOS and Android |
| State management | Riverpod (flutter_riverpod) | v2 series. Riverpod 3 upgrade is a future task. |
| Routing | go_router | v14 series |
| Local database | Drift (SQLite) | User state and seeded Bible content |
| Full-text search | SQLite FTS5 | For Bible verses |
| Ethiopian calendar | abushakir | Bahire Hasab and Ethiopian date math |
| Audio | audioplayers | Mezmur and Hear Today's Word |
| Local notifications | flutter_local_notifications | Prayer reminders |
| Auth | firebase_auth | Email + password, Google Sign-In, Apple Sign-In pending |
| Cloud sync | cloud_firestore | For signed-in user data (bookmarks, streak, personal prayer list) |
| Sign-in providers | google_sign_in, firebase_auth | Apple Sign-In pending |

### Package versions worth noting

- flutter_riverpod is on v2. v3 is available. Upgrade is planned but not urgent.
- sqlite3_flutter_libs: the latest version at the time of audit was marked end-of-life. Watch for a replacement.
- timezone and flutter_timezone are installed for local prayer reminder scheduling.
- No `intl` / `flutter_localizations` / ARB tooling yet. Added when localization scaffolding is set up.

### Required Flutter versions

- Flutter 3.41+ on stable channel
- Dart 3.11+

---

## 2. The 6-layer pipeline (mental model for the whole app)

Every screen in the app gets its data through the same vertical pipeline. Understand this one pattern and you understand about 90 percent of the codebase.

```
main.dart -> ProviderScope -> TsionApp -> MaterialApp.router
                              |
                              v
        ROUTING (go_router)
        routerProvider -> buildRouter() -> AppShell
                              |
                              v  renders a screen
                              
   1. SCREEN (ConsumerWidget)         lib/features/<x>/presentation/
        ref.watch(xScreenStateProvider)
                              |
                              v
   2. SCREEN-STATE PROVIDER           lib/core/providers/screen_state_providers.dart
        ref.watch(xRepositoryProvider).fetchXScreen()
                              |
                              v
   3. REPO PROVIDER (the switch)      lib/core/providers/repo_providers.dart
        useDbReposProvider ? DbXRepository : FakeXRepository
                              |
                              v
   4. REPOSITORY (orchestrator)       lib/core/repos/db/ or lib/core/repos/fake/
        pulls from up to 3 data sources, returns a *ScreenState
                              |
                              v
   5. DATA SOURCES
        Drift/SQLite      JSON assets      CalendarEngine
         (user state       (content         (abushakir math)
          and Bible         except Bible)
          verses)
                              |
                              v
   6. ADAPTER -> UI                   lib/core/adapters/screen_state_adapters.dart
        XAdapter(state) maps raw state to a view-model the widget renders
```

### Layer-by-layer

**Layer 1: Bootstrap** (`main.dart`, `app/app.dart`)

`main()` initializes Flutter, the SQLite workaround, and Firebase, then wraps everything in a single Riverpod `ProviderScope` with one override (`firebaseBootstrapProvider`). `TsionApp` watches `routerProvider` and hands it to `MaterialApp.router`. That is the only thing at the top. Everything else is reached through the router and providers.

**Layer 2: Routing** (`app/app_router.dart`, `app/route_paths.dart`)

`buildRouter()` defines one `GoRouter`. `RoutePaths` is the single source of truth for every URL, both the templates (`/books/bible/:book/:chapter`) and type-safe builders (`biblePassagePath(book, chapter)`). Screens never hand-write path strings, they call `RoutePaths.xPath(...)`.

`AppShell` is a `ShellRoute` that wraps the 5 main tabs (Today, Books, Prayers, Calendar, Explore) with the bottom NavigationBar. Selected tab is derived from the current URL. Two route groups live outside the shell: `/streak/*`, `/profile/*`, and `/patron-saint/:name`.

**Layer 3: The repo switch** (`repo_providers.dart`)

This is the most important file for understanding the app. `useDbReposProvider` (a bool, default true) flips every feature between a real `Db*Repository` and a `Fake*Repository`:

```dart
final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  if (!ref.watch(useDbReposProvider)) return FakeTodayRepository();
  return DbTodayRepository(ref.watch(dbProvider), dailyVerseRepository: ...);
});
```

Every feature follows this exact shape. Flip one flag and the whole app runs on fakes, useful for UI work and tests.

Shared singletons wired here: `dbProvider` (the Drift `AppDatabase`), `calendarEngineProvider`, `dailyReadingsRepositoryProvider`, `dailyVerseRepositoryProvider`.

**Layer 4: Repositories**

A `Db*Repository` is not just a DB wrapper. It is a composition point that pulls from all three data sources and returns a finished `*ScreenState`.

Example: `DbTodayRepository.fetchTodayScreen()`:
- JSON assets: `dailyVerseRepository.loadForDate()` for today's verse.
- Drift: `StreakDao` for today's streak status.
- Assembles both into a `TodayScreenState`.

`DbCalendarRepository` is the richest example. It is constructed with all three sources: `db + engine (CalendarEngine) + saintsRepository (assets) + dailyReadingsRepository (assets)`.

**Layer 5: Data sources** (see Section 3 below).

**Layer 6: Adapters** (`screen_state_adapters.dart`)

Screens do not read raw `*ScreenState` directly. They wrap it: `TodayAdapter(state).verseCard`, `PrayersAdapter(state).primaryTitle`, `CalendarAdapter(state).fastingGuidance`. The adapter is a thin view-model that exposes safe getters (with fallbacks like `_safeText(...)`) and maps `iconKey` strings to `IconData`. This keeps widgets simple and presentation logic testable.

---

## 3. Data sources: the critical split

Understand this or you will make wrong changes.

| Source | Holds | Examples |
|---|---|---|
| Drift / SQLite | User state and Bible content | saved_items, reading_progress, streak_events, prayer_schedule, prayer_completions, personal_prayers, `bible_books`, `bible_verses`, and `bible_verses_fts` |
| JSON assets (via `rootBundle`) | Content except Bible | Synaxarium (2.7 MB), readings plans, mezmur metadata, daily verses, saints index, FAQ |
| CalendarEngine | Computed truth | Ethiopian dates, fasts, feasts, Bahire Hasab, via abushakir |

### Rules

- **Never store content in the database except the Bible.** All other content lives in JSON assets.
- **Never store user state in JSON assets.** User state lives in Drift.
- **A repository's job is to join these sources into a screen state.**

### First-launch content pack

Bible verses are seeded into Drift on first launch:

- On first launch, if `bible_verses` is empty, run a one-time seed job that reads the bundled JSON (Amharic and English) and inserts it into Drift.
- Populate the FTS5 virtual table from the same source in the same transaction.
- Mark completion in the `meta` table so seeding does not re-run.
- Migration path: `schemaVersion` bumps from 4 to 5 with the new tables.
- Version the content pack in `meta` so future updates can trigger a re-seed if the pack version changes.

The seed should not block the UI. Show a "preparing your library" state on first launch if it takes more than a second.

---

## 4. Drift schema

`schemaVersion` is currently 5.

### Tables

- `meta` (key-value)
- `saved_items` (bookmarks)
- `reading_progress` (continue reading)
- `streak_tasks` (3 required tasks plus bonus task definitions)
- `streak_events` (per-day completion)
- `prayer_schedule` (time slots)
- `prayer_completions` (per-day per-slot completion events)
- `personal_prayers` (signed-in personal prayer list entries)
- `bible_books` (id, canon_id, testament, order_index, name_en, name_am, abbrev_en, abbrev_am)
- `bible_verses` (book_id, chapter, verse, text_en, text_am, PRIMARY KEY(book_id, chapter, verse))
- `bible_verses_fts` (FTS5 virtual, mirrors `bible_verses`, columns: text_en, text_am, book_id UNINDEXED, chapter UNINDEXED, verse UNINDEXED)

### Streaks table update in v5

`streak_tasks` has an `is_bonus` column (default 0) so we can mark the 3 optional tasks (Daily Saint, Feasts and Fasts, Daily Tip) as bonus.

### Migration notes

- Migration 4 -> 5 creates the Bible tables, the personal prayer sync table, and marks the Bible seed as pending.
- On next launch after upgrade, the seed job runs (see Section 3).
- Do not drop existing user data. Never.

---

## 5. Repo folder structure

```
lib/
  main.dart, firebase_options.dart
  app/
    app.dart, app_router.dart, app_shell.dart, route_paths.dart
  core/
    actions/       ...
    adapters/      screen_state_adapters.dart
    auth/          firebase auth wrappers
    calendar/      calendar_engine.dart plus models and observance store
    content/       ...
    db/            drift tables and DAOs and generated .g.dart
    firebase/      init helpers
    icons/         ...
    models/        ui_contract_models (ScreenState types)
    profile/       ...
    providers/     repo_providers.dart, screen_state_providers.dart
    readings/      ...
    repos/
      db/          real repositories
      fake/        fake repositories (UI/test mode)
      guards/      ...
    notifications/ ...
    onboarding/    ...
    sync/          ...
    streak/        ...
    theme/         app_theme.dart (deepPurple is placeholder)
  features/
    bible/         application, data, presentation
    calendar/      application, data, presentation
    explore/       presentation
    prayers/       application, data, presentation
    profile/       presentation
    streak/        presentation
    today/         application, data, presentation
test/
  auth/, bible/, calendar/, notifications/, onboarding/, sync/, widget_test.dart
assets/
  content/         all JSON
  audio/           mezmur and Hear Today's Word
  ...
```

### Feature-first pattern

Each feature under `lib/features/<feature>/` has three subfolders:

- `application/`: state notifiers, controllers, use cases
- `data/`: feature-specific data code (asset-only Bible flow lives here, not core/repos)
- `presentation/`: screens and widgets

This pattern is followed consistently at about 85 percent. One exception to keep in mind:

1. `core/repos/` has parallel `db/` and `fake/` trees for every repo. This is intentional (per the repo switch pattern), not smell.

---

## 6. The calendar engine

Location: `lib/core/calendar/calendar_engine.dart` (about 670 lines).

Related files:
- `lib/core/calendar/calendar_engine_models.dart` holds the date, observance, feast, fast, and Bahire Hasab data models returned by the engine.
- `lib/core/calendar/calendar_observance_store.dart` provides a small cache around daily and monthly engine lookups.

Uses `abushakir`: `EtDatetime`, `EthDate`, `BahireHasab`.

### Functions the engine exposes

- `ethDateFromGregorian` / `gregorianFromEthDate` - date conversion
- `getDayObservance(date)` - fast status, feasts, season progress, evangelist for any day
- `getMonthObservance(year, month)` - full month grid
- `getRangeObservance(from, to)` - N-day range
- `getAnchorsForYear` - Bahire Hasab derived movable anchors: Nineveh, Abiy Tsom, Hosanna, Siklet, Easter, Ascension, Pentecost, Apostles
- `getBahireHasabStatsForYear` - evangelist, amete-alem, abekte, metkih, wenber, Meskerem-1 weekday
- `getMovableCelebrationsForYear` - from `bahire.allAtswamat`
- Fixed feasts (Meskel, Genna, Timket, Filseta, etc.), the Wed and Fri weekly fast (with 50-days-of-Easter and feast exemptions), all major fasting seasons, and Gahad days

### Hard constants worth naming

There are hardcoded offsets like `_offsetEaster = 69` and a Geez-month-name to month-number reverse lookup. These are exactly the kind of logic that needs tests.

### Testing requirement

Golden-date tests exist and must pass in CI before shipping. Current coverage:

- Easter for at least 2 known Ethiopian years
- Nineveh, Timket, Genna, Meskel for at least 2 years
- Wed and Fri fast status for a sample week in and out of the 50 days of Easter
- Ethiopian year boundary correctness around Meskerem 1

Location: `test/calendar/calendar_engine_test.dart`.

---

## 7. Conventions (rules for new code)

These are firm. Break them only with a documented reason.

1. **No hardcoded UI strings.** All new widget text goes through the localization layer (once scaffolded in Phase 2) or a central strings file. If a strings file does not yet exist for your feature, create one. Do not write `'Prayer Reminders'` directly in a widget.

2. **Use `RoutePaths`, never string literals for routes.** Every new route gets a template and a type-safe builder in `route_paths.dart` and is referenced by that.

3. **Follow the repo switch pattern.** Any new feature that reads data needs a repository interface, a `Db*Repository` implementation, and a `Fake*Repository` implementation, wired through `repo_providers.dart`.

4. **Never mix content and user state.** Content goes to JSON assets (except Bible, which goes to Drift). User state goes to Drift. If you find yourself putting user state in an asset or content in `saved_items`, stop.

5. **Screens read `*ScreenState` through adapters, never raw DB queries.** No `db.query(...)` calls inside a widget. Use the pipeline.

6. **New database changes require a migration and a schemaVersion bump.**

7. **Golden tests for calendar logic.** Any new calendar function ships with test coverage against known dates.

8. **Sign-in gating goes through a single guard.** Do not sprinkle `if (user == null)` all over widgets. Use the guards in `core/repos/guards/` (or add one there) so gating is consistent and auditable.

9. **No new hardcoded colors either.** Use `app_theme.dart`. The current `deepPurple` seed is a placeholder and will be replaced.

10. **When you find a "share not implemented" or similar TODO, either fix it or open an issue.** Do not add more silent stubs.

---

## 8. Firebase and sync

### Auth

- Firebase Auth is the identity source of truth.
- Email + password and Google Sign-In are wired.
- Apple Sign-In is required for iOS App Store approval if we offer third-party sign-in. This is an open task.

### Firestore sync scope

Signed-in user data that syncs to Firestore:

- Bookmarks (`saved_items`)
- Streak history (`streak_events`)
- Personal prayer list ("Pray for me")
- Prayer completion events (feeds streak)
- Prayer schedule settings

Sync pattern: local Drift is the source of truth on device. On write, mirror to Firestore. On startup, flush the local retry queue, pull remote changes, and merge. Firestore handles its own offline write persistence; the local retry queue covers write failures and retries on the next startup. Last-writer-wins for simple fields, with per-item timestamps.

### Offline behavior

- Sign in once, then all features work offline.
- Writes queue locally and sync when back online.
- The signed-out user experience is fully offline by design (no writes, no sync).

### Firestore data model

- Collection `users/{uid}/bookmarks/{itemId}` -> `{ id, title, kind, createdAtIso, updatedAtIso, body?, deleted }`
- Collection `users/{uid}/streaks/{eventId}` -> `{ id, dateYmd, taskId, completedAtIso, updatedAtIso, deleted }`
- Collection `users/{uid}/prayerCompletions/{completionId}` -> `{ id, dateYmd, slotId, completedAtIso, updatedAtIso, deleted }`
- Collection `users/{uid}/prayerSchedule/{slotId}` -> `{ id, slotId, label, timeLocal, isEnabled, updatedAtIso }`
- Collection `users/{uid}/prayerList/{id}` -> `{ id, name, intention, createdAtIso, updatedAtIso, dueAtIso?, deleted }`

Security rules live in `firestore.rules` for manual deployment.

---

## 9. Notifications

Prayer notifications are implemented with local scheduling:

- Package: `flutter_local_notifications` + `timezone` + `flutter_timezone`.
- Initialize the timezone database and local timezone on startup.
- Read `prayer_schedule` and schedule a repeating daily notification per enabled slot.
- Reschedule on any edit to `prayer_schedule`.
- Handle permission requests explicitly on iOS and Android 13+.
- Android uses `USE_EXACT_ALARM`, boot receivers, core library desugaring, and `AndroidScheduleMode.exactAllowWhileIdle`.
- iOS sets the UNUserNotificationCenter delegate and requests alert, badge, and sound permissions.
- Consider a "quiet hours" setting (mentioned in old planning docs) as a nice-to-have.

### Tapping a notification

Deep link to `/prayers/:id` for that slot. Reuse `RoutePaths`.

---

## 10. Testing

Current state: Phase 1 has focused coverage across calendar, notifications, Bible migration and FTS, sign-in gating, sync, onboarding, and the app smoke test.

MVP testing floor:

- Calendar engine golden-date tests.
- Reading plan reference parser tests (handles LXX Psalm remapping, chapter/verse ranges, festal hiatus).
- Streak logic tests (does not double-count, handles timezone edges).
- Drift migration tests (v4 -> v5, especially the Bible seed).

`flutter analyze` and `flutter test` must be clean before merging.

---

## 11. Known technical risks

1. Calendar expectations are covered by golden tests, but current approved sources are not the official Ethiopian Orthodox Tewahedo Church synod. Priest or scholar review is required before public launch.
2. `sqlite3_flutter_libs` latest is marked end-of-life. Track a replacement.
3. Riverpod v2 to v3 upgrade is deferred but coming.
4. No localization scaffolding despite bilingual mandate.
5. Firebase is a network dependency in an app that markets as offline-first. Doc language and gating rules address this, but it is worth being explicit with users.
6. Sync conflict resolution across devices is not designed in detail yet. Simple last-writer-wins is the starting point.
7. Content sourcing risk: some content (especially Mezmur) does not have confirmed rights.

---

## 12. Deviations from the code as of the last audit

Known deviations to track:

- `app_theme.dart`: `seedColor: Colors.deepPurple` marked as placeholder.
- Working branch `codex/mezmur-library-player` needs review before merge to main.

---

## 13. Two files to read first

If you have one hour to understand this codebase, read these two files:

1. `lib/core/providers/repo_providers.dart` - the wiring hub and the db-vs-fake switch.
2. `lib/app/route_paths.dart` - the navigation map.

Between them you know where every screen gets its data and where every URL is defined.
