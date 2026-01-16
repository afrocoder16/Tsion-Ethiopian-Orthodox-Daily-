UI Data Usage (M0-M5.3)

Overview
- ScreenState DTOs are the single source of truth for UI data.
- Repositories supply ScreenState data via Riverpod providers.
- Fake repositories are default for local development.
- DB repositories use Drift-backed DAOs to supply persisted data.

Providers
- useDbReposProvider controls whether DB repos are used.
- dbProvider must be overridden with a real AppDatabase instance.
- Each screen repository provider switches between Fake or DB based on useDbReposProvider.

Fake vs DB
- Fake repos return stable, contract-valid dummy data.
- DB repos mirror Fake content but replace specific sections with persisted data:
  - Explore saved list uses SavedItemsDao.
  - Books continue reading uses ReadingProgressDao.
  - Prayers uses PrayerCompletionsDao to mark recent status.
  - Today uses StreakEventsDao to summarize streak completion.

User Actions
- toggleSave: add/remove saved items.
- setReadingProgress: upsert reading progress.
- completeStreakTask: record streak completion.
- completePrayer: record prayer completion.

Debug Guards
- ScreenState guards run in debug only.
- Guards validate required fields and IDs for contract safety.
