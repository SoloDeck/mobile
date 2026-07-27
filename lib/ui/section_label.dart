import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_text.dart';

/// Nhãn mục in hoa giãn cách, `.lbl` trong bản phác thảo.
///
/// **Dùng khi:** đặt tên cho một khối nội dung ngay phía trên nó — “Đang chờ thu
/// · tháng 7”, “Hàng chờ đồng bộ”, “Lịch thanh toán”. Đây là nhãn *tĩnh*, nói
/// khối bên dưới là gì.
///
/// **KHÔNG dùng khi:**
/// - Nhãn có kèm một liên kết ở mép phải (“Chi tiết”, “Tất cả”) — đó là
///   `SectionHeader`, nó lo cả hai vế và khoảng cách giữa chúng.
/// - Muốn một dòng tiêu đề đọc được thành câu — cỡ 10pt in hoa giãn cách chỉ hợp
///   với 2–5 từ. Câu dài dùng `AppText.sub`.
/// - Nội dung là một con số — dùng `MonoText` hoặc `Money`.
///
/// Chữ truyền vào viết thường như trong bản phác thảo; widget tự in hoa, đúng
/// cách `text-transform: uppercase` hoạt động ở bản HTML. Nhờ vậy chuỗi trong mã
/// nguồn vẫn đọc được và vẫn khớp nguyên văn với bản phác thảo.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});

  /// Chữ viết thường, tiếng Việt, chép từ bản phác thảo.
  final String text;

  /// Đổi màu khi nhãn nằm trên nền tối. Mặc định là màu chữ mờ.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: color == null
          ? AppText.label
          : AppText.label.copyWith(color: color),
    );
  }
}
