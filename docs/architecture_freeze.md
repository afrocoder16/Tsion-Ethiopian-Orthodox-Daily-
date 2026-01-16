Architecture Freeze (M0-M5.3)

Locked
- UI contracts in `docs/ui_contract.md`.
- ScreenState DTOs and repository interfaces.
- Fake vs DB repository split and provider toggle.
- DB schema and DAOs defined in `lib/core/db/`.
- ScreenState guards and adapters.

Rules for Changes
- Contract changes require a new versioned contract doc and team sign-off.
- Backward-incompatible changes must be additive first, then migrated.
- DB schema changes require a migration plan and updated DAOs.
- Repos must remain Flutter-free and return valid ScreenState data.
- Any new data fields must be added to guards and tests.
