import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/ui/section_label.dart';

/// Nhãn mục kèm một lối đi tiếp ở mép phải, `.sec` trong bản phác thảo.
///
/// **Dùng khi:** một khối nội dung vừa cần tên, vừa cần đường dẫn sang danh sách
/// đầy đủ — “Cần bạn xử lý / 3 việc”, “Công nợ theo tuổi nợ / Chi tiết”, “Hàng
/// chờ đồng bộ / Thử lại”.
///
/// **KHÔNG dùng khi:**
/// - Không có gì ở mép phải — dùng `SectionLabel`, nhẹ hơn và không tạo hàng
///   trống bên phải.
/// - [actionLabel] là hành động chính hoặc hành động nguy hiểm. Đây là chữ 11.5pt
///   không viền, hợp với “xem thêm” chứ không hợp với “xoá” hay “gửi”.
///
/// Khoảng cách trên 18 và dưới 9 đã nằm sẵn trong widget, đúng `margin` của
/// `.sec` — đừng bọc thêm `Padding` bên ngoài.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key, this.actionLabel, this.onAction});

  /// Tên khối, viết thường; `SectionLabel` sẽ in hoa.
  final String label;

  /// Chữ của lối đi tiếp. `null` = không có gì ở mép phải.
  final String? actionLabel;

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppGap.sectionTop,
        bottom: AppGap.sectionBottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: SectionLabel(label)),
          if (actionLabel != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Semantics(
                button: onAction != null,
                child: Text(actionLabel!, style: AppText.link),
              ),
            ),
        ],
      ),
    );
  }
}
