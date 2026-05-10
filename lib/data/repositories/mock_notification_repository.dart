import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/mock_data/mock_data.dart';
import 'package:mobile/domain/models/app_notification.dart';
import 'package:mobile/domain/repositories/notification_repository.dart';

/// Mock implementation của [NotificationRepository].
class MockNotificationRepository implements NotificationRepository {
  final List<AppNotification> _notifications =
      List.from(MockData.notifications);

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(AppConstants.mockNetworkDelay);
    return List.unmodifiable(
      _notifications..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    return _notifications.where((n) => !n.isRead).length;
  }
}
