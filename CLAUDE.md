# CLAUDE.md

You are working in the Tsion Orthodox app repository. Read this file first.

This file exists so you do not re-audit the codebase from scratch every session. It gives you the mental model, the current status, the rules, and what to work on next. For depth, read the other three docs.

---

## The project in 3 sentences

Tsion is an offline-first Ethiopian Orthodox daily companion app built in Flutter for iOS and Android. It has a Today hub, an offline Bible in Amharic and English, prayers with schedule and reminders, feasts and fasts driven by the Ethiopian calendar and Bahire Hasab, daily readings, saints, and a streak system. Sign-in is optional but unlocks bookmarks, streak tracking, personal prayer list, Mezmur playback, Light a Candle, and Daily Reflection.

Developer: solo, midvora.com.

---

## Read these next when needed

- `README.md` for a quick overview.
- `documentation/PRODUCT.md` for what the app is, the features, MVP scope, Phase 2, sign-in rules, open questions.
- `documentation/ARCHITECTURE.md` for the technical guide (the 6-layer pipeline, schemas, conventions).

---

## The mental model (memorize this)

Router picks a screen. Screen watches a ScreenState provider. A repo switch hands it a Db*Repository. The repo joins three data sources: Drift (user state and Bible verses in Phase 1), JSON assets (all other content), and CalendarEngine (Ethiopian date and Bahire Hasab math via abushakir). An Adapter turns the ScreenState into a view-model the widget renders.

Two files reveal the whole architecture:

- `lib/core/providers/repo_providers.dart` (the wiring hub and db-vs-fake switch)
- `lib/app/route_paths.dart` (the navigation map)

Start there for any change.

---

## Current status snapshot (update this section as you work)

**Last audit**: 2026-06-13.

**Branch**: `codex/mezmur-library-player` (ready to merge to main).

**Builds**: yes, cleanly. `flutter analyze` shows 2 warnings, 0 errors (unused elements in `mezmur_screen.dart`).

**What is done**:

- Calendar engine (rich, using abushakir), Today home, Bible library and reader (77 of 81 English books have real text), deep-links, prayers hub and detail, prayer schedule editor, calendar today/month/day views, daily readings with the reference parser, Synaxarium (2.7 MB), profile and auth (Firebase, email/password and Google), streaks (3-task version), mezmur player, Hear Today's Word audio.

**What is partial**:

- Bible search is title-only, not full-text. Phase 1 to fix.
- Prayer schedule is a flat editable list, not the explicit 4/7/custom preset UX.
- Saints "daily" coverage outside Synaxarium is thin.
- Settings live scattered under Profile, no unified hub.
- Explore tab has real structure but content is being sourced.

**What is missing**:

- Prayer notifications (flutter_local_notifications not even installed). High priority Phase 1.
- Localization scaffolding (no ARB, no l10n). Phase 2, but no new hardcoded strings from now on.
- Content in Drift for Bible (currently JSON assets). Phase 1 migration.
- Onboarding flow.
- Calendar engine tests. Critical to add before ship.
- CLAUDE.md and the other docs are being added right now.

**Open questions** (do not guess these, ask):

- Mezmur audio rights.
- Apple Sign-In for iOS App Store.
- Firestore actual usage today (in pubspec but confirm usage).
- Branding: tagline, final colors, logo. Current theme uses `Colors.deepPurple` as a placeholder.
- License for the repo.

---

## What to work on next

Priority order for Phase 1. Do not jump ahead unless the founder says so.

1. **Calendar engine golden-date tests** in `test/calendar/calendar_engine_test.dart`. Cover Easter, Nineveh, Timket, Genna, Meskel across 2+ Ethiopian years, plus Wed/Fri fast status and Ethiopian year boundaries. Nothing else ships until this is green.
2. **Prayer notifications**. Add `flutter_local_notifications` + `timezone` to pubspec. Wire to `prayer_schedule`. Handle permissions. Deep-link taps to `/prayers/:id`.
3. **Bible SQLite migration + FTS5 search**. Bump `schemaVersion` to 5. Add `bible_books`, `bible_verses`, `bible_verses_fts` tables. Seed on first launch from bundled JSON (both English and Amharic). Wire search UI to real full-text queries.
4. **Sign-in gating**. Implement consistent gating for: bookmarks, streak, personal prayer list, Mezmur playback, Light a Candle, Daily Reflection, marking prayers complete. Use a single guard, not scattered null checks. Add a friendly "sign in to unlock" prompt component.
5. **Firestore sync**. Bookmarks, streak history, personal prayer list, prayer completions, prayer schedule. Local Drift is source of truth on device. Writes queue offline and sync on reconnect.
6. **Merge `codex/mezmur-library-player` to main** and delete the empty `lib/core/calendar_engine/` directory (the real engine lives in `lib/core/calendar/`).
7. **Onboarding flow**. First-launch prayer schedule preset (4-time, 7-time, custom), notification permission, optional sign-in prompt.
8. **Settings hub**. Consolidate the settings scattered under Profile into one place.
9. **Explore content wiring** as the founder sources it.

---

## Rules for any code you write

These are firm. If you break one, document why.

1. **No hardcoded UI strings.** Route through a strings file or the localization layer (once scaffolded). If you write `'Prayer Reminders'` in a widget, undo it.
2. **Use `RoutePaths`, never string literal routes.** Every new route gets a template and a type-safe builder there.
3. **Follow the repo switch pattern.** New data-reading features get a repository interface, a `Db*Repository`, and a `Fake*Repository`, wired through `repo_providers.dart`.
4. **Do not mix content and user state.** Content -> JSON assets (except Bible, which lives in Drift after Phase 1). User state -> Drift.
5. **Screens read `*ScreenState` through adapters.** No raw DB queries in widgets.
6. **DB changes need a migration and a schemaVersion bump.**
7. **Sign-in gating goes through one guard**, not scattered null checks.
8. **Every new calendar function ships with tests against known dates.**
9. **No new hardcoded colors.** Use `app_theme.dart`. `deepPurple` seed is a placeholder.
10. **If you find a TODO or "not implemented" comment, either fix it or open an issue.** Do not add more.

---

## Gotchas

- **Two calendar directories exist**: `core/calendar/` (real, keep) and `core/calendar_engine/` (empty stub, delete). Do not import from the stub.
- **`services_provider.dart` has a stale comment** claiming "Placeholders ONLY. No DB, no Abushakir, no notifications in v1.1." Both DB and Abushakir are in use now. Ignore or fix the comment.
- **Repo switch**: `useDbReposProvider` (default true) toggles the whole app between real repos and fakes. Useful for UI work and tests. Do not accidentally flip it in production code.
- **Bible passage flow is different**: it bypasses the main pipeline because it is pure content with no per-screen orchestration. Reads assets directly through `BibleAssetPassageRepository`. In Phase 1 this switches to Drift + FTS5.
- **Streaks are a hub, not a leaf**: multiple features write streak events. `buildStreakTasks()` defines the tasks. Visiting `/streak/daily-verse`, a prayer, or readings marks that task complete.
- **Profile / Auth is a self-contained island** and does not participate in the repo switch pattern.
- **`sqlite3_flutter_libs` latest is EOL** at the time of the last audit. Do not blindly upgrade; check for a replacement.
- **Riverpod is v2, not v3.** Do not upgrade without a plan.
- **Local notifications are not installed at all**. Prayer times are saved but never fire. This is the biggest specced gap.

---

## Signed-out vs signed-in behavior

Signed-out user can read the Bible, view the calendar and feasts and fasts, read Daily Readings, view Daily Saint, read prayer text, read the Verse of the Day, play the Hear Today's Word daily audio, and read Guidance / FAQ.

Sign-in is required for: bookmarks, streak, personal prayer list, Mezmur playback, Light a Candle, Daily Reflection, marking prayers complete (feeds streak), and the Profile screens.

Sign-in once, then all sign-in features work offline. Writes queue and sync when back online.

Do not put a signed-out user behind a wall. When they tap a gated feature, show a friendly prompt with what sign-in unlocks. Never block them from the rest of the app.

---

## When to ask the founder before proceeding

Ask before doing any of these. Do not assume.

- Adding a new dependency to `pubspec.yaml`.
- Changing the stack (state management, routing, DB).
- Changing what features are MVP vs Phase 2.
- Changing sign-in gating rules.
- Changing content sources.
- Anything in the "Open questions" list above.
- Any change that affects more than 10 files or touches architecture.

For everything else within the current priorities: proceed, and report back with what you did and why.

---

## How to update this file

When the status changes materially, update the "Current status snapshot" and "What to work on next" sections in this file. Keep the rules and the mental model stable. If a rule genuinely needs to change, discuss it with the founder first.

Last updated: initial creation, June 2026.
