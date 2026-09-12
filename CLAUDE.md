# CLAUDE.md

Read this file first when working in the Tsion Orthodox app repository. It is the current project handoff, not a substitute for the deeper product and architecture documents.

## Project in brief

Tsion is an offline-first Ethiopian Orthodox daily companion built with Flutter for Android and iOS. Its core reading experience includes Today, an Amharic and English Bible, prayer texts, Ethiopian calendar data, Daily Readings, Synaxarium entries, Explore articles, and a three-task streak flow. Firebase is deliberately unconfigured, so account UI is hidden and personal features use local device storage.

Developer: solo, midvora.com.

## Read next

- `README.md` for setup and the shortest status overview.
- `documentation/PRODUCT.md` for product scope, content inventory, and release blockers.
- `documentation/ARCHITECTURE.md` for the data pipeline, navigation rules, and engineering conventions.
- `documentation/STATUS.md` for the latest audit, test results, feature walk, and file-level findings.

## Mental model

The standard feature pipeline is:

```text
GoRouter route
  -> Consumer screen
  -> screen-state provider
  -> repository provider and real/fake switch
  -> Drift, JSON assets, or CalendarEngine
  -> adapter and rendered widget
```

Start with these files:

- `lib/core/providers/repo_providers.dart` for repository wiring and the real/fake switch.
- `lib/app/route_paths.dart` for the route map.
- `lib/app/app_router.dart` for route construction and redirects.
- `lib/core/adapters/screen_state_adapters.dart` for UI view models.

## Current snapshot

Last audited: 2026-09-12.

Phase 1's eight workstreams are implemented. Phase 2 content packs now drive prayers, Explore, non-Bible books, Wudase Mariam, Daily Readings, daily verses, and the Synaxarium. This does not mean the product is release-ready.

Latest local verification:

- `flutter analyze`: clean.
- `flutter test`: see `documentation/STATUS.md` for the final pass count.
- `flutter build apk --debug`: succeeds and writes `build/app/outputs/flutter-apk/app-debug.apk`.
- Android emulator walk: startup, Today, Bible search and passage, Prayers, Wudase weekday sections, inline Calendar date selection, Synaxarium, and Daily Readings passage links exercised.
- `flutter doctor -v`: Android toolchain healthy; Visual Studio is missing only for Windows desktop development.

Content snapshot:

- Bible: 81 Amharic files and 81 English files.
- Standard prayers: 7.
- Wudase Mariam: 10 table-of-contents sections and 226 non-empty text blocks. Source metadata still reports 70 flagged pages, 55 missing transcript pages, 2 missing named sections, and 0 approved pages.
- Explore: 2 complete articles, no guided or community entries.
- Synaxarium: 366 daily entry assets; 24 entries flagged for missing confident primary-saint extraction.
- Daily Readings: 365 records but only 364 unique dates. `11-02` is duplicated, `03-06` and `12-25` are missing, and Pagumen 6 is marked as non-leap-year content.

## Mezmur is intentionally hidden

Mezmur code, data, player state, and assets remain in the repository. The feature is hidden from Today and Prayers, and `/prayers/mezmur` redirects to `/prayers`.

The controlling switch is `FeatureFlags.mezmurEnabled` in `lib/core/config/feature_flags.dart`. Do not remove the retained implementation. Re-enable it only after audio rights and product readiness are confirmed, then follow the verification steps in `documentation/ARCHITECTURE.md`.

## What works now

- Offline Bible seeding, reading, bilingual FTS5 search, deep links, and continue-reading state.
- Seven standard prayer texts plus the Wudase Mariam section reader.
- Ethiopian calendar month grid with inline selected-date details, feasts, fasts, saints, and Synaxarium access.
- Daily Reading references that open Bible passages when the source resolves to a structured book and chapter.
- Onboarding with four-time, seven-time, and custom prayer schedules.
- Local three-task streak tracking.
- Account routes redirect to local Settings while Firebase is disabled. Auth and Firestore code remains available but is not user-facing.
- Settings, reminders, bookmarks, reading progress, streaks, and personal actions work locally without a sign-in prompt.
- Leaf routes preserve their origin through `push`; direct deep links and custom back buttons use explicit fallbacks.

## Known incomplete or blocked work

- Correct the Daily Readings dataset errors before release.
- Proofread Wudase Mariam and the 24 flagged Synaxarium entries against approved sources.
- Replace Android and iOS example application IDs, configure Firebase, and add Android release signing.
- Decide whether Apple Sign-In is required for the iOS release.
- Re-enable accounts only after Firebase configuration and account-product decisions are complete.
- Add a real saints directory and search experience.
- Expand Explore beyond its two articles.
- Replace the sample patron-saint profile and persist its reminder.
- Implement prayer audio, Light a Candle persistence and hardware-light behavior, and Reflection journaling.
- Add localization infrastructure and replace the placeholder theme and launch branding.
- Complete physical-device notification QA and a real-device iOS run.

## Priority order

1. Correct and validate Daily Readings data.
2. Review Wudase Mariam and flagged Synaxarium source content.
3. Decide production IDs, configure Firebase, and configure release signing.
4. Configure and verify account migration from local-only mode when accounts are ready.
5. Add saints-directory and Explore content.
6. Complete Android and iOS physical-device QA.

Do not jump ahead when a change depends on a founder decision.

## Engineering rules

1. Do not add hardcoded UI strings. Use the strings or localization layer.
2. Use `RoutePaths`, never literal route strings in widgets.
3. Use `context.go` for root or tab replacement and `context.push` for leaf destinations.
4. Give direct-link leaf screens a safe back fallback through `popOrGo` or `FallbackBackScope`.
5. Follow the repository interface, `Db*Repository`, `Fake*Repository`, and provider-switch pattern for data-reading features.
6. Keep content in JSON assets and user state in Drift. Bible content is the deliberate exception because Drift and FTS5 power its reader and search.
7. Screens consume `*ScreenState` through adapters. Do not query Drift directly in widgets.
8. Database changes require a migration, schema-version bump, and migration tests.
9. Calendar logic changes require tests against known dates.
10. Sign-in gating belongs in the shared guard, not scattered null checks.
11. Do not add hardcoded colors. Use the app theme.
12. Do not expose placeholder content, inactive buttons, or dead tap surfaces.
13. Preserve unrelated user changes in a dirty working tree.

## Important gotchas

- `useDbReposProvider` defaults to true and switches all supported features between production and fake repositories.
- Bible assets must remain tracked because first-launch seeding reads them into Drift.
- The calendar engine in `lib/core/calendar/` is the authoritative Ethiopian-date implementation.
- Streaks are a hub. Daily Verse, Prayer, and Readings write streak events.
- Settings are available at `/settings`; Profile and auth remain a self-contained, disabled feature island.
- Firebase initialization is intentionally safe when `DefaultFirebaseOptions.isConfigured` is false.
- `FeatureFlags.accountFeaturesEnabled` controls account UI, route access, and sign-in gating. It is false until Firebase is configured.
- Riverpod is version 2. Do not upgrade it casually.
- `sqlite3_flutter_libs` is end-of-life; plan its replacement before changing it.
- Android exact prayer alarms use `USE_EXACT_ALARM` and `AndroidScheduleMode.exactAllowWhileIdle`.

## Founder decisions required

Ask before changing any of these:

- Public application IDs and app name.
- Mezmur tracks, audio sources, or audio rights.
- Apple Sign-In policy.
- Bible and Synaxarium source attribution or rights.
- Wudase Mariam approval criteria.
- Branding, final colors, logo, icon, splash, and store presentation.
- Repository license.
- Dependencies, architecture, sign-in boundaries, or MVP scope.

## Updating this handoff

Update the snapshot, blockers, and priority list when project status changes materially. Record detailed command results and feature-walk findings in `documentation/STATUS.md`. Check the current Git branch at runtime instead of encoding a long-lived branch assumption here.

Last updated: 2026-09-12.
