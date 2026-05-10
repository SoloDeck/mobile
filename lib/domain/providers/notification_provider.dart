import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/repositories/mock_notification_repository.dart';
import 'package:mobile/domain/models/app_notification.dart';
import 'package:mobile/domain/repositories/notification_repository.dart';

/// Provider cho [NotificationRepository].
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
});

/// Provider quản lý danh sách thông báo.
final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(
        NotificationNotifier.new);

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  FutureOr<List<AppNotification>> build() async {
    final repo = ref.read(notificationRepositoryProvider);
    return repo.getNotifications();
  }

  /// Đánh dấu thông báo đã đọc.
  Future<void> markAsRead(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAsRead(id);
    state = AsyncData(
      (state.value ?? [])
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(),
    );
  }

  /// Đánh dấu tất cả đã đọc.
  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead();
    state = AsyncData(
      (state.value ?? []).map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}

/// Provider đếm thông báo chưa đọc.
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
