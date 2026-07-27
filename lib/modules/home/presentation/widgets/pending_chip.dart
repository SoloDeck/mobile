import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';

/// Chip nhỏ trên nền tối (`AppColors.ink`) — nền và viền trắng trong suốt.
///
/// Trích từ MÀN 15 (`lib/features/offline/offline_screen.dart`, nguyên
/// `_PendingChip`), dùng trong [OfflineBanner] cho số mục đang chờ gửi.
///
/// **Dùng khi:** cần một chip trên nền mực, như dải báo ngoại tuyến. `StatusChip`
/// (`lib/ui/status_chip.dart`) cố ý không có biến thể nền tối — xem doc của nó:
/// "Cần chip trên nền tối như MÀN 06… dựng private trong màn đó". `PendingChip`
/// là biến thể ấy, đã có màn thứ hai dùng (MÀN 02 ở trạng thái ngoại tuyến) nên
/// mới nâng lên đây.
///
/// **KHÔNG dùng khi:** chip đặt trên nền sáng (giấy/trắng) — dùng `StatusChip`,
/// nó có đủ tone màu mang nghĩa mà `PendingChip` không có.
class PendingChip extends StatelessWidget {
  const PendingChip(this.label, {super.key});

  /// Chữ hiển thị, ví dụ "3 chờ gửi".
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.md,
        vertical: AppGap.chipVertical,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.16),
        borderRadius: AppRadius.chipAll,
        border: Border.all(color: AppColors.surface.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: AppText.chip.copyWith(color: AppColors.surface),
        softWrap: false,
      ),
    );
  }
}
