# SoloDesk Mobile — AI Agent Instructions

Canonical instructions for AI coding agents (Claude Code, Codex, GitHub Copilot, Gemini, Antigravity) working in this repository. `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md` are symlinks to this file. Read this before making any changes to the mobile app.

## Project

SoloDesk Mobile is a Flutter application that serves as the companion app for the SoloDesk CRM backend (`../backend/`). It targets Vietnamese freelancers managing clients, deals, proposals, contracts, and invoices on mobile.

**Key business flow:**
```
Client → Deal → Proposal → Contract → Invoice
              ↓
        Voice lead capture
              ↓
        Reminders → Analytics dashboard
```

## Architecture

**Feature-First Modular Clean Architecture.**

```
lib/
├── core/           # App infrastructure — never contains business logic
│   ├── app/        # SoloDeskApp widget, app bootstrap
│   ├── router/     # GoRouter setup, route names, guards
│   ├── theme/      # Material 3 theme, colors, typography
│   ├── config/     # App environment config (envied)
│   ├── network/    # Dio ApiClient + interceptors
│   ├── storage/    # Flutter Secure Storage wrapper
│   ├── database/   # Drift AppDatabase
│   ├── logging/    # Logger setup
│   └── security/   # Token manager
│
├── shared/         # Cross-module reusables
│   ├── api/        # Generated OpenAPI client + ApiResponse model
│   ├── widgets/    # Common UI components (loading shimmer, error retry)
│   ├── extensions/ # Dart extension methods
│   ├── utils/      # Formatters, validators
│   ├── models/     # ApiResponse<T>, Pagination
│   └── errors/     # AppException hierarchy
│
└── modules/        # Business features (9 modules)
    ├── auth/
    ├── clients/
    ├── deals/
    ├── proposals/
    ├── contracts/
    ├── invoices/
    ├── reminders/
    ├── analytics/
    └── settings/
```

Each module internal structure:

```
module/
├── presentation/
│   ├── pages/          # Full-screen widgets
│   ├── widgets/        # Module-local reusable widgets
│   ├── providers/      # Riverpod providers
│   └── controllers/    # AsyncNotifier / Notifier subclasses
├── application/
│   ├── usecases/       # Single-responsibility use cases
│   └── services/       # Orchestration services
├── domain/
│   ├── entities/       # Freezed data classes (pure Dart)
│   ├── value_objects/  # Typed wrappers (EmailAddress, Money, etc.)
│   ├── repositories/   # Abstract interfaces
│   └── exceptions/     # Module-specific domain exceptions
└── infrastructure/
    ├── datasource/     # Remote (Dio) and local (Drift) data sources
    ├── repository/     # Implements domain/repositories/ interfaces
    ├── dto/            # JSON-annotated request/response DTOs
    └── mapper/         # DTO ↔ Entity conversion
```

## State Management Rules

- **Riverpod only.** No Provider, Bloc, GetX, or MobX.
- Use `@riverpod` annotation + codegen for all providers.
- Page-level state lives in `AsyncNotifier` / `Notifier` subclasses under `presentation/controllers/`.
- Providers in `presentation/providers/` call use cases from `application/usecases/`.
- Never call a repository directly from a provider — always go through a use case.

## Networking Rules

- All HTTP requests go through `core/network/api_client.dart` (`ApiClient`).
- `ApiClient` is a Dio wrapper — modules never instantiate `Dio` themselves.
- Interceptor chain: `AuthInterceptor` (attach token) → `ErrorInterceptor` (map errors) → `PrettyDioLogger` (debug only).
- Remote data sources receive `ApiClient` via constructor injection.

## Navigation Rules

- **GoRouter only.** Route definitions live in `core/router/app_router.dart`.
- Route name constants live in `core/router/route_names.dart`.
- Auth redirect guard lives in `core/router/route_guards.dart`.
- Navigate with `context.go(RouteNames.home)` — never `Navigator.push`.

## Local Storage Rules

- Drift (`AppDatabase`) for structured offline data — deals, clients, proposals.
- `flutter_secure_storage` for tokens, API keys, and credentials.
- Never store sensitive values in SharedPreferences or Hive.
- Repository pattern: remote data source → local data source → repository decides which to use.

## Offline-First Rules

- Repository reads: try local cache first, then remote.
- Repository writes: write remote, then update local cache on success.
- Pending sync queue for writes made while offline (stored in Drift).
- Conflict resolution: server-side `updated_at` wins.

## Code Generation

0. **DO NOT HARDCODE:** Respect the root `GEMINI.md` principle. Use `@Envied` for configuration and always run codegen after `.env` changes.

After changing annotated files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Files that trigger codegen:
- `@freezed` — entity and DTO classes
- `@riverpod` — Riverpod providers and notifiers
- `@DriftDatabase` / `@DataClassName` — Drift tables and queries
- `@Envied` — environment config

Never edit `*.g.dart` or `*.freezed.dart` files by hand.

## Testing Rules

```
test/
├── unit/      # Use cases, repositories (in-memory Drift), pure logic
├── widget/    # Page and widget tests with Riverpod ProviderScope
└── integration/  # End-to-end flows (emulator required)
```

- Mock repositories with `mocktail` in use case unit tests.
- Use in-memory Drift database for repository unit tests (not mocks).
- Widget tests use `ProviderScope` with overridden providers.
- Test file naming: `test_<subject>.dart` mirrors `lib/<subject>.dart`.

## Commit Rules

**REQUIRED reading before any commit:** see [`.ai/commit-rules.md`](.ai/commit-rules.md) for the full
commit and branch convention. Key rule: never commit to `main` — branch as `<type>/<scope>` first.

## Common Commands

```bash
# Install / update deps
flutter pub get

# Codegen (always run after model changes)
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Format
dart format .

# Tests
flutter test

# Run (debug)
flutter run
```

## Backend API Contract

All API types are generated from `../backend/contracts/openapi.yaml`.
Base URL: `http://localhost:8000/api/v1`
Auth: `Authorization: Bearer <access_token>`

The backend standard response envelope:
```json
{
  "success": true,
  "code": 200,
  "timestamp": "ISO8601",
  "data": { ... }
}
```

Deserialize with `ApiResponse.fromJson(json, T.fromJson)`.

## Key Files

| File | Purpose |
|---|---|
| `lib/main.dart` | Entry point — `ProviderScope` + `SoloDeskApp` |
| `lib/core/app/app.dart` | `SoloDeskApp` widget |
| `lib/core/router/app_router.dart` | GoRouter provider |
| `lib/core/network/api_client.dart` | Dio wrapper |
| `lib/core/database/app_database.dart` | Drift `AppDatabase` |
| `lib/shared/models/api_response.dart` | Generic API envelope |
| `lib/shared/errors/app_exception.dart` | Exception hierarchy |
| `.env` | Runtime env (gitignored) |

---

# Additional Architecture Rules

*(Carried over from the prior AGENTS.md — non-negotiable boundary rules.)*

## Folder Rules

```
lib/
├── core/        # Infrastructure only — no business logic
├── shared/      # Reusable across modules — no module-specific code
└── modules/     # Business features — self-contained
```

- `core/` may import from `shared/` but never from `modules/`.
- `shared/` must not import from `modules/` or `core/`.
- `modules/<name>/` may import from `core/` and `shared/` but not from other modules.

## Module Internal Layer Rules

```
presentation/ → application/ → domain/
                             ↑
               infrastructure/ implements domain/repositories/
```

- `presentation/` may call `application/` use cases and watch providers.
- `application/` orchestrates domain and infrastructure via dependency injection.
- `domain/` is pure Dart — no Flutter, no Dio, no Drift imports.
- `infrastructure/` implements `domain/repositories/` interfaces.


## Error Handling

- Throw `AppException` subclasses (defined in `lib/shared/errors/`) from repositories and use cases.
- Never throw raw `DioException` from a repository — map it to `AppException` in the repository layer.
- Providers expose `AsyncValue<T>` — let Riverpod handle loading/error states.

## Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `deal_repository.dart` |
| Classes | `PascalCase` | `DealRepository` |
| Providers | `camelCaseProvider` | `dealListProvider` |
| Route names | `SCREAMING_SNAKE` constant | `RouteNames.dealDetail` |
| Freezed entities | `@freezed class` | `@freezed class Deal` |

