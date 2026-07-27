import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_text.dart';

/// Chữ số hệ mono, `.num` trong bản phác thảo.
///
/// **Dùng khi:** hiển thị bất kỳ con số nào cần đọc chính xác hoặc so cột với
/// dòng khác — “7/11 việc”, “1,8 / 10 GB”, “18 / 80”, “78”, “+9”, “BG-2026-0042”.
/// Chữ số đều cột nên các dòng xếp chồng luôn thẳng hàng.
///
/// **KHÔNG dùng khi:** con số là *một khoản tiền chính xác*. Dùng `Money` — nó
/// lo cả định dạng nghìn lẻ, ký hiệu ₫, và quan trọng nhất là màu mang nghĩa.
/// Viết `MonoText('12.500.000 ₫')` là bỏ qua toàn bộ tầng ngữ nghĩa đó.
///
/// Vẫn dùng [MonoText] cho số tiền *không chính xác*: khoảng giá
/// (“14 – 19 triệu ₫”), ước tính (“~15.000.000 ₫”), rút gọn (“16,7 tr”) — bản
/// phác thảo cố ý viết chúng như chữ chứ không như một con số máy tính ra.
class MonoText extends StatelessWidget {
  const MonoText(this.text, {super.key, this.style, this.color});

  /// Chuỗi đã định dạng sẵn.
  final String text;

  /// Mặc định [AppText.num]. Đổi sang `numMd`, `numLg`, `numHero` khi cần lớn hơn.
  final TextStyle? style;

  /// Ghi đè màu chữ mà vẫn giữ nguyên cỡ và độ đậm.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppText.num;
    return Text(
      text,
      style: color == null ? base : base.copyWith(color: color),
    );
  }
}
