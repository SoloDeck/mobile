import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';

/// Dải hành động nổi ở đáy màn, có gradient chuyển sang màu giấy.
///
/// **Dùng khi:** màn hình cuộn được và hành động chính phải luôn nằm trong tầm
/// ngón cái — “Duyệt và gửi khách” (MÀN 08), “Chụp hoặc chọn file” (MÀN 10),
/// “Gửi ngay” (MÀN 12), “Nâng lên Business” (MÀN 13).
///
/// **KHÔNG dùng khi:**
/// - Màn hình không cuộn và nội dung đã tự đẩy nút xuống đáy — MÀN 01 làm vậy,
///   không cần dải nổi vì không có gì trôi qua bên dưới.
/// - Màn hình có `SoloNavBar`. Hai thanh chồng lên nhau ở đáy là bắt ngón cái
///   chọn giữa hai thứ cùng lúc; bản phác thảo không có màn nào như thế.
/// - Chỉ để đặt một dòng chú thích — dải này tồn tại vì cái nút, không phải vì
///   cái nền.
///
/// Gradient là phần bắt buộc chứ không phải trang trí: nó cho người dùng thấy
/// nội dung còn chạy tiếp bên dưới nút, thay vì tưởng đã hết trang.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child, this.caption});

  /// Nút hoặc hàng nút. Hành động chính luôn là nút đặc.
  final Widget child;

  /// Dòng giải thích nhỏ dưới nút: “Gửi qua Zalo OA · kèm link xem bản PDF”,
  /// “Huỷ tự động gia hạn bất cứ lúc nào”.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Cùng một màu giấy, chỉ khác độ trong — nội dung mờ dần vào nền chứ
          // không đâm vào một màu khác.
          colors: [AppColors.paper.withValues(alpha: 0), AppColors.paper],
          stops: const [0, 0.26],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppGap.screen,
          AppGap.card,
          AppGap.screen,
          AppGap.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // `.btn{width:100%}` — nút chính trải hết bề ngang dải, không co lại
          // theo độ dài chữ.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            child,
            if (caption != null) ...[
              const SizedBox(height: AppGap.md),
              Text(caption!, style: AppText.mut, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
