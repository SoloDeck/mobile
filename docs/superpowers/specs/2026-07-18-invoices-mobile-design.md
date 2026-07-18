# Invoices — Mobile Module (Hóa đơn) — Design Spec

**Date:** 2026-07-18
**Branch:** `feat/invoices-mobile` (off `origin/main`)
**Layer:** mobile only (backend contract already complete)
**Pattern:** mirror the existing `deals` module exactly (clean architecture, freezed 3, riverpod 3, drift, dio, go_router).

## 1. Goal & scope

Build the mobile Invoices module against the already-complete backend contract, covering the freelancer money-loop:

**list → detail → create draft → edit draft → send → record payment → void**, with an offline drift cache for the list.

### In scope (endpoints)
- `GET /invoices` — list (filters: `status`, `invoice_number`, date ranges, `overdue_only`, `sort_by`, `sort_order`, `page`, `page_size`)
- `POST /invoices` — create draft
- `GET /invoices/{id}` — detail (with line items)
- `PATCH /invoices/{id}` — update draft only (line_items replace, not merge)
- `POST /invoices/{id}/send` — draft → sent
- `POST /invoices/{id}/void` — not allowed on paid/partially_paid
- `GET /invoices/{id}/payments` — list payment records
- `POST /invoices/{id}/payments` — record payment (amount ≤ outstanding)

### Out of scope (later)
- `POST /invoices/{id}/payment-link` (MoMo deep-link / bank QR / PaymentIntent) — deferred.
- proposals / contracts / reminders modules — separate future specs.

## 2. Contract → freezed DTO field maps (exact parity — verify against `backend/contracts/openapi.yaml`)

Base URL `…/api/v1`. All responses use the envelope `{success, code, timestamp, data}` → unwrap with the shared `ApiResponse.fromJson`. Money decimals arrive as JSON numbers → parse to `double`.

- **`InvoiceResponseDto`** ← `InvoiceResponse`: `id, ownerUserId, clientId, clientName?, contractId?, dealId?, invoiceNumber, status(InvoiceStatus), issueDate(date), dueDate(date), currency, subtotal, taxRate, taxAmount, total, amountPaid, amountOutstanding, notes?, lineItems[LineItemDto], sentAt?(dt), voidedAt?(dt), createdAt(dt), updatedAt(dt)`
- **`LineItemDto`** ← `LineItemDTO`: `description, quantity, unitPrice, amount, sortOrder`
- **`CreateInvoiceRequestDto`** → `CreateInvoiceRequest`: `clientId, contractId?, dealId?, issueDate?, dueDate, currency(=VND), subtotal?, taxRate(=0), notes?, lineItems[{description, quantity, unitPrice, sortOrder?}]` — **client rule: must include `contractId` OR `dealId`**; and (`lineItems` min 1) OR `subtotal` supplied.
- **`UpdateInvoiceRequestDto`** → `UpdateInvoiceRequest`: `subtotal?, dueDate?, taxRate?, notes?, lineItems?`
- **`PaymentRecordDto`** ← `PaymentRecordResponse`: `id, invoiceId, amount, paymentDate(date), paymentMethod(PaymentMethod), referenceNote?, createdAt(dt)`
- **`RecordPaymentRequestDto`** → `RecordPaymentRequest`: `amount, paymentDate, paymentMethod?, referenceNote?`

### Enums (value objects)
- `InvoiceStatus`: `draft | sent | partiallyPaid | paid | overdue | void` (json: `draft, sent, partially_paid, paid, overdue, void`)
- `PaymentMethod`: `bankTransfer | cash | online | other` (json: `bank_transfer, cash, online, other`)

## 3. Module file layout (`mobile/lib/modules/invoices/` — replace the empty stub)

```
domain/
  entities/invoice.dart              # freezed: Invoice, LineItem, PaymentRecord
  value_objects/invoice_status.dart  # enum + json map + label(vi) + color/icon helper
  value_objects/payment_method.dart  # enum + json map + label(vi)
  repositories/invoices_repository.dart
application/usecases/
  list_invoices_usecase.dart · get_invoice_usecase.dart
  create_invoice_usecase.dart · update_invoice_usecase.dart
  send_invoice_usecase.dart · void_invoice_usecase.dart
  record_payment_usecase.dart · list_payments_usecase.dart
infrastructure/
  dto/ invoice_response_dto · line_item_dto · create_invoice_request_dto
       · update_invoice_request_dto · payment_record_dto · record_payment_request_dto
  mapper/ invoice_mapper.dart · invoice_row_mapper.dart
  datasource/ invoices_remote_datasource.dart · invoices_local_datasource.dart
  repository/ invoices_repository_impl.dart
presentation/
  controllers/ invoices_list_controller.dart · invoice_detail_controller.dart
  providers/   invoices_provider.dart
  pages/       invoices_page.dart · invoice_detail_page.dart · invoice_form_page.dart
  widgets/     invoice_card · invoice_status_badge · line_item_editor
               · payment_record_tile · record_payment_sheet · invoice_amount_summary
```

## 4. Data flow, cache & networking (per mobile CLAUDE.md offline-first rules)

- Remote datasource takes `ApiClient` (dio wrapper) via constructor; never instantiate Dio.
- **Reads:** repository serves cached rows first (drift), then fetches remote, upserts `InvoiceRows`, re-emits.
- **Writes** (create/update/send/void/record-payment): remote-first; on success refetch/upsert the affected invoice into cache. No optimistic UI for money.
- Add `InvoiceRows` drift table to `core/database/app_database.dart` (register in `@DriftDatabase(tables: [...])`, bump `schemaVersion`, add migration step). Row = flat invoice summary fields for the list (id, invoiceNumber, clientName, status, dueDate, total, amountOutstanding, updatedAt). Line items/payments are fetched on detail (not cached in v1).
- Conflict resolution: server `updated_at` wins.

## 5. Screens & UX

Match the existing app design system (Be Vietnam Pro + Noto Sans, 8dp grid, primary `#2563EB`, press feedback, ≥44pt touch targets, safe-area). Reuse `lib/shared/utils/currency_formatter.dart` for VND. Apply `ui-ux-pro-max` mobile rules: status conveyed by icon+color (not color alone), VND shown with tabular figures, overdue emphasized (danger), skeleton loaders >300ms, empty states, one primary CTA per screen, destructive actions separated + confirm dialog, inline field errors, `aria`/semantics labels on icon-only buttons.

- **InvoicesPage** — new 5th bottom-nav tab **"Hóa đơn"** (`Icons.receipt_long`). List of `InvoiceCard` (number, client name, VND total tabular, due date, `InvoiceStatusBadge`). Filter chips: Tất cả / Quá hạn / Nháp / Đã gửi / Đã thanh toán. Pull-to-refresh, infinite scroll, skeleton, empty state ("Chưa có hóa đơn"). FAB "Tạo hóa đơn".
- **InvoiceDetailPage** — `InvoiceAmountSummary` (total / đã trả / **còn lại**), line-item table, payment history, meta (client, issue/due dates, notes). Status-driven actions: draft → Sửa / Gửi / Xoá; sent|partially_paid → Ghi nhận thanh toán / Huỷ; paid|void → read-only.
- **InvoiceFormPage** (create/edit draft) — client picker (prefilled when opened from a deal), deal/contract link, issue/due date pickers, `LineItemEditor` (rows: description, qty, unit price → live amount), tax rate, notes; live subtotal/tax/total preview; inline validation (deal/contract required; ≥1 line item or subtotal).
- **RecordPaymentSheet** (bottom sheet) — amount (default = outstanding), payment date, method, note; blocks amount > outstanding inline (mirrors backend 400).
- **Deal-detail entry point** — add an "Hóa đơn" section to `deals/presentation/pages/deal_detail_page.dart` listing that deal's invoices + "Tạo hóa đơn" prefilled with `dealId`.

### Navigation wiring
- `core/router/route_names.dart` already declares `invoices = '/invoices'` and `invoiceDetail = '/invoices/:id'`.
- Add a 5th `StatefulShellBranch` in `core/router/app_router.dart` (`/invoices` → `InvoicesPage`, nested `:id` → `InvoiceDetailPage`; `new` → `InvoiceFormPage`), **in index order**.
- Add the matching 5th nav item in `core/app/app_shell.dart` (index-aligned with the branch).

## 6. Error handling
- `409` (edit/void on non-draft / already-paid) → friendly vi message + refresh detail.
- `400` overpayment → inline sheet error.
- Offline → cached list read-only; mutations show "Cần kết nối mạng".
- All via the existing `ErrorInterceptor` → `AppException` mapping.

## 7. Testing (flutter test — required; naming `test_<subject>.dart`)
- DTO `fromJson`/`toJson` round-trips (null contract/deal, computed `amountOutstanding`, enums).
- Mapper DTO→entity + row mapper.
- Remote datasource path/body assertions (mock `ApiClient`/dio with `mocktail`).
- Repository cache-then-network (in-memory Drift).
- Controllers: list filter/overdue/pagination + mutation refresh; detail load + actions.
- Widget tests: `InvoiceStatusBadge`, `LineItemEditor` totals, `RecordPaymentSheet` overpayment guard.
- `flutter analyze` → 0 issues; `dart format .`.

## 8. Build order (task checklist)
1. Domain entities + value objects (+ unit tests for enum json/label).
2. DTOs (+ codegen) + fromJson/toJson tests.
3. Mappers (+ tests).
4. Drift `InvoiceRows` + registration + migration; `invoices_local_datasource`.
5. `invoices_remote_datasource` (+ tests).
6. `invoices_repository_impl` + DI providers (+ repo tests).
7. Usecases (+ tests).
8. Controllers (list + detail).
9. Widgets + pages.
10. Nav wiring (app_router branch + app_shell item) + deal-detail entry.
11. `build_runner`, `flutter analyze`, `flutter test`, `dart format`.

## 9. Definition of Done
- All in-scope endpoints wired end-to-end and reachable from UI.
- 5th "Hóa đơn" tab + deal-detail invoices section working.
- Offline list cache functioning.
- `flutter analyze` 0 issues, `flutter test` green, formatted.
- Commit(s) on `feat/invoices-mobile` following `.ai/commit-rules.md`; open PR. (Root submodule-pointer bump happens later, after merge.)
