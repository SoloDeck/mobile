---
name: solodesk-screen
description: Dựng một màn hình Flutter của SoloDesk từ bản phác thảo HTML trong design/. Dùng skill này bất cứ khi nào cần implement, sửa hoặc đối chiếu một màn hình mobile của SoloDesk — kể cả khi yêu cầu chỉ nêu tên màn ("làm màn doanh thu", "dựng màn duyệt báo giá") hoặc số màn ("màn 07").
---

# Dựng một màn hình SoloDesk

## Quy trình

### 1. Đọc bản phác thảo trước

Tìm màn hình trong `design/solodesk-mobile-ui.html` bằng số màn:

```bash
grep -n 'MÀN 07' design/solodesk-mobile-ui.html
```

Đọc cả khối `<figure class="unit">` — gồm markup của màn hình **và** phần
`<figcaption>` bên dưới. Figcaption chứa lý do thiết kế; nó giải thích *tại sao* màn
hình được bố trí như vậy và thường nêu rõ điều gì cố ý KHÔNG có. Bỏ qua phần này là
nguồn sai sót phổ biến nhất.

### 2. Kiểm kê trước khi viết

Liệt kê ra: màn này cần widget nào đã có trong `lib/ui/`, cần widget mới nào, và
chuỗi hiển thị nào cần lấy nguyên văn từ bản phác thảo.

Nếu cần widget mới mà nó xuất hiện ở từ hai màn trở lên → đặt vào `lib/ui/`.
Chỉ dùng ở một màn → để private trong file màn đó, tiền tố `_`.

### 3. Bảng tra thành phần

| Trong HTML | Trong Flutter |
|---|---|
| `.slip` | `SlipCard(top:, bottom:)` — **chỉ cho nội dung tiền** |
| `.stamp.due` / `.paid` / `.draft` | `StampBadge.due()` / `.paid()` / `.draft()` |
| `.chip.money` / `.ai` / `.ok` / `.warn` | `StatusChip('…', tone: Tone.money)` |
| `.chip` (đang chọn, nền đậm) | `StatusChip('…', tone: Tone.solid)` |
| `.lbl` | `SectionLabel('…')` |
| `.num` | `Money(…)`, `Money.hero(…)`, `Money.inline(…)` |
| `.card` | `Card` — đã cấu hình trong `AppTheme`, đừng bọc thêm `Container` |
| `.btn` / `.btn.out` | `FilledButton` / `OutlinedButton` |
| `.tabbar` + `.fab` | `SoloNavBar(index:, onSelect:, onQuickCapture:)` |
| `.av` | `_Avatar` (private mỗi màn, hoặc nâng lên `lib/ui/` nếu đã dùng ≥ 2 màn) |
| `.bar` | `LinearProgressIndicator` bọc `ClipRRect(borderRadius: 99)` |

Giá trị số: bo góc lấy từ `AppRadius`, lề và khoảng cách lấy từ `AppGap`, cỡ chữ lấy
từ `AppText`. Nếu bản phác thảo có một con số không nằm trong ba lớp này, đó là dấu
hiệu token còn thiếu — thêm vào token, đừng viết cứng vào màn hình.

### 4. Dữ liệu

Dùng dữ liệu giả đúng như trong bản phác thảo (Minh An, Việt Phát, Studio Cỏ, các số
tiền cụ thể). Đặt trong một hằng số `_demo` ở cuối file, không rải rác giữa widget
tree. Khi ghép API thật chỉ cần thay đúng chỗ đó.

### 5. Golden test

Mỗi màn hình phải có một golden test trong `test/golden/`:

```dart
testWidgets('màn 07 — kết quả chấm điểm lead', (tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    home: const LeadScoreScreen(),
  ));
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(LeadScoreScreen),
    matchesGoldenFile('goldens/screen_07_lead_score.png'),
  );
});
```

Chạy `flutter test --update-goldens` một lần để tạo ảnh, rồi **mở ảnh ra xem** và so
với bản phác thảo trước khi commit. Ảnh vàng chỉ có giá trị nếu lần đầu tiên nó đúng.

### 6. Tự kiểm trước khi báo xong

```bash
flutter analyze
flutter test
rg 'Color\(0x' lib/features/            # phải không có kết quả
rg "fontFamily: '" lib/features/        # phải không có kết quả
```

Báo cáo kết thúc bằng: màn số mấy, widget mới nào đã thêm vào `lib/ui/`, và điểm nào
trong bản phác thảo phải diễn giải lại vì Flutter không làm được y hệt CSS.

## Sai sót hay gặp

- **Bỏ qua figcaption** rồi dựng đúng hình nhưng sai hành vi (ví dụ thêm kéo thả vào
  Kanban, trong khi chú thích ghi rõ là cố ý bỏ).
- **Dùng `SlipCard` cho thẻ thường** vì thấy nó đẹp hơn `Card`.
- **Bịa chuỗi hiển thị** thay vì chép nguyên văn tiếng Việt từ bản phác thảo.
- **Đặt nút hành động chính ở đầu màn hình.** Bản phác thảo luôn đặt ở 1/3 dưới để
  ngón cái với tới. Trên màn có nội dung cuộn, nút nằm trong dải nổi ở đáy với
  gradient chuyển sang màu nền.
- **Bỏ trạng thái rỗng và trạng thái mất mạng.** Màn nào trong bản phác thảo có mô tả
  trạng thái rỗng thì phải dựng luôn, không để làm sau.
