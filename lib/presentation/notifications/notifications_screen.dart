import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/widgets/error_retry_widget.dart';
import 'package:mobile/core/widgets/loading_shimmer.dart';
import 'package:mobile/domain/providers/notification_provider.dart';
import 'package:mobile/presentation/notifications/widgets/notification_tile.dart';

/// Màn hình danh sách thông báo.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () =>
                  ref.read(notificationProvider.notifier).markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Đọc tất cả'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (error, _) => ErrorRetryWidget(
          message: error.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.invalidate(notificationProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 56, color: AppColors.textTertiary),
                  SizedBox(height: 12),
                  Text('Không có thông báo'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationProvider),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, index) {
                final noti = notifications[index];
                return NotificationTile(
                  notification: noti,
                  onTap: () {
                    if (!noti.isRead) {
                      ref
                          .read(notificationProvider.notifier)
                          .markAsRead(noti.id);
                    }
                  },
                  onDismiss: () {
                    ref
                        .read(notificationProvider.notifier)
                        .markAsRead(noti.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã đánh dấu đã đọc'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
