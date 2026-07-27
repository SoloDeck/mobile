import 'package:flutter/material.dart';
import 'package:solodesk_mobile/modules/home/presentation/widgets/pending_chip.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Dải báo mất mạng — nền mực chạy hết chiều ngang màn hình, không lùi theo
/// `AppGap.screen` như phần thân bên dưới nó.
///
/// Trích từ MÀN 15 (`lib/features/offline/offline_screen.dart`, nguyên
/// `_OfflineBanner`). MÀN 15 không còn là page riêng — nó là trạng thái ngoại
/// tuyến của MÀN 02, nên widget này tách ra để MÀN 02 tự đặt lên trên
/// `SoloAppBar` khi mất mạng.
///
/// **Dùng khi:** màn đang ở trạng thái mất mạng và cần báo giờ chụp dữ liệu
/// cũ, đặt trên cùng cột nội dung, trước thanh tiêu đề.
///
/// **KHÔNG dùng khi:** màn có mạng — đừng hiện banner này "phòng hờ", nó chỉ
/// xuất hiện khi thật sự ngoại tuyến.
///
/// Cỡ chữ 12px trong bản phác thảo không khớp token nào — đây là ngoại lệ có
/// chủ đích của MÀN 15 gốc (dùng `AppText.sub` là lệch cỡ gần nhất nên viết
/// tay 12px), không phải khoảng cách bịa ra tại chỗ.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.message,
    required this.pendingLabel,
  });

  /// Chuỗi báo mất mạng kèm giờ chụp dữ liệu cũ, ví dụ
  /// "Đang ngoại tuyến · dữ liệu lúc 08:14".
  final String message;

  /// Nhãn số mục đang chờ gửi, ví dụ "3 chờ gửi", hiển thị trong [PendingChip].
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.screen,
        vertical: AppGap.md,
      ),
      child: Row(
        children: [
          const SoloIcon(
            SoloIcons.wifiOff,
            label: 'Mất kết nối mạng',
            size: SoloIcon.sm,
            color: AppColors.surface,
          ),
          const SizedBox(width: AppGap.row),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppFontFamily.body,
                fontSize: 12,
                color: AppColors.surface,
              ),
            ),
          ),
          PendingChip(pendingLabel),
        ],
      ),
    );
  }
}
