import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';

/// Đường xé đứt nét, `.perf` trong bản phác thảo.
///
/// **Dùng khi:** chia một thẻ thành hai phần mà phần dưới là *hệ quả* của phần
/// trên — số tiền rồi tới nút thanh toán, danh sách đợt rồi tới tổng, thông tin
/// file rồi tới hành động. Nó đọc như đường xé của một tờ biên lai.
///
/// Dùng được cả trong `SlipCard` lẫn trong `Card` thường — MÀN 05 và MÀN 08 đặt
/// nó trong `Card`, và đó là chủ ý.
///
/// **KHÔNG dùng khi:**
/// - Chỉ cần một đường kẻ ngăn hai dòng ngang hàng nhau — dùng `Divider`, đường
///   xé mang nghĩa mạnh hơn thế nhiều.
/// - Ngăn cách hai thẻ khác nhau — hai `Card` đã tự cách nhau bằng khoảng trống.
///
/// ## Một chỗ phải diễn giải lại
///
/// CSS `border-top: dashed` để trình duyệt tự chọn độ dài gạch. Flutter không có
/// nét đứt sẵn nên [dash] và [gap] được đặt tay cho ra đúng cảm giác đường xé
/// của bản phác thảo. Đổi hai số này là đổi chữ ký thị giác của cả app.
class PerforatedDivider extends StatelessWidget {
  const PerforatedDivider({
    super.key,
    this.bleed = AppGap.slip,
    this.thickness = 1.5,
    this.dash = 4,
    this.gap = 3,
    this.color = AppColors.line,
  });

  /// Phần thò ra mỗi bên để đường xé chạy hết chiều ngang thẻ, xuyên qua padding.
  ///
  /// Mặc định bằng padding của `SlipCard`. Đặt trong `Card` thì truyền
  /// [AppGap.card]; đặt trong khối không có padding thì truyền `0`.
  final double bleed;

  final double thickness;

  /// Độ dài một gạch.
  final double dash;

  /// Khoảng hở giữa hai gạch.
  final double gap;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppGap.lg),
      child: SizedBox(
        height: thickness,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Rộng hơn ô chứa đúng [bleed] mỗi bên. OverflowBox căn giữa nên
            // phần thừa chia đều hai phía, tràn qua padding của thẻ.
            final width = constraints.maxWidth + bleed * 2;
            return OverflowBox(
              minWidth: width,
              maxWidth: width,
              minHeight: thickness,
              maxHeight: thickness,
              child: CustomPaint(
                size: Size(width, thickness),
                painter: _PerforationPainter(
                  color: color,
                  thickness: thickness,
                  dash: dash,
                  gap: gap,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PerforationPainter extends CustomPainter {
  const _PerforationPainter({
    required this.color,
    required this.thickness,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double thickness;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      final end = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
    }
  }

  @override
  bool shouldRepaint(_PerforationPainter old) =>
      old.color != color ||
      old.thickness != thickness ||
      old.dash != dash ||
      old.gap != gap;
}
