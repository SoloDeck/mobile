# Chạy Claude Code trên SoloDesk

Chép nguyên các prompt bên dưới. Thứ tự quan trọng: mỗi bước tạo ra thứ mà bước sau
dùng để tự kiểm chứng.

---

## Bước 0 — Đặt file vào đúng chỗ

```
your_flutter_app/
├── CLAUDE.md
├── .claude/
│   ├── settings.json
│   ├── rules/flutter-ui.md
│   ├── skills/solodesk-screen/SKILL.md
│   ├── agents/screen-builder.md
│   └── hooks/verify_dart.sh          (chmod +x)
├── design/solodesk-mobile-ui.html
├── tools/sync_tokens.py
└── lib/{theme,ui,features}/
```

Cần `jq` cho hook. Kiểm tra hook đã nạp bằng `/hooks` trong phiên Claude Code.

---

## Bước 1 — Bắt Claude Code khảo sát trước, đừng cho viết code ngay

Vào plan mode (`Shift+Tab` hai lần), rồi:

```
Đọc CLAUDE.md và design/solodesk-mobile-ui.html.

Lập bảng kiểm kê: 15 màn hình, mỗi màn cần widget nào trong lib/ui/, widget nào
chưa có. Nhóm các widget còn thiếu theo số màn hình sử dụng chúng.

Chưa viết code. Chỉ đưa bảng kiểm kê và thứ tự dựng mà bạn đề xuất.
```

Bước này rẻ và quyết định chất lượng của tất cả các bước sau. Nếu bảng kiểm kê sai,
dừng lại sửa ở đây thay vì để 15 agent cùng dựng sai.

---

## Bước 2 — Dựng widget dùng chung trước, tuần tự

Widget dùng chung là nút thắt: mọi màn hình đều phụ thuộc vào nó, nên đừng làm song
song.

```
Dựng các widget còn thiếu trong lib/ui/ theo bảng kiểm kê, theo thứ tự số màn hình
sử dụng chúng, nhiều nhất trước.

Mỗi widget: một golden test trong test/golden/, doc comment nêu rõ khi nào dùng và
khi nào KHÔNG dùng (xem SlipCard làm mẫu).

Sau mỗi widget, chạy flutter analyze và flutter test rồi mới sang cái tiếp theo.
```

Xem lại từng golden trước khi đi tiếp. Ảnh vàng sai ở bước này sẽ nhân lên 15 lần.

---

## Bước 3 — Dựng 14 màn còn lại song song

Đây là lúc dùng dynamic workflow — mỗi màn một agent, mỗi agent một thư mục riêng
nên gần như không xung đột file:

```
ultracode: dựng 14 màn hình còn lại của SoloDesk (màn 01, 03–15) trong
lib/features/, mỗi màn một agent screen-builder, mỗi agent làm đúng một màn.

Mỗi agent phải đọc đúng khối MÀN <số> trong design/solodesk-mobile-ui.html gồm cả
figcaption, theo skill solodesk-screen, và chỉ được tạo file trong thư mục màn của
mình cộng với test/golden/.

Sau khi tất cả xong, chạy một lượt kiểm tra cuối: flutter analyze, flutter test, và
tổng hợp danh sách widget private mà các agent đề nghị nâng lên lib/ui/.
```

Theo dõi bằng `/workflows`. Có thể dừng, xem prompt của từng agent, khởi động lại
agent nào lệch hướng.

Ghi chú: dynamic workflow cần Claude Code từ v2.1.154 và có trên các gói trả phí;
trên gói Pro cần bật ở dòng *Dynamic workflows* trong `/config`. Runtime chạy tối đa
16 agent đồng thời. Nếu không dùng được, thay bằng cách chạy tuần tự theo nhóm 3–4
màn một lượt — chậm hơn nhưng cho ra kết quả tương đương.

---

## Bước 4 — Kiểm chứng bằng mắt, không chỉ bằng test

Golden test bắt được hồi quy nhưng không bắt được "dựng đúng cấu trúc mà nhìn sai".
Chạy app thật và bắt Claude tự so:

**Claude Code Desktop** chạy được app trong iOS Simulator và tự nhìn màn hình
(https://code.claude.com/docs/en/desktop-ios-simulator). Prompt:

```
Chạy app trong simulator, mở lần lượt từng màn hình, so với khối tương ứng trong
design/solodesk-mobile-ui.html.

Với mỗi màn, liệt kê chênh lệch theo mức độ: sai quy ước màu (nghiêm trọng), sai bố
cục (vừa), lệch khoảng cách dưới 4pt (bỏ qua).

Chưa sửa gì. Đưa danh sách trước.
```

Rồi sửa theo từng nhóm, không sửa một lượt cả 15 màn.

---

## Bước 5 — Thêm một vòng phản biện

Trước khi merge:

```
Đọc lại 7 quy tắc trong CLAUDE.md, rà toàn bộ lib/features/ và tìm chỗ vi phạm.

Với mỗi vi phạm: trích dòng code, nêu quy tắc bị phá, và đề xuất cách sửa.
Nghiêm khắc hơn bình thường — mục tiêu là tìm ra lỗi, không phải xác nhận là ổn.
```

---

## Vì sao chia nhỏ như vậy

Một prompt kiểu "dựng hết 15 màn hình theo file HTML này" sẽ chạy, sẽ compile, và sẽ
sai — sai theo kiểu khó thấy: màu hồng lọt vào chỗ không phải tiền, Kanban mọc ra
kéo thả, chuỗi tiếng Việt bị viết lại theo giọng khác.

Ba thứ ngăn điều đó, xếp theo hiệu quả:

1. **Hook `verify_dart.sh`** — chặn ngay tại chỗ, trước khi lỗi lan sang màn khác.
   Đây là thứ hiệu quả nhất và cũng rẻ nhất.
2. **Golden test** — biến "trông có đúng không" thành một câu hỏi có đáp án.
3. **CLAUDE.md + rules** — cho Claude biết ranh giới trước khi nó chạm vào.

Đọc thêm: https://code.claude.com/docs/en/best-practices — nguyên tắc đầu tiên trong
đó đúng là "cho Claude một cách tự kiểm chứng công việc của mình".
