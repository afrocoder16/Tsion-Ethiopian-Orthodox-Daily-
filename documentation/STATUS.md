# Tsion Project Status

Audit date: 2026-09-12

This is the detailed engineering handoff for the current checkout. Use `git branch --show-current` when beginning work instead of relying on a branch name copied into documentation.

## 1. Verification result

| Check | Result |
|---|---|
| `flutter analyze` | Passed with no issues |
| `flutter test --reporter compact` | 39 of 39 tests passed |
| `flutter build apk --debug` | Passed |
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk`, 194,989,158 bytes |
| Android emulator | Pixel 7, Android 17 API 37 |
| Flutter | 3.41.4 stable |
| Dart | 3.11.1 |
| Android toolchain | Healthy |
| Windows desktop toolchain | Visual Studio missing; unrelated to Android and iOS targets |

The Android walkthrough exercised startup, all five bottom tabs, Bible search, Bible passages, Daily Prayer, Wudase Mariam weekday sections, Calendar inline date selection, Synaxarium, Daily Readings, local Streak behavior, Explore articles, and local Settings.

The app starts and the debug APK installs and launches. Firebase account operations and cloud sync are intentionally hidden in local-only mode. Physical notification timing and a real-device iOS run were not validated because their required devices were not available.

## 2. Work completed in this audit

### Wudase Mariam

`assets/wudase_mariam.json` is registered in `pubspec.yaml` and parsed through `BookContentStore`. It appears in Daily Prayer and Daily Prayers Books with this exact order:

1. General Daily Prayer
2. Monday - Wudase Mariam
3. Tuesday - Wudase Mariam
4. Wednesday - Wudase Mariam
5. Thursday - Wudase Mariam
6. Friday - Wudase Mariam
7. Saturday - Wudase Mariam
8. Sunday - Wudase Mariam
9. Anqetse Birhan
10. Prayer of Conscience

Selecting a weekday opens that section rather than the start of the whole book. Back returns from the selected reader to the Wudase table of contents. A regression test verifies the section selection and return path.

The content is still a draft. The supplied metadata reports 226 non-empty blocks, 70 flagged pages, 55 missing transcript pages, 2 missing named sections, and 0 approved pages.

### Mezmur hidden safely

Mezmur is disabled through `FeatureFlags.mezmurEnabled` in `lib/core/config/feature_flags.dart`.

- The Prayers card is hidden.
- Today does not show a Mezmur card or shortcut.
- Unsupported header audio shortcuts are hidden.
- Direct navigation to `/prayers/mezmur` redirects to `/prayers`.
- The screens, player, state, data, and assets remain in the repository.

To re-enable it, confirm content and audio rights, set the feature flag to true, run analyze and all tests, and exercise the Prayers card, Today entry, deep link, sign-in gate, and player on a device.

### Daily Readings links

Daily Reading preview models now retain a resolved Bible book ID and chapter. The adapter exposes whether a reading can open in the Bible. A resolvable tile shows a chevron and opens the matching passage; an unresolved reference remains readable without pretending to be interactive.

### Calendar crash-state fix

The Calendar screen previously showed `Unable to load calendar` on an ordinary fasting day. `DbCalendarRepository` supplied an empty seasonal label while declaring the day a fast, which violated the screen-state contract. It now uses the resolved top fasting reason as the label. The month grid and inline day details rendered normally after rebuilding and reinstalling the APK.

### Unified Calendar day view

The full month calendar remains at the top of the Calendar tab. Tapping a day selects it in place and updates the Ethiopian date, Gregorian date, weekday, Evangelist, celebrations, saints, and Synaxarium actions below the grid. Previous and next arrow buttons now change months and preserve the selected day; direct month swiping is disabled. Five-week and six-week months share the available height without RenderFlex overflow. The selected date has a primary-color marker while the actual current day retains its green marker. The Spiritual Tracker was removed from the Calendar UI. Legacy `/calendar/day/:date` links redirect to this unified view instead of opening a separate day screen.

### Local-only Settings mode

Account UI is hidden while Firebase is unconfigured. Person shortcuts in Prayers, Calendar, and Explore are replaced by Settings shortcuts. `/profile` and its auth routes redirect to `/settings`, onboarding omits account setup, and shared sign-in guards allow personal actions to use local storage without displaying a prompt. The Firebase and Profile implementation remains in place behind `FeatureFlags.accountFeaturesEnabled` for later re-enabling.

## 3. Navigation audit and fixes

The following concrete navigation defects were found and corrected:

1. Wudase weekday rows opened the book without selecting the requested section. Section identity now flows through the repository, provider, route, and reader state.
2. Mezmur remained reachable by direct route even when removed from normal UI. The route now redirects while the feature flag is false.
3. Many leaf destinations used `go`, replacing the current location and losing their origin. Today cards, Today headers shortcuts, Prayers cards, prayer details, Bible results, book readers, Calendar items, Explore articles, and Daily Verse links now use `push` where they are leaves.
4. Several custom back buttons called `pop` even when there was no previous route. Daily Prayer, Streak, Synaxarium, Daily Readings, Reflection, Light a Candle, patron saint, and Profile now use a safe route fallback.
5. Top-level deep links to Streak, Profile, and patron saint had no useful hardware-back destination. `FallbackBackScope` supplies Today or Books as appropriate.
6. Unknown routes could strand the user on an error state. Router exceptions now recover to Today.
7. Loading and error variants of multiple leaf screens had no app bar and therefore no visible back path. Book detail, Reader, Bible library, Bible chapter, Bible passage, Prayer detail, and Daily Readings retain app-bar navigation in those states.
8. Daily Reading tiles looked like destinations but did nothing. Structured references now open the Bible passage; unresolved ones no longer advertise a tap.
9. Streak created screens directly with `MaterialPageRoute`, bypassing the route map. It now navigates with `RoutePaths`.
10. Today, Prayers, Calendar, and Explore displayed unsupported or dead header buttons. Only working actions remain visible.
11. Today exposed unrouted fake cards such as Daily Tip, Ask a Priest, and Find a Church. The screen now admits only known routed card IDs.
12. Books showed inactive filters and category chips. They were removed until filtering exists.
13. Explore showed inactive category chips. They were removed until filtering exists.
14. Today showed an inactive `See all` action. It was removed.
15. Book detail displayed a misleading Download control without a download workflow. It was removed; the real offline state remains.
16. Patron saint showed inactive favorite, share, and change controls. They were removed; its reminder card now has one working toggle surface.

Navigation regression tests cover the hidden Mezmur route, absence of Mezmur and fake cards from normal UI, unknown-route recovery, Wudase section selection and back behavior, legacy Calendar day links opening the selected date inline, and previous/next month controls across a six-week month.

## 4. Feature walkthrough

| Area | State | Notes |
|---|---|---|
| Startup and Today | Working | Loads real daily content and routed cards; no Mezmur surface |
| Books | Working | Bible and content books open; inactive filters removed |
| Bible library and chapters | Working | 81 bundled book files per language |
| Bible search | Working | Search returned results and a result opened the passage |
| Prayers | Working with gaps | Seven standard texts and Wudase work; prayer audio is not implemented |
| Wudase Mariam | Working, content review required | All 10 table-of-contents sections open directly |
| Calendar | Working | Arrow-based month navigation, full grid, inline selected-date details, celebrations, saints, and Synaxarium actions |
| Daily Readings | Working with data defects | Structured Gen 1 reference opened Genesis 1 during the walk |
| Synaxarium | Working, content review required | Daily entry, saved days, save action, and copy action render |
| Streak | Working locally | No account prompt while account features are disabled |
| Explore | Partial | Both bundled articles open and return correctly; no paths, community, or filters |
| Profile | Hidden | Profile and auth routes redirect to Settings while accounts are disabled |
| Settings | Working locally | Preferences, prayer reminders, and notification controls are available without an account |
| Onboarding schedules | Working | Four-time, seven-time, and custom schedules are covered by tests |

## 5. Broken, incomplete, and release-blocking items

### Content integrity

- Daily Readings contains 365 records but only 364 unique dates.
- `11-02` is duplicated across `july.json` and `june.json`.
- `03-06` and `12-25` are missing.
- `13-06` is present in `september.json` but marked `non_leap_year`.
- Wudase Mariam has the unresolved extraction and approval flags listed above.
- `synaxarium_needs_review.json` flags 24 entries with `no_primary_saint`.
- The separate saints index contains only 10 recurring-date records and one year-specific record.
- Explore contains only two articles and no guided or community entries.

### Product gaps

- Today audio is hidden because there is no real daily-audio source.
- Prayer detail still has a disabled Audio switch.
- Light a Candle does not persist names, and its flash toggle does not control the phone light.
- Daily Reflection displays questions but has no response input or persistence.
- Account and cloud-sync UI is hidden until Firebase is configured.
- There is no standalone saints list or saints search route.
- Patron saint uses sample data, has no normal entry point, and does not persist its reminder.
- Mezmur remains intentionally hidden pending rights and readiness.
- Localization infrastructure is absent, and the current theme and launch branding are placeholders.

### Configuration and release gaps

- `lib/firebase_options.dart` intentionally contains no configured Firebase project.
- Android still uses `com.example.tsion_orthodox_daily_app`.
- iOS still uses `com.example.tsionOrthodoxDailyApp`.
- Android release builds use debug signing.
- Apple Sign-In has not been decided or implemented.
- Bible, Synaxarium, Wudase Mariam, and Mezmur rights or approval decisions need written confirmation.
- Physical Android notification timing and real-device iOS behavior remain unverified.

## Recommended next work

1. Correct the Daily Readings duplicate, missing dates, and leap-day metadata from an approved source, then add dataset-integrity tests.
2. Review Wudase Mariam and the 24 flagged Synaxarium entries against source scans.
3. Choose production application IDs, configure Firebase, add release signing, and decide Apple Sign-In.
4. Define and test the migration from local-only personal data to an account before enabling Firebase UI.
5. Replace patron-saint sample data and add a real saints directory and search.
6. Expand Explore and complete physical-device Android and iOS QA.
