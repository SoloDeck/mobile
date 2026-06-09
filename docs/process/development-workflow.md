# Development Workflow

## Setup

```bash
git clone <repo>
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cp .env.example assets/env/.env
# Fill in API_BASE_URL in assets/env/.env
flutter run
```

## Feature Implementation Order

For each new feature, implement in this order:

```
1. domain/entities/         — Freezed data class
2. domain/repositories/     — Abstract interface
3. domain/exceptions/       — Module-specific exceptions
4. infrastructure/dto/      — Request/response DTOs
5. infrastructure/mapper/   — DTO ↔ Entity mappers
6. infrastructure/datasource/ — Remote (Dio) and local (Drift) sources
7. infrastructure/repository/ — Offline-first repository impl
8. application/usecases/    — One use case per action
9. presentation/providers/  — Riverpod providers
10. presentation/controllers/ — AsyncNotifier
11. presentation/pages/     — Page widgets
12. presentation/widgets/   — Module-local widgets
13. test/unit/              — Use case and repository tests
14. test/widget/            — Page widget tests
```

Run codegen after steps 1, 4, 7, 9:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Branch Strategy

- `main` — production-ready; protected; requires PR + CI green
- `develop` — integration branch for completed features
- `feat/<module>-<description>` — feature branches (branch off `develop`)
- `fix/<module>-<description>` — bug fix branches

## PR Checklist

- [ ] `flutter analyze` passes with zero warnings
- [ ] `dart format` applied
- [ ] Unit tests for all new use cases
- [ ] Widget test for new pages
- [ ] CLAUDE.md and AGENTS.md updated if architecture changes
- [ ] No `*.g.dart` or `*.freezed.dart` in broken state
