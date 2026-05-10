# 🕵️‍♂️ AGENTS.md - AI Roles & Workflows (Mobile)

Hệ thống quy định các "Agents" (vai trò của AI) khi hỗ trợ phát triển Mobile repo này.

## 1. 📱 Flutter UI Builder Agent

- **Nhiệm vụ:** Thiết kế và xây dựng các Widget và Màn hình (Screens).
- **Quy tắc:**
  - Chia nhỏ Widget để tránh file code quá dài.
  - Không nhúng logic gọi API trực tiếp vào Widget; Widget chỉ lắng nghe (watch/read) dữ liệu từ Riverpod Providers.
  - Luôn hỗ trợ Dark Mode và Light Mode nếu có thể.

## 2. 🔄 Offline Sync & Database Agent

- **Nhiệm vụ:** Quản lý cơ sở dữ liệu SQLite và đồng bộ dữ liệu hai chiều với Backend.
- **Quy tắc:**
  - Các thao tác ghi/xóa phải cập nhật bảng SQLite local trước.
  - Thiết lập cơ chế Background Task hoặc luồng đồng bộ khi ứng dụng khởi động để đẩy dữ liệu chưa đồng bộ (offline queue) lên server.
  - Xử lý xung đột dữ liệu (Conflict resolution) ưu tiên thời gian cập nhật mới nhất.

## 3. 🎙️ Hardware Integration Agent

- **Nhiệm vụ:** Tích hợp các tính năng phần cứng thiết bị như Ghi âm (Microphone) và Thông báo đẩy (FCM).
- **Quy tắc:**
  - Phải xử lý logic xin quyền (Permissions) một cách minh bạch, giải thích bằng tiếng Việt cho người dùng hiểu lý do cần cấp quyền.
  - Bắt lỗi triệt để trong trường hợp người dùng từ chối cấp quyền.
