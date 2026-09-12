# Tsion Orthodox App: Product Specification

This document defines the product as it exists in the current codebase, the completed Phase 1 scope, the current content state, and the work that remains before release.

## 1. Vision

Tsion is an offline-first daily companion for Ethiopian Orthodox Christians. It should help a person return to prayer, Scripture, the Church calendar, the appointed readings, and the saints throughout the day without requiring an account for the core reading experience.

## 2. Product principles

- Core Scripture, prayer text, calendar, readings, and Synaxarium content work offline.
- Ethiopian and Gregorian dates are shown together where useful.
- Content accuracy is more important than breadth.
- Personal actions work locally without an account while Firebase is disabled.
- Unfinished features should not present dead controls or placeholder content.
- The app supplements Church life and priestly guidance. It does not replace either.

## 3. Phase 1 status

Phase 1 is complete across its eight planned workstreams:

1. Today hub and daily verse
2. Offline Bible library, reader, continue reading, and bilingual FTS5 search
3. Prayer hub, seven prayer texts, prayer completion, schedule, and local reminders
4. Ethiopian calendar with today, month selection, inline day details, feasts, and fasts
5. Daily Readings with reference parsing and Bible passage links
6. Daily saint and Synaxarium views, entries, and bookmarks
7. Three-task streak flow and onboarding
8. Optional Firebase account and sync implementation

Phase 1 completion means the implementation exists and its focused tests pass. It does not mean the app is release-ready. Firebase configuration, data correction, content review, identifiers, signing, branding, and device QA remain open.

## 4. Current content inventory

### Bible

- 81 Amharic book files and 81 English book files are bundled.
- Content is seeded into Drift on first launch.
- SQLite FTS5 supports Amharic and English search.
- Book, chapter, passage, search, deep-link, and continue-reading flows are implemented.

The exact Amharic source and rights status still require written confirmation. English and Ethiopian-canon source attribution also needs a final rights pass before release.

### Standard prayers

`assets/data/prayers.json` contains seven prayer records:

- Morning Prayer
- Midday Prayer
- Afternoon Prayer
- Night Prayer
- Trisagion Prayers
- Psalm 50
- Prayer of St. Ephrem

### Wudase Mariam

`assets/wudase_mariam.json` is integrated into Daily Prayer and Daily Prayers Books. The reader table of contents has 10 ordered sections:

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

The integration preserves 226 non-empty source text blocks. The supplied extraction metadata reports 0 approved pages, 70 flagged pages, 55 missing transcript pages, and 2 missing named sections. This is draft content. Every section must be checked against the scanned source before release.

### Daily Readings

Twelve monthly JSON plans are bundled. The current data has known structural errors:

- Ethiopian date `11-02` appears twice.
- Ethiopian dates `03-06` and `12-25` are missing.
- Pagumen 6 appears in a file marked `non_leap_year`.

The UI now opens a Bible passage when a reading reference resolves to a structured book and chapter. Unresolved references remain visible but cannot open a passage until their source data is corrected.

### Saints and Synaxarium

- A 366-day Amharic Synaxarium is bundled with daily and detail views.
- The source review manifest flags 24 entries that lack a confidently extracted primary saint.
- The separate curated saints index is thin, with 10 recurring-date records and one year-specific record.
- There is no standalone saints list or saints search route yet.
- The patron saint screen still uses sample profile content and is not linked from the Books UI.

### Explore

Explore is content-driven and hides empty sections. The current pack contains two complete articles and no guided-path or community entries. Community interactivity and category filtering are not implemented.

### Mezmur

Mezmur is intentionally hidden for this development phase. No Prayers card, Today carousel item, header icon, or other normal UI entry point is shown. Direct navigation to `/prayers/mezmur` redirects to `/prayers`.

The screens, player, controller state, metadata, and assets remain in place. Re-enable only after audio rights and product readiness are confirmed. The technical steps are documented in `ARCHITECTURE.md` and `STATUS.md`.

## 5. Feature behavior

### Today

Route: `/today`.

The Today tab shows the daily verse, daily devotion progress, and routed cards for Midday Prayer, Daily Readings, Feasts and Fasts, Today's Saint, and Light a Candle. Header shortcuts open Streak, Reflection, and Calendar. The audio card stays hidden until a real daily-audio source is available.

### Books and Bible

Primary routes start under `/books`. Legacy `/bible` routes remain for compatibility.

Users can open the Bible, select a book and chapter, read a passage, search Amharic or English text, resume reading, open the seven-prayer collection, and read Wudase Mariam by selected section. Book filters are not implemented and are not shown.

### Prayers

Primary routes start under `/prayers`.

Users can open and read the seven standard prayers and Wudase Mariam. Prayer completion, bookmarks, personal prayer lists, Light a Candle, and Daily Reflection use local device state while accounts are disabled. Prayer reminders can be configured during onboarding and through Settings. Prayer audio is not implemented, so its disabled switch remains an incomplete surface.

### Calendar and Daily Readings

Primary routes start under `/calendar`.

The Calendar tab keeps the full month grid at the top. Previous and next arrow buttons beside the month title change months, while direct month swiping is disabled. Selecting a date updates an inline section below it with the Ethiopian and Gregorian dates, weekday, Evangelist, celebrations, saints, and Synaxarium actions. It does not open a separate day screen. Legacy `/calendar/day/:date` links redirect to the same unified Calendar view with that date selected. Daily Readings can open structured references in the Bible. The known source-date errors in Section 4 still need correction.

### Saints

Daily saint content is served through the Synaxarium from Calendar, Today, and Streak. Synaxarium entry detail and bookmarks exist. A full saints directory, saints search, and a real patron-saint selection flow do not exist yet.

### Streak

Route group: `/streak/*`.

The implemented required tasks are Daily Verse, Prayer, and Readings. Local progress and weekly status are stored in Drift. Cloud synchronization cannot be exercised while Firebase is disabled.

### Onboarding

Onboarding supports four-time, seven-time, and custom prayer schedules. Completion and schedule persistence are implemented and tested.

### Settings, Profile, and sign-in

Settings is available from the Prayers, Calendar, and Explore headers. App preferences, prayer reminders, and notification controls work locally without an account.

Email/password and Google sign-in code remains in the repository, but all account entry points and prompts are hidden. Direct Profile and auth routes redirect to Settings while `FeatureFlags.accountFeaturesEnabled` is false. Apple Sign-In remains an iOS release decision.

## 6. Local-only account mode

Signed-out users can use Today, Bible reading and search, standard prayer text, Wudase Mariam, Calendar, Daily Readings, fasting guidance, daily Synaxarium content, Explore articles, and onboarding.

These actions are stored locally without sign-in while account features are disabled:

- Bookmarks
- Personal prayer list
- Prayer completion
- Light a Candle
- Daily Reflection
- Settings, prayer reminders, and notification preferences

Cloud synchronization does not run in local-only mode. The shared guards remain in code for future account support. The Mezmur gate is currently irrelevant because Mezmur is hidden globally.

## 7. Known release blockers

- Firebase options are not configured, so account UI and cloud sync are disabled.
- Android uses `com.example.tsion_orthodox_daily_app`.
- iOS uses `com.example.tsionOrthodoxDailyApp`.
- Android release builds still use the debug signing configuration.
- Apple Sign-In has not been decided or implemented.
- Readings have the duplicate, missing, and leap-day errors listed above.
- Wudase Mariam and 24 Synaxarium entries need source review.
- Explore content is thin.
- Saints list and search are missing.
- Light a Candle does not persist names or control the phone light.
- Daily Reflection does not accept or persist journal responses.
- Prayer audio is not implemented.
- The theme, app icon, splash, store metadata, license, and final rights confirmations remain open.

See `STATUS.md` for the latest verification commands and file-level findings.

## 8. Open founder decisions

Do not guess these:

1. Final application IDs and public app name
2. Apple Sign-In for iOS
3. Mezmur track list and rights per track
4. Exact Bible source attribution and rights
5. Synaxarium rights
6. Wudase Mariam approval process
7. Branding, icon, splash, and store presentation
8. Repository license

## 9. Next product priorities

1. Correct and validate the readings dataset.
2. Proofread Wudase Mariam and flagged Synaxarium entries against their scans.
3. Decide application IDs, configure Firebase, and set up release signing.
4. Define how locally stored personal data should join an account when accounts are enabled.
5. Add real saints-directory and Explore content.
6. Complete physical-device QA on Android and iOS.
