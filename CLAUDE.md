# 🤖 CLAUDE.md - SoloDesk Mobile Repository

## 1. Bối cảnh dự án (Project Context)

- **Tên dự án:** SoloDesk Mobile App.
- **Mục tiêu:** Ứng dụng đồng hành giúp Freelancer cập nhật nhanh trạng thái khách hàng, nhận thông báo (push notifications) và thu thập thông tin bằng giọng nói khi đang di chuyển.
- **Tech Stack cốt lõi:**
  - Framework: Flutter.
  - Ngôn ngữ: Dart (yêu cầu Sound Null Safety).
  - State Management: Riverpod.
  - Local Database (Offline Cache): SQLite (thông qua package `sqflite` hoặc `drift`).
  - Push Notifications: Firebase Cloud Messaging (FCM).

## 2. Quy tắc lập trình (Coding Guidelines)

- **Quản lý Trạng thái:** Sử dụng kiến trúc của `Riverpod`. Tránh dùng `setState` tràn lan. Tách biệt giao diện và logic thông qua các `NotifierProvider` hoặc `AsyncNotifierProvider`.
- **Kiến trúc Offline-First:** Ứng dụng phải hoạt động được khi mất mạng. Mọi thay đổi trạng thái Deal/Khách hàng cần được lưu vào SQLite cục bộ trước, sau đó đồng bộ (Sync) lên máy chủ khi có kết nối Internet.
- **Xử lý Giọng nói (Voice-to-Lead):** Tối ưu hóa luồng ghi âm và gọi API chuyển giọng nói thành văn bản. Hiển thị rõ trạng thái đang ghi âm/đang xử lý AI.
- **Thiết kế UI:** Sử dụng Material Design 3 kết hợp với các tinh chỉnh riêng để đồng bộ nhận diện thương hiệu với phiên bản Web.

## 3. Cấu trúc thư mục (Directory Structure)

- `lib/core`: Cấu hình app, theme, routing, utils, và network client.
- `lib/data`: Models, SQLite repositories, và API data sources.
- `lib/domain`: Business logic và providers (Riverpod).
- `lib/presentation`: Screens (màn hình) và Widgets (thành phần UI tái sử dụng).

## 4. Các lệnh cơ bản (Commands)

- Lấy packages: `flutter pub get`
- Sinh code (nếu dùng build_runner/freezed): `flutter pub run build_runner build --delete-conflicting-outputs`
- Chạy app (Debug): `flutter run`
