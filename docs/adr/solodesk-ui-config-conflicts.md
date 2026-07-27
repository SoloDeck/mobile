# Mâu thuẫn giữa bộ config SoloDesk UI và kiến trúc hiện tại

**Trạng thái:** đã chốt **hướng B** — tầng UI mới dựng song song với `lib/modules/`
**Ngày:** 2026-07-26

## Quyết định

Người dùng chỉ định dựng widget vào `lib/ui/`, tức chọn hướng B ở cuối tài liệu này.
`lib/theme/` và `lib/ui/` đã tồn tại và có test; `lib/core/`, `lib/shared/`, `lib/modules/`
không bị đụng tới. Mục 1–6 trong bảng dưới vì thế **không còn là mâu thuẫn chờ xử lý** mà là
mô tả đúng hiện trạng — hai tầng cố ý tách nhau. Việc hợp nhất, nếu có, để một quyết định sau.

### Ngoại lệ SlipCard — cố ý không chép theo bản phác thảo

Bản phác thảo dùng `.slip` ở **MÀN 01** (“Lần đăng nhập gần nhất”) và **MÀN 10** (“File đang
chọn”), cả hai đều không phải nội dung tiền. Đã chốt **giữ nguyên quy tắc 3**: `SlipCard` chỉ
dùng cho tiền, hai màn đó dựng bằng `Card`.

Ghi lại ở đây vì agent dựng màn đọc thẳng HTML — nếu không có dòng này thì việc “sửa lại cho
giống bản phác thảo” trông sẽ giống một bản vá đúng đắn. Doc comment của `SlipCard` cũng nhắc
lại điều này.

### Token bổ sung vào bản phác thảo

Bản phác thảo dùng 10 màu nằm ngoài `:root` mà widget dùng chung cần: viền bốn loại chip, hai
màu chữ đậm trên nền `*-soft`, bốn điểm cuối gradient avatar. Đã thêm chúng vào `:root` và trỏ
các quy tắc CSS tương ứng sang `var(--…)` — bản HTML render y hệt trước, còn `sync_tokens.py`
giờ sinh ra 30 màu thay vì 20. Đây là quy trình mà quy tắc 1 mô tả: sửa nguồn thiết kế rồi sinh
lại, không viết cứng vào Dart.

## Bối cảnh

Bộ config tầng giao diện (`.claude/rules/flutter-ui.md`, `.claude/skills/solodesk-screen/`,
`.claude/agents/screen-builder.md`, `.claude/hooks/verify_dart.sh`, `.claude/settings.json`,
và mục "SoloDesk UI — Design Source of Truth" trong `AGENTS.md`) được viết cho một cây thư mục
`lib/theme` + `lib/ui` + `lib/features`. Repo hiện tại dùng `lib/core` + `lib/shared` + `lib/modules`
theo clean architecture.

Bộ config được đặt vào đúng vị trí **nguyên văn, không sửa đường dẫn** — đây là quyết định có chủ ý
để không sinh ra một bản dịch sai lệch trước khi chốt hướng. Tài liệu này ghi lại từng chỗ lệch và
hệ quả cụ thể của nó.

## Các chỗ lệch

| # | Docs mới nói | Repo hiện có | Hệ quả cụ thể |
|---|---|---|---|
| 1 | `lib/theme/app_colors.dart`, tự sinh từ HTML | `lib/core/theme/app_colors.dart`, viết tay 73 dòng | Chạy `sync_tokens.py` sẽ tạo bảng màu **thứ hai**. Toàn bộ `lib/modules/` đang import file viết tay. |
| 2 | `lib/ui/` cho widget dùng chung | `lib/shared/widgets/` (5 widget) | Bảng tra trong `SKILL.md` (`SlipCard`, `StatusChip`, `Money`, `SoloNavBar`) trỏ vào thư mục không tồn tại. |
| 3 | `lib/features/<màn>/`, một thư mục mỗi màn hình | `lib/modules/<module>/presentation/pages/` | `screen-builder` được dặn "chỉ tạo file trong `lib/features/`" nên sẽ dựng cây thư mục mới thay vì vào module có sẵn. |
| 4 | Hook chặn `Color(0x` khi path chứa `/lib/features/` | Code thật nằm ở `lib/modules/` | **Hook không bảo vệ được dòng code nào đang có.** Xem `verify_dart.sh` dòng 13. |
| 5 | `settings.json` deny `Edit(lib/theme/app_colors.dart)` | File cần khoá là `lib/core/theme/app_colors.dart` | Rào chắn đang canh một đường dẫn chưa tồn tại. |
| 6 | `test/golden/` với golden test mỗi màn | `test/widget/`, `test/unit/`, chưa có golden nào | Cần dựng hạ tầng golden test từ đầu. |
| 7 | Skill `solodesk-screen` — dựng theo *màn hình* | Skill `mobile-module` — dựng theo *module* clean architecture | Hai skill dạy hai cách khác nhau cho cùng một loại việc; Claude sẽ chọn theo cách người dùng hỏi. |
| 8 | Cấm `google_fonts`, font bundle trong `assets/fonts/` | `pubspec.yaml:42` có `google_fonts: ^8.1.0`; `assets/` mới chỉ có `env/` | **Quy tắc 6 đang bị vi phạm ngay từ dependency.** Gỡ package và bundle font, hoặc bỏ quy tắc 6. |

## ~~Chặn riêng: Flutter SDK trên máy này quá cũ~~ — đã gỡ

`flutter upgrade` đưa máy lên **Flutter 3.44.8 / Dart 3.12.2**. `flutter pub get` chạy được,
`pubspec.yaml` không phải sửa dòng nào. Ngoài ra phải tạo `.env` từ `.env.example` để
`envied_generator` chạy được, rồi `dart run build_runner build` — thiếu bước này thì `flutter
analyze` báo hơn 1100 lỗi do code sinh chưa có.

Baseline sau khi gỡ chặn: **13 issue mức `info`, 0 error, 103 test pass**. Mọi việc sau đó phải
giữ đúng con số này.

<details>
<summary>Nội dung cũ, giữ lại để tra cứu</summary>

### Chặn riêng: Flutter SDK trên máy này quá cũ để `flutter pub get` chạy được

Không liên quan bộ config UI, nhưng chặn luôn hook `verify_dart.sh` (dòng 22 gọi `flutter analyze`).

- Máy đang chạy **Flutter 3.41.9 / Dart 3.11.5** (stable, 2026-04-29). `flutter_test` của SDK này
  ghim `meta 1.17.0`.
- `pubspec.lock` (đang commit, không bị sửa) khoá `meta 1.18.0` + `analyzer 12.1.0` — nghĩa là
  repo đã resolve thành công trên một **SDK mới hơn**.
- `analyzer >=10.0.2 <13.1.0` cần `meta ^1.18.0`, nên toàn bộ tầng codegen
  (`freezed`, `riverpod_generator`, `json_serializable`, `dart_style`) không resolve được tại chỗ.

`pubspec.yaml` **không sai** — đã thử hạ `freezed` và `riverpod_generator` xuống bản stable, xung
đột chỉ dịch sang `json_serializable`/`dart_style`. Cách sửa đúng là `flutter upgrade` trên máy
local, không phải sửa dependency.

</details>

## Hai hướng xử lý

**A. Sửa docs cho khớp repo.** Đổi đường dẫn trong 5 file config sang `lib/core/theme`,
`lib/shared/widgets`, `lib/modules/*/presentation/pages`, `test/widget`. Giữ nguyên 7 quy tắc và
quy trình đọc bản phác thảo. Ưu: không sinh kiến trúc thứ hai, hook bảo vệ được code thật ngay.
Nhược: bảng tra trong `SKILL.md` phải viết lại, và mô hình "một thư mục mỗi màn" không ánh xạ
1–1 sang "một module nhiều màn".

**B. Dựng tầng UI mới song song.** Để `lib/theme` + `lib/ui` + `lib/features` mọc riêng cho 15 màn
phác thảo, `lib/modules` giữ nguyên phần nghiệp vụ. Ưu: bộ config chạy được nguyên trạng, 15 màn
dựng nhanh. Nhược: hai bảng màu, hai nơi chứa widget dùng chung, và cuối cùng vẫn phải hợp nhất.

Chưa chọn hướng nào thì **không chạy Bước 2–3 của `docs/process/solodesk-ui-runbook.md`** — đó là
lúc 15 agent bắt đầu ghi file theo cây thư mục trong docs.

## Việc cần làm trước tiên

1. Đặt `design/solodesk-mobile-ui.html` vào `design/` — thiếu file này thì cả hai hướng đều đứng.
2. Chọn A hoặc B.
3. Nếu chọn A: sửa mục 1–6 trong bảng trên rồi cập nhật tài liệu này thành *đã đóng*.
