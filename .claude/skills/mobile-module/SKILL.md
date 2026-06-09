---
name: mobile-module
description: Implement a Flutter feature/module for SoloDesk mobile using clean architecture (presentation/application/domain/infrastructure) with riverpod 3, freezed 3, drift, dio, go_router. Use when building/changing a module under mobile/lib/modules (clients, deals, invoices, proposals, contracts, reminders, analytics, settings), writing DTOs/mappers/providers/usecases, or hitting iOS build/codegen errors. The auth module is the template.
---

# Mobile Module — SoloDesk Flutter

Stack: Flutter (sdk ^3.8), riverpod 3, freezed 3, drift, dio, go_router, google_sign_in, envied. The `auth` module is complete — use it as the template for clients/deals/invoices/proposals/contracts/reminders/analytics/settings.

## Module structure (mirrors auth)
```
lib/modules/{module}/
├── presentation/   pages/ · providers/ · controllers/
├── application/    usecases/
├── domain/         entities/ · repositories/   (interfaces)
└── infrastructure/ dto/ · datasource/ · repository/ (impl) · mapper/
```
- DTO (freezed + json) matches the API contract → `mapper/` converts DTO to a domain entity.
- Providers/controllers use riverpod codegen (`@riverpod`, `.g.dart` files).

## Working principles
- Read `mobile/CLAUDE.md`, `mobile/AGENTS.md`, `mobile/COMMIT_RULES.md` before coding.
- DTOs follow the **shape-mapping table** from contract-keeper (snake_case API → Dart field mapped in the mapper). To change a shape → ask contract-keeper, don't change it yourself.
- After editing annotated code, RUN: `dart run build_runner build --delete-conflicting-outputs` (if a previous run is stuck: `dart run build_runner clean` first).

## freezed 3.x / riverpod 3.x gotchas (seen in practice)
Old 2.x code only breaks once a model/provider becomes reachable in the compile graph from `main.dart`. Mechanical fixes:
- "missing implementations of `_$X`" → every `@freezed`/`@Freezed` class must be declared `abstract class X with _$X`.
- Generic freezed + JSON (`ApiResponse<T>`, `PaginatedData<T>`) needs `@Freezed(genericArgumentFactories: true)`.
- `AsyncValue.valueOrNull` was removed in riverpod 3 → use `.value` (returns `T?`).
- Missing `*.g.dart`/`*.freezed.dart` → run build_runner as above.
- `envied` (`@Envied`) reads `mobile/.env` (gitignored) at codegen time, NOT a Flutter asset. Copy from `mobile/.env.example`. Missing vars → fails to generate `app_config.g.dart`.

## Live / cleaned-up architecture
- Real code lives under `lib/modules/`, `lib/core/`, `lib/shared/`. The legacy trees `lib/presentation|data|domain/` were deleted — don't recreate them.

## Verifying builds (don't use flutter run on device)
- iOS is now pure SPM (CocoaPods deintegrated). `flutter run` on a physical iPhone times out at "CONFIGURATION_BUILD_DIR".
- Verify compilation with: `flutter build ios --debug --no-codesign`. To run on a real device, the user runs `flutter run` from their own terminal (granting Automation permission), not via the sandbox.
- Always `flutter analyze` and report the real errors.

## Boundaries
Edit only files in the `mobile/` submodule. Commit per `COMMIT_RULES.md`; remember to update the submodule pointer in the root repo.
