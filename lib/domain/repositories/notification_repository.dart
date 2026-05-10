import 'package:mobile/domain/models/app_notification.dart';

/// Interface cho repository quản lý thông báo.
abstract class NotificationRepository {
  /// Lấy tất cả thông báo.
  Future<List<AppNotification>> getNotifications();

  /// Đánh dấu một thông báo đã đọc.
  Future<void> markAsRead(String id);

  /// Đánh dấu tất cả thông báo đã đọc.
  Future<void> markAllAsRead();

  /// Đếm số thông báo chưa đọc.
  Future<int> getUnreadCount();
}
