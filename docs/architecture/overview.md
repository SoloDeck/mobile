# Architecture Overview — SoloDesk Mobile

## Pattern

Feature-First Modular Architecture with Clean Architecture per module.

## Why

A folder-by-type structure (screens/, models/, repositories/) mixes all domains together — adding a Deal feature requires touching 4+ top-level folders. Feature-first means each module owns its full vertical slice: UI, business logic, and data access.

## Top-Level Structure

```
lib/
├── core/      Infrastructure shared by all modules (no business logic)
├── shared/    Cross-module reusable code (models, widgets, extensions)
└── modules/   9 business feature modules
```

## Module Structure

Each module is a self-contained Clean Architecture slice:

```
module/
├── presentation/     Flutter UI layer
│   ├── pages/        Full-screen widgets
│   ├── widgets/      Module-local reusable UI components
│   ├── providers/    Riverpod state providers
│   └── controllers/  AsyncNotifier / Notifier subclasses
├── application/      Business orchestration
│   ├── usecases/     Single-responsibility use cases
│   └── services/     Coordination services
├── domain/           Pure Dart business model
│   ├── entities/     Freezed immutable data classes
│   ├── value_objects/ Typed domain primitives
│   ├── repositories/ Abstract interfaces (no implementations)
│   └── exceptions/   Module-specific exceptions
└── infrastructure/   I/O implementations
    ├── datasource/   Remote (Dio) and local (Drift) sources
    ├── repository/   Implements domain/repositories/
    ├── dto/          JSON-annotated request/response DTOs
    └── mapper/       DTO ↔ Entity converters
```

## Dependency Rule

Dependencies always point inward:

```
presentation → application → domain ← infrastructure
```

- `domain/` has no dependencies on Flutter, Dio, or Drift.
- `infrastructure/` depends on `domain/` (implements its interfaces).
- `presentation/` depends on `application/` (calls use cases).
- Cross-module communication: via `shared/` types only — never direct module imports.

## Data Flow

```
Widget watches Provider
       ↓
Provider calls UseCase
       ↓
UseCase calls Repository interface
       ↓
RepositoryImpl calls RemoteDatasource (Dio) and/or LocalDatasource (Drift)
       ↓
Result flows back as AsyncValue<T>
```

## Offline-First

```
Repository.get():
  1. Return local cache immediately (optimistic)
  2. Fetch remote in background
  3. Update cache, notify provider

Repository.create/update():
  1. Write to remote
  2. On success, update local cache
  3. On failure, queue for sync (pending_sync table)
```
