# assets/fonts/

Ba họ chữ của bản phác thảo. App **không** dùng package `google_fonts`
(AGENTS.md quy tắc 6) — font phải bundle sẵn để app chạy ngoại tuyến ngay lần mở
đầu tiên.

## File cần có

Tên file phải khớp chính xác — `test/flutter_test_config.dart` tìm theo tên này.

| File | Nguồn |
|---|---|
| `BricolageGrotesque-Regular.ttf` | fonts.google.com/specimen/Bricolage+Grotesque |
| `BricolageGrotesque-Bold.ttf` | ↑ |
| `BricolageGrotesque-ExtraBold.ttf` | ↑ |
| `BeVietnamPro-Regular.ttf` | fonts.google.com/specimen/Be+Vietnam+Pro |
| `BeVietnamPro-Medium.ttf` | ↑ |
| `BeVietnamPro-SemiBold.ttf` | ↑ |
| `BeVietnamPro-Bold.ttf` | ↑ |
| `IBMPlexMono-Regular.ttf` | fonts.google.com/specimen/IBM+Plex+Mono |
| `IBMPlexMono-Medium.ttf` | ↑ |
| `IBMPlexMono-SemiBold.ttf` | ↑ |

Bricolage Grotesque bản variable (`BricolageGrotesque[opsz,wdth,wght].ttf`) cũng
dùng được, nhưng phải đổi tên thành ba file tĩnh ở trên hoặc sửa lại danh sách
trong `test/flutter_test_config.dart`.

## Trước khi có file

Bộ test vẫn chạy: phần kiểm tra cấu trúc của mỗi widget chạy bình thường, chỉ
phần **so ảnh vàng bị bỏ qua** kèm lý do in ra màn hình. Đây là chủ ý — chụp ảnh
vàng bằng font thay thế là khoá một ảnh sai lại làm chuẩn.

## Sau khi có file

1. Chạy `flutter test` — phần golden hết bị bỏ qua.
2. Chạy `flutter test --update-goldens` một lần để tạo ảnh, rồi **mở ảnh ra xem**
   và so với `design/solodesk-mobile-ui.html` trước khi commit.
3. Dán khối dưới đây vào `pubspec.yaml`, dưới `flutter:`, để app thật cũng dùng
   font này (bộ test không cần bước này):

```yaml
  fonts:
    - family: Bricolage Grotesque
      fonts:
        - asset: assets/fonts/BricolageGrotesque-Regular.ttf
          weight: 400
        - asset: assets/fonts/BricolageGrotesque-Bold.ttf
          weight: 700
        - asset: assets/fonts/BricolageGrotesque-ExtraBold.ttf
          weight: 800
    - family: Be Vietnam Pro
      fonts:
        - asset: assets/fonts/BeVietnamPro-Regular.ttf
          weight: 400
        - asset: assets/fonts/BeVietnamPro-Medium.ttf
          weight: 500
        - asset: assets/fonts/BeVietnamPro-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/BeVietnamPro-Bold.ttf
          weight: 700
    - family: IBM Plex Mono
      fonts:
        - asset: assets/fonts/IBMPlexMono-Regular.ttf
          weight: 400
        - asset: assets/fonts/IBMPlexMono-Medium.ttf
          weight: 500
        - asset: assets/fonts/IBMPlexMono-SemiBold.ttf
          weight: 600
```
