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

**Last audit**: 2026-07-06 (Phase 1 claim audit + full architecture audit).

**Branch**: `main`. Phase 1 was reviewed and merged to main on 2026-07-06 (fast-forward from `codex/mezmur-library-player`; the doc-only `codex/iphone-test-run-report` handoff branch was folded in first, see `TEST-ONCE-README.md`). Phase 2 work happens on new feature branches off main.

**Builds**: yes, cleanly. `flutter analyze` is clean and the Phase 1 test suite (24 tests) is green as of the latest run. The content assets referenced by `pubspec.yaml` (Bible am/en JSON, readings, daily verse) are tracked in git, so fresh clones build; previously `.gitignore` excluded all of `/assets/` and the iPhone test run on the Mac failed on missing assets. iOS: `ios/Podfile` added and deployment target raised to 15.0 (Firebase requires it). iOS signing on the test Mac uses team D8ZVP9436N, bundle id com.samson.tsionOrthodoxDaily — those signing values live only on the Mac, do not wipe them there. A real-device iOS run has not completed yet; that is the next validation step.

**Architecture audit outcomes (2026-07-06)**: Ethiopian month names/aliases live in `core/calendar/ethiopian_months.dart` (single source; calendar, synaxarium, and saints repos delegate to it — celebrations kept a stricter local matcher on purpose). `mezmur_screen.dart` is split into part files (`_art`, `_sections`, `_player`, `_subscreens`). Known debt, in priority order: audio player lives in mezmur widget state (extract a controller before any background-audio work), ~430 hardcoded colors and ~120 hardcoded strings in feature screens (Rules 9 and 1), big JSON parses run on the UI thread (wrap in `compute()`), `_ethMonthAmharic` still returns English names (content decision), `screen_state_adapters.dart` is one 45-class file.

**What is done**:

- Calendar engine (rich, using abushakir) with golden-date tests, Today home, Bible library and reader in Drift with FTS5 search, deep-links, prayers hub and detail, prayer schedule editor, local prayer notifications, calendar today/month/day views, daily readings with the reference parser, Synaxarium (2.7 MB), profile and auth (Firebase, email/password and Google), sign-in gating, Firestore sync service and rules, streaks (3-task version), onboarding, mezmur player, Hear Today's Word audio.

**What is partial**:

- Saints "daily" coverage outside Synaxarium is thin.
- Settings live scattered under Profile, no unified hub.
- Explore tab has real structure but content is being sourced.
- Firestore sync has the MVP service, queue, startup pull, and rules. There is no explicit connectivity listener because no connectivity dependency is approved; Firestore offline persistence handles reconnect and startup flush handles local queue retries.

**What is missing**:

- Localization scaffolding (no ARB, no l10n). Phase 2, but no new hardcoded strings from now on.
- Unified Settings hub.
- Content sourcing and rights confirmation before public launch.
- Apple Sign-In if iOS ships with Google Sign-In.

**Open questions** (do not guess these, ask):

- Mezmur audio rights.
- Apple Sign-In for iOS App Store.
- Branding: tagline, final colors, logo. Current theme uses `Colors.deepPurple` as a placeholder.
- License for the repo.
- Exact Amharic Bible source and public-domain confirmation.
- Synaxarium rights confirmation.

---

## What to work on next

Post-Phase-1 priority order. Do not jump ahead unless the founder says so.

1. **Settings hub**. Consolidate the settings scattered under Profile into one place.
2. **Content sourcing and rights pass**. Confirm Mezmur audio rights, Synaxarium rights, Amharic Bible source, and sources for Ethiopian unique books before public launch.
3. **Apple Sign-In decision**. Add Apple Sign-In if iOS ships with Google Sign-In.
4. **Explore content wiring** as the founder sources it.
5. **Phase 2 localization scaffold**. Add ARB/l10n and retrofit existing UI strings.
6. **Release hardening**. Priest or scholar review of calendar expectations, app store metadata, branding, license, and final QA.

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

- **Calendar engine location**: `core/calendar/` is the real engine. The old empty legacy stub was removed.
- **Repo switch**: `useDbReposProvider` (default true) toggles the whole app between real repos and fakes. Useful for UI work and tests. Do not accidentally flip it in production code.
- **Bible passage flow is different**: Bible content is seeded from bundled JSON into Drift and searched through FTS5. Keep the JSON assets because the seed reads from them.
- **Streaks are a hub, not a leaf**: multiple features write streak events. `buildStreakTasks()` defines the tasks. Visiting `/streak/daily-verse`, a prayer, or readings marks that task complete.
- **Profile / Auth is a self-contained island** and does not participate in the repo switch pattern.
- **`sqlite3_flutter_libs` latest is EOL** at the time of the last audit. Do not blindly upgrade; check for a replacement.
- **Riverpod is v2, not v3.** Do not upgrade without a plan.
- **Local notifications are installed** for prayer reminders. Android exact alarms use `USE_EXACT_ALARM` and `AndroidScheduleMode.exactAllowWhileIdle`.

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
