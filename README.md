# SoloDesk Mobile

Flutter mobile application for the SoloDesk AI-powered CRM platform — built for Vietnamese freelancers.

## Overview

SoloDesk Mobile is the companion app that lets freelancers update client status on the go, receive real-time push notifications, and capture leads by voice.

## Architecture

**Feature-First Modular Architecture** (Clean Architecture per module).

```
lib/
├── core/           # App-wide infrastructure (network, storage, routing, theme)
├── shared/         # Reusable widgets, extensions, models, and error types
└── modules/        # Self-contained business feature modules
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

Each module follows a 4-layer structure:

```
module/
├── presentation/   # UI — pages, widgets, providers, controllers
├── application/    # Use cases and services (business orchestration)
├── domain/         # Entities, value objects, repository interfaces, exceptions
└── infrastructure/ # DTOs, mappers, repository implementations, data sources
```

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` + `riverpod_annotation` |
| Navigation | `go_router` |
| Networking | `dio` |
| Local database | `drift` (SQLite) |
| Secure storage | `flutter_secure_storage` |
| Serialization | `freezed` + `json_serializable` |
| API models | Generated from `contracts/openapi.yaml` |

## Quick Start

```bash
# Install dependencies
flutter pub get

# Generate code (Freezed / Riverpod / Drift)
dart run build_runner build --delete-conflicting-outputs

# Copy and fill env file
cp .env.example assets/env/.env

# Run
flutter run
```

## API Contract

All API models are generated from `../backend/contracts/openapi.yaml`. Never hand-write DTOs.

## Testing

```bash
# All tests
flutter test

# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/
```

## CI

GitHub Actions workflow at `.github/workflows/flutter-ci.yml` runs:
- `flutter analyze`
- `dart format --output=none --set-exit-if-changed .`
- `flutter test test/unit/ test/widget/`

## Backend API

Base URL: `http://localhost:8000/api/v1` (development)

See `../backend/contracts/openapi.yaml` for the full OpenAPI 3.1.0 specification.

## Related

- [Backend](../backend/README.md) — FastAPI Python API
- [Web](../web/) — React web frontend
- [OpenAPI Spec](../backend/contracts/openapi.yaml)
