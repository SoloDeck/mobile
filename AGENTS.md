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

---

# SoloDesk UI — Design Source of Truth

*(Bộ quy tắc tầng giao diện. Xem `docs/adr/solodesk-ui-config-conflicts.md` — phần cấu trúc
thư mục dưới đây hiện chưa khớp với "Architecture" ở trên, mâu thuẫn đang chờ quyết.)*

App đồng hành cho freelancer Việt Nam. CRM + hợp đồng + nhắc thu tiền.

## Nguồn sự thật về thiết kế

`design/solodesk-mobile-ui.html` chứa toàn bộ 15 màn hình đã được duyệt, mỗi màn có
chú thích lý do thiết kế bên dưới. **Luôn đọc màn hình tương ứng trong file này trước
khi viết bất kỳ widget nào.** Đừng suy diễn giao diện từ tên màn hình.

Số màn hình được đánh dấu bằng `<span class="no">MÀN 07</span>` trong file HTML.

## Lệnh

```bash
flutter analyze                    # phải sạch trước khi báo xong
flutter test                       # gồm cả golden test
flutter test --update-goldens      # chỉ chạy khi thiết kế đổi CÓ CHỦ Ý
dart format lib test
python3 tools/sync_tokens.py design/solodesk-mobile-ui.html lib/theme/app_colors.dart
```

## Quy tắc không được vi phạm

Bảy điều dưới đây là quyết định thiết kế đã chốt, không phải gợi ý. Nếu một yêu cầu
buộc phải phá một trong số này, **dừng lại và hỏi** thay vì tự quyết.

1. **Không hardcode màu.** Mọi `Color` phải đến từ `AppColors`. Không có
   `Color(0xFF...)` nào trong `lib/features/**`. `app_colors.dart` là file tự sinh —
   sửa `design/solodesk-mobile-ui.html` rồi chạy lại `tools/sync_tokens.py`.

2. **Màu mang ngữ nghĩa.** Hồng (`momo`) chỉ dùng cho tiền. Tím (`ai`) chỉ dùng cho
   nội dung do AI sinh và đang chờ duyệt. Ngọc (`jade`) = đã thu/đã xong. Hổ phách
   (`amber`) = sắp đến hạn. Dùng `Tone.money` / `Tone.ai` thay vì gọi màu trực tiếp.

3. **`SlipCard` chỉ dùng cho tiền.** Thẻ thường dùng `Card`. Tấm phiếu răng cưa xuất
   hiện ở chỗ không liên quan tiền là làm hỏng quy ước thị giác của cả app.

4. **Kanban không kéo thả trên mobile.** Sáu giai đoạn hiển thị bằng chip lọc cuộn
   ngang + danh sách dọc. Đổi giai đoạn bằng menu chọn. Đừng thêm `Draggable`,
   `ReorderableListView` hay thư viện kéo thả nào.

5. **AI không bao giờ tự gửi ra ngoài.** Mọi nội dung máy sinh phải qua màn xem trước
   với nút "Duyệt và gửi". Không có đường tắt nào từ kết quả AI thẳng tới API gửi tin.

6. **Không dùng package `google_fonts`.** Font bundle trong `assets/fonts/`. App phải
   chạy ngoại tuyến ngay lần mở đầu tiên.

7. **Ngoại tuyến không chặn thao tác.** Ghi lead, tick task, sửa nội dung vẫn chạy khi
   mất mạng và xếp vào hàng chờ. Chỉ hành động gửi ra ngoài mới bị chặn.

## Cấu trúc

```
design/          bản phác thảo HTML — nguồn sự thật
tools/           script sinh token
lib/theme/       token: màu, chữ, ThemeData
lib/ui/          widget dùng chung (SlipCard, StatusChip, Money, SoloNavBar…)
lib/features/    một thư mục cho mỗi màn hình
test/golden/     ảnh vàng của widget và màn hình
```

## Trước khi báo xong một màn hình

- `flutter analyze` sạch, không cảnh báo mới.
- Golden test của màn đó đã chạy qua.
- Không có `Color(0xFF...)`, `TextStyle(fontFamily: '...')` hay số bo góc viết cứng
  trong file vừa tạo. Bo góc lấy từ `AppRadius`, khoảng cách từ `AppGap`.
- Viết một dòng nêu rõ **màn nào trong file HTML** đã được đối chiếu.

## Ngôn ngữ

Chuỗi hiển thị viết bằng tiếng Việt, giọng văn theo đúng bản phác thảo: động từ chủ
động, câu ngắn, không dùng thuật ngữ kỹ thuật với người dùng cuối ("Nhắc thanh toán"
chứ không phải "Trigger reminder"). Comment trong code viết tiếng Việt.

