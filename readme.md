# Tsion Orthodox App

An offline-first Ethiopian Orthodox daily companion for iOS and Android.

Tsion helps believers keep the Church rhythm in their pocket: Verse of the Day, an offline Bible (81 books, Amharic and English), a prayer routine with reminders, feasts and fasts driven by the Ethiopian calendar and Bahire Hasab, daily readings, daily saint, and a streak system that rewards consistency.

## Status

In active development. Solo developer: midvora.com.

Current branch of note: `codex/mezmur-library-player` (ready to merge into main).

## Platforms

iOS and Android, single Flutter codebase.

## Stack (short version)

- Flutter, Riverpod, go_router
- Drift (SQLite) for local storage
- Abushakir for Ethiopian calendar and Bahire Hasab
- flutter_local_notifications for prayer reminders (Phase 1, in progress)
- Firebase (auth, Firestore) for sign-in and cloud sync
- audioplayers for Mezmur playback

Content is public domain (see `documentation/PRODUCT.md` for details). Mezmur audio rights are an open question.

## Documentation

Four documents cover this project. Read them in this order:

1. **README.md** (this file). Orientation.
2. **documentation/PRODUCT.md**. What Tsion is, features, MVP scope, Phase 2, sign-in rules, roadmap, open questions.
3. **documentation/ARCHITECTURE.md**. How the code is organized, the data flow, schemas, conventions.
4. **CLAUDE.md**. Guide for Claude Code and any AI assistant working on this repo. Current status, gotchas, what to work on next.

If you are Claude Code or another AI assistant opening this repo, read CLAUDE.md first.

## Running the app

Standard Flutter workflow:

```
flutter pub get
flutter run
```

Requirements: Flutter 3.41+ on the stable channel, Dart 3.11+.

## License

To be decided.
