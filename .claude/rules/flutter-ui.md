---
paths: ["lib/ui/**", "lib/features/**"]
---

# Quy tắc cho tầng giao diện

Áp dụng khi đọc hoặc sửa bất kỳ file nào trong `lib/ui/` và `lib/features/`.

## Bố cục

- Khung tham chiếu là 390 × 844 pt. Mọi khoảng cách trong bản phác thảo được ghi theo
  khung này — chép thẳng, không quy đổi.
- Lề trái/phải màn hình luôn là `AppGap.screen`. Không có ngoại lệ.
- Hành động chính nằm ở 1/3 dưới màn hình. Trên màn cuộn, đặt trong dải nổi ở đáy
  với gradient chuyển sang `AppColors.paper`.
- Vùng chạm tối thiểu 44 × 44 pt kể cả khi icon nhỏ hơn.

## Widget

- Ưu tiên `const` ở mọi chỗ có thể. Danh sách con nên là `const [...]`.
- Không lồng `Container` chỉ để thêm padding — dùng `Padding`.
- Không bọc `Card` trong `Container` để đổi viền; `AppTheme` đã cấu hình sẵn.
- Widget dùng ở từ hai màn trở lên thì chuyển sang `lib/ui/`, kèm doc comment nêu rõ
  khi nào được dùng và khi nào không.

## Tiếp cận

- Mọi biểu tượng đứng một mình phải có `Semantics(label:)` bằng tiếng Việt.
- Trạng thái không được truyền tải chỉ bằng màu. Chip "quá hạn" phải có chữ, không
  chỉ có nền hồng.
- Không đặt cỡ chữ nhỏ hơn 11 pt.

## Chuỗi hiển thị

Chép nguyên văn tiếng Việt từ bản phác thảo. Nếu cần chuỗi mới, viết theo cùng giọng:
động từ chủ động, câu ngắn, tên gọi theo cách người dùng gọi chứ không theo cách hệ
thống được xây ("Nhắc thanh toán", không phải "Gửi reminder job").
