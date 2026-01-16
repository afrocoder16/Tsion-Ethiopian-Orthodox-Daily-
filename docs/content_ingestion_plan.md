Content Ingestion Plan

Definitions
- Content: immutable or infrequently changing data (texts, books, prayers, categories).
- User-state: per-user, mutable data (saved items, progress, streaks, completions).

Ingestion Strategy
- Source content as JSON/CSV with stable IDs.
- Validate and normalize IDs before import.
- Import pipeline writes content into DB tables or content packs.
- User-state is never imported from content sources.

Versioning and Updates
- Content bundles carry a `content_version`.
- Updates are applied as migrations or replaceable batches.
- Deprecated content remains readable but hidden if necessary.
- User-state remains intact across content updates.

Performance Guardrails
- Repos return data within a single async pass; no heavy joins.
- Today screen data must be fast: <= one read for streak status and one for today-specific content.
