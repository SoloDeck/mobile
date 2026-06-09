# Definition of Done

A feature is done when ALL of the following are true:

## Code

- [ ] Domain entity defined with Freezed
- [ ] Repository interface defined in `domain/repositories/`
- [ ] DTOs defined in `infrastructure/dto/` (Freezed + json_serializable)
- [ ] Mapper defined in `infrastructure/mapper/`
- [ ] Remote datasource implemented
- [ ] Repository implementation complete (offline-first if applicable)
- [ ] Use case(s) implemented for each user action
- [ ] Riverpod providers and notifier implemented
- [ ] Page widget and module widgets implemented

## Quality

- [ ] `flutter analyze` passes with zero warnings/infos
- [ ] `dart format` applied (CI enforces this)
- [ ] No `print()` statements
- [ ] No hardcoded strings (route paths use `RouteNames.*`)

## Tests

- [ ] Unit test for every use case (happy path + error path)
- [ ] Widget test for page widget
- [ ] Repository unit test with in-memory Drift (if Drift is used)

## Architecture

- [ ] No cross-module imports (except via `shared/`)
- [ ] No Dio calls from widgets or providers directly
- [ ] No `setState` in widgets with Riverpod providers
- [ ] Generated files are up-to-date and committed
- [ ] CLAUDE.md updated if new patterns introduced
