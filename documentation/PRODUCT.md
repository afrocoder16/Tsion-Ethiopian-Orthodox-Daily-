# Tsion Orthodox App: Product Specification

This document defines what Tsion is, what ships in MVP, what waits for Phase 2, the rules that govern sign-in, and the open questions that are not yet answered.

If any of this document conflicts with the code, either the code is wrong or this document is out of date. Fix whichever is wrong and update the other side.

---

## 1. Vision

Build a daily-use Ethiopian Orthodox app that helps believers keep the Church rhythm in their pocket:

- Ethiopian calendar (13 months) with accurate feasts and fasts via Bahire Hasab
- Verse of the Day, Daily Readings, Daily Saint, and short teachings
- Prayer routine with reminders (4 times default, 7 times option, custom schedule)
- Offline-first Bible with the Ethiopian Orthodox canon structure (81 books)
- Streaks that reward consistency
- Optional sign-in for cloud sync, Mezmur playback, and personal features

## 2. Non-goals for v1

- Full social network or chat platform
- Live-stream hosting (audio comes from a curated library)
- Replacing priest guidance. Any future AI features are assistive only

## 3. Success criteria (measurable)

- D7 retention: users returning at least once per day in the first week
- Daily hub completion rate (Verse, Prayer, or Readings opened)
- Calendar trust: near-zero calendar bug reports, validated against known dates
- Offline reliability: core features usable with no internet
- Content correctness: releases signed off after review

---

## 4. The six locked decisions

These were decided after auditing the code and are the ground truth for scope. Any change to these needs a conscious update to this document.

### Decision 1: Content storage (hybrid)

- Bible verses live in local SQLite with full-text search (FTS5), both English and Amharic, searchable across the whole Bible in both languages.
- Everything else (prayers, saints, readings plans, mezmur metadata, verse-of-the-day, FAQ) stays as JSON assets loaded at runtime.
- Rationale: real verse search is a core Bible feature. Other content is small enough that JSON is simpler and works fine.

### Decision 2: Firebase and offline

- Sign-in is optional but unlocks meaningful features (see Section 6).
- Signed-in users: sign in once, the app works offline afterward, and it syncs when back online.
- Signed-out users: the app works fully offline with a meaningful subset of features.
- Firebase (auth + Firestore) stays for now. Supabase is noted as a future consideration but not planned.

### Decision 3: Explore tab

- Explore stays visible in MVP.
- The founder is sourcing real content for Sunbit Timhert Bet, Guided Paths, Community, and Explore categories.
- Community features (Ask a Question, Read Reflections, Community Prayers) are deferred to Phase 2 in terms of interactivity. In MVP they can be view-only or come-soon states if content is not ready.

### Decision 4: Prayer notifications

- Core MVP pillar. High priority for Phase 1.
- The app currently saves reminder times but never fires them. This is the biggest specced gap.
- Implementation: flutter_local_notifications plus timezone package, wired to the existing `prayer_schedule` table.

### Decision 5: Amharic interface localization

- Phase 2. Full ARB / l10n scaffolding retrofit is not a Phase 1 task.
- Hard rule from now on: no new hardcoded UI strings. All new widget text goes through the localization layer (once scaffolded) or a central strings file so retrofit is possible without touching every widget.
- Bible content is already bilingual at the data layer.

### Decision 6: Streaks

- 3 required tasks: Daily Verse, Prayer, Readings.
- 3 optional bonus tasks: Daily Saint, Feasts and Fasts, Daily Tip.
- Streak is kept if all 3 required tasks are completed for the day. Bonus tasks add to a "bonus" counter but do not affect the base streak.
- This replaces the earlier "0/6 style" streak in old planning docs.

---

## 5. Feature list (MVP scope)

Each feature is marked with its status as of the last audit and the source of truth for its behavior.

### 5.1 Today Home

Route: `/home`. Bottom tab: Today.

- Verse of the Day hero card. Tap opens the Bible at that verse.
- "Hear Today's Word" audio card. Plays inline.
- Orthodox Daily horizontal carousel, in this order: Prayers, Daily Readings, Feasts and Fasts, Daily Saint, Orthodox Tip, Guidance (FAQ), Mezmur, Pray for me list, Nearby Church.
- Daily Practice widget: 3-task streak status, weekly progress bar.

Offline: yes. Sign-in required: no.

### 5.2 Bible

Routes: `/books/bible`, `/books/bible/:book/:chapter`, plus legacy `/bible/...`.

- 81-book Ethiopian canon structure supported. English currently has real text for 77 of 81 books.
- Book list, chapter navigation, verse display.
- Deep link from Verse of the Day and Daily Readings opens the exact passage.
- Continue reading from last position.
- Full-text verse search (Phase 1 migration to SQLite + FTS5, both English and Amharic).
- Bookmarks require sign-in (see Section 6).

Offline: yes. Sign-in required: only for bookmarks.

### 5.3 Prayers

Route: `/prayers` and `/prayers/:id`.

- Prayer hub with a "prayer for this moment" card that surfaces the currently appointed prayer.
- Prayer detail with text (Amharic and English content) and completion button.
- Prayer schedule editor: 4-time default, 7-time option, custom times allowed.
- Completion tracking, feeds streak.
- Reminders (local notifications) that actually fire when configured. Phase 1 build.
- Related: Mezmur (audio), Kidase (worship service reference), Light a Candle, Daily Reflection, Fasting Guidance.

Offline: yes for prayer text and schedule. Sign-in required for streak history, Light a Candle, Daily Reflection, and Mezmur playback.

### 5.4 Calendar (Feasts and Fasts)

Routes: `/calendar`, `/calendar/today`, `/calendar/month`, `/calendar/day`.

- Ethiopian date and Gregorian date shown side by side.
- Today view: fast status, current fast season, feasts and commemorations.
- Month view: Ethiopian month grid with fasting and feast indicators.
- Day detail: full observance, links to saint, readings, prayers.
- Powered by the calendar engine (see ARCHITECTURE.md) using Abushakir.

Offline: yes. Sign-in required: no.

### 5.5 Daily Readings

Route: `/readings/today`.

- Reading list for today, resolved through the reading plan (12 monthly JSON plans).
- Tap opens the passage in the Bible.
- Handles Ethiopian date lookups, LXX Psalm remapping, festal hiatus.

Offline: yes. Sign-in required: no.

### 5.6 Saints

Routes: `/saints`, `/saints/:id`, plus Synaxarium entries and `/patron-saint/:name`.

- Daily saint card.
- Saints list with search.
- Saint detail with summary and full text.
- Synaxarium: rich per-day entries with bookmarks.
- Patron saint feature.

Offline: yes. Sign-in required for bookmarks.

Note: the curated `saints_index.json` is thin. The Synaxarium is rich. Filling out the daily saints coverage outside Synaxarium is content work, not code work.

### 5.7 Streaks and Daily Practice

Route: `/streak/*`.

- Daily practice screen with the streak circle and weekly bar.
- 3 required tasks: Daily Verse, Prayer, Readings.
- 3 bonus tasks: Daily Saint, Feasts and Fasts, Daily Tip.
- Streak logic: base streak requires all 3 required tasks for the day. Bonus tasks tracked separately.

Offline: local streak works. Sign-in required for the whole feature per Decision 6 refinement (see Section 6). Signed-out users see a prompt to sign in to start tracking.

### 5.8 Explore

Bottom tab: Explore.

- Sunbit Timhert Bet: structured learning (Mistere Beta Kristiyan, Life in the Church).
- Guided Paths: New to Orthodoxy, Understanding the Liturgy, Living the Fast.
- Community: Ask a Question, Read Reflections, Community Prayers (interactivity deferred to Phase 2).
- Explore Categories and Content sections.

Offline: read-only content should work offline. Sign-in required: view is open, interactivity (post, ask) needs sign-in and is Phase 2.

Content sourcing: in progress.

### 5.9 Profile and Sign-in

Routes: `/profile/*`.

- Email and password sign-in via Firebase.
- Google Sign-In.
- Sign-in method for iOS App Store approval is an open question (see Section 8).
- Profile screens: edit profile, forgot password, notification settings, prayer reminders editor.

Sign-in required: yes for the profile area itself.

### 5.10 Settings

Not fully unified today. Preferences live inside Profile (calendar display mode, Ethiopian vs Gregorian feast calc, reminder times). MVP goal is a single Settings hub, but this is medium priority.

### 5.11 Guidance / FAQ

Route: `/guidance` and Fasting Guidance card.

- FAQ list with search, no AI in MVP.
- AI-powered guidance is a Phase 2 consideration only, and only with citations and a "not a priest" disclaimer.

### 5.12 Nearby Church

MVP: opens external maps search. Full directory is Phase 2.

---

## 6. Sign-in gating rules

The rule: **the app is usable and meaningful without signing in. Sign-in unlocks personal features, cross-device sync, and premium content.**

### Signed-out user can:

- Read the Bible
- View the Calendar, Feasts and Fasts, and Day details
- Read Daily Readings
- View Daily Saint and browse Saints
- Read Prayer text and view the schedule
- Read the Verse of the Day
- Play the "Hear Today's Word" daily audio card
- Read Guidance / FAQ
- Browse Explore content (interactivity is Phase 2 anyway)
- Read Fasting Guidance

### Sign-in required for:

- Bookmarks (create and view)
- Streak tracking and daily practice progress (no streak without sign-in)
- Personal prayer list ("Pray for me / family")
- Mezmur playback (streaming, no full MP3 downloads for offline)
- Light a Candle
- Daily Reflection
- Marking prayers complete (since completion feeds streak, and streak requires sign-in)
- Anything on the Profile screens

### Offline behavior for signed-in features:

- Sign in once, then all sign-in features work offline afterward.
- Local writes queue and sync when the device is back online.
- Firestore is the sync target. Local Drift is the source of truth on device.

### Signed-out prompt pattern:

When a signed-out user taps a gated feature, show a friendly prompt explaining what sign-in unlocks with a "Sign in" button and a "Not now" option. Do not block the user from continuing to use the free parts of the app.

---

## 7. Content and rights

All content in the app is sourced as public domain or otherwise clearly rights-cleared, with the following notes:

- **English Bible**: World English Bible (WEB) is the intended source. 77 of 81 books have real text as of the last audit. See `doc/english_bible_build_notes.md` in the repo for status.
- **Amharic Bible**: public domain source. Which specific version needs to be documented once confirmed. New Amharic Standard Version is copyrighted and is not used.
- **Synaxarium**: source PDFs are in the repo. Rights need to be confirmed in writing before release.
- **Mezmur audio**: rights are unclear as of this document. This is an open question.
- **Ethiopian unique books (Enoch, Jubilees, etc.)**: public domain English translations available for at least some. Confirmed sources needed before enabling in the app.

Every content item in the app should have a documented source and rights confirmation before it ships. Nothing should be included on the assumption that it is fine.

---

## 8. Open questions

These are unresolved and must not be guessed at.

1. **Mezmur audio rights**: what are the exact tracks and confirmed rights per track?
2. **Sign-in methods**: is Apple Sign-In needed for iOS App Store approval? (Yes, if the app offers third-party sign-in like Google, Apple requires Apple Sign-In too. Confirm and add.)
3. **Firestore usage today**: firebase_core, firebase_auth, cloud_firestore are all in pubspec. Is Firestore actively being used, or only auth?
4. **Branding**: tagline, final color palette, logo. Current theme uses Colors.deepPurple as a placeholder.
5. **License**: repo has no LICENSE file. Decide before publishing publicly.
6. **App Store metadata**: name, subtitle, screenshots, description, category.
7. **Amharic Bible source**: exact version and confirmed public domain status.
8. **Synaxarium rights**: confirmed sourcing.
9. **Backend future**: revisit Supabase only if Firebase hits a specific limit or cost problem.
10. **Launch date**: not set.

---

## 9. Roadmap

### Phase 1 (MVP ship)

In priority order:

1. **Calendar engine tests**. Golden-date tests for known Easter, Nineveh, Timket, Genna, Wed-Fri fast status across at least 2 years. Non-negotiable.
2. **Prayer notifications**. flutter_local_notifications + timezone. Wire to prayer_schedule. Handle permissions.
3. **Bible SQLite migration**. Move both English and Amharic verses into Drift, add FTS5 tables, implement search across the whole Bible in both languages. Keep everything else as JSON.
4. **Sign-in gating**. Implement the gating rules from Section 6 consistently across features. Sign-in prompt component.
5. **Firestore sync**. Bookmarks, streak history, personal prayer list sync between device and cloud. Handle offline queue.
6. **Merge `codex/mezmur-library-player` to main** and clean up the second (unused) `core/calendar_engine/` directory.
7. **CLAUDE.md and the four docs live in the repo** so context is not lost between sessions.
8. **Content sourcing for Explore** as it becomes available.
9. **Onboarding flow**: first-launch prayer schedule preset choice, notification permission, sign-in prompt (optional).
10. **Settings hub**: consolidate settings scattered under Profile.

### Phase 2

- Amharic interface localization (full ARB + retrofit).
- Community interactivity (Ask a Question, Read Reflections, Community Prayers with posting).
- Mezmur offline downloads (Spotify-style, encrypted, tied to signed-in account).
- AI Guidance (curated content only, with citations, priest disclaimer).
- Full church directory with events.
- Cross-device sync beyond the MVP set.
- Broader saints coverage outside Synaxarium.
- Optional: revisit backend (Supabase) if scale or cost becomes a problem.

### Explicitly deferred beyond Phase 2

- Social features (feeds, follows, DMs).
- Live streaming.
- AI chat that is not source-cited.

---

## 10. What "done" means for MVP

The app ships when:

- Airplane mode works for: Verse of the Day, Bible open and read, Calendar today and month view, Saints daily view, Daily Readings open passage, Prayer text and schedule view.
- Verse of the Day tap opens the exact verse.
- Prayer schedule can be edited and notifications fire on time.
- Calendar engine returns correct observance for any date, validated by tests.
- Bible full-text search works for both English and Amharic.
- Sign-in unlocks the gated features, and offline behavior matches Section 6.
- Signed-in features sync between two devices.
- No new hardcoded UI strings have been added since the localization rule was set.
- Streak logic increments correctly and does not double-count or miss days across timezone edges.

MVP fails if any of the above are broken.
