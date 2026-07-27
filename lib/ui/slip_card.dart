import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';

/// Tấm phiếu giấy răng cưa, `.slip` trong bản phác thảo.
///
/// Đây là **chữ ký thị giác** của SoloDesk: người dùng lướt nhanh nhìn thấy hai
/// vết cắt hai bên là biết ngay “đây là tiền”, trước khi kịp đọc chữ.
///
/// ## Chỉ dùng cho tiền
///
/// **Dùng khi:** nội dung của thẻ là một khoản tiền hoặc một chứng từ tiền —
/// công nợ (MÀN 02), lịch thanh toán (MÀN 05), khoảng giá gợi ý (MÀN 07), doanh
/// thu (MÀN 11), bản nhắc thu tiền (MÀN 12), gói dịch vụ đang trả phí (MÀN 13),
/// số liệu tiền đã cũ khi mất mạng (MÀN 15).
///
/// **KHÔNG dùng khi:** nội dung không liên quan tiền. Thẻ thường dùng `Card`.
/// Tấm phiếu răng cưa xuất hiện ở chỗ không phải tiền là làm hỏng quy ước thị
/// giác của cả app — đây là quy tắc 3 trong `AGENTS.md`, không phải gợi ý.
///
/// **KHÔNG dùng khi** chỉ muốn thẻ trông đẹp hơn `Card`. Đó chính là cách quy
/// tắc 3 bị phá trong thực tế.
///
/// ## Hai ngoại lệ trong bản phác thảo — cố ý không chép theo
///
/// Bản phác thảo dùng `.slip` ở hai chỗ không phải tiền:
/// - **MÀN 01** — thẻ “Lần đăng nhập gần nhất”.
/// - **MÀN 10** — thẻ “File đang chọn”.
///
/// Cả hai khi dựng sẽ dùng `Card`. Đã chốt giữ nguyên quy tắc 3 thay vì nới nó;
/// xem `docs/adr/solodesk-ui-config-conflicts.md`. Đừng “sửa lại cho giống bản
/// phác thảo” — lệch này là có chủ ý.
class SlipCard extends StatelessWidget {
  const SlipCard({
    super.key,
    required this.child,
    this.notch = 96,
    this.borderColor = AppColors.line,
    this.borderWidth = 1,
    this.gradient,
    this.stale = false,
    this.padding = const EdgeInsets.all(AppGap.slip),
  });

  final Widget child;

  /// Khoảng cách từ mép trên thẻ tới **mép trên** của vết cắt, đúng nghĩa biến
  /// `--notch` trong bản phác thảo.
  ///
  /// Đặt sao cho vết cắt rơi vào đúng dòng ngăn giữa hai phần của tấm phiếu —
  /// nó là bản lề thị giác, không phải hoạ tiết đặt bừa.
  final double notch;

  /// Viền thẻ. MÀN 12 dùng viền hồng nhạt, MÀN 13 dùng viền tím 2px.
  final Color borderColor;
  final double borderWidth;

  /// Nền chuyển sắc thay cho nền trắng. MÀN 13.
  final Gradient? gradient;

  /// Số liệu cũ khi mất mạng: xám hoá và mờ đi. MÀN 15.
  ///
  /// Không chặn thao tác, chỉ báo rằng con số này chụp từ lúc còn mạng.
  final bool stale;

  final EdgeInsetsGeometry padding;

  /// Bán kính vết cắt. Bản phác thảo dùng hình tròn đường kính 18.
  static const double notchRadius = AppRadius.slipNotch;

  /// Tâm vết cắt nằm lệch ra ngoài mép thẻ 1pt, nên nó ăn vào thân thẻ 8pt.
  static const double _notchCenterOffset = 1;

  /// Ma trận xám hoá theo trọng số sáng của mắt người, tương đương
  /// `filter: grayscale(1)` của CSS.
  static const ColorFilter _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final Widget card = CustomPaint(
      painter: _SlipPainter(
        notch: notch,
        borderColor: borderColor,
        borderWidth: borderWidth,
        gradient: gradient,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (!stale) return card;

    return Opacity(
      opacity: 0.72,
      child: ColorFiltered(colorFilter: _grayscale, child: card),
    );
  }
}

class _SlipPainter extends CustomPainter {
  const _SlipPainter({
    required this.notch,
    required this.borderColor,
    required this.borderWidth,
    required this.gradient,
  });

  final double notch;
  final Color borderColor;
  final double borderWidth;
  final Gradient? gradient;

  /// Thân thẻ đã trừ đi hai vết cắt hai bên.
  Path _shape(Size size) {
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppRadius.card),
        ),
      );

    final centerY = notch + SlipCard.notchRadius;
    Path bite(double centerX) => Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: SlipCard.notchRadius,
        ),
      );

    return Path.combine(
      PathOperation.difference,
      Path.combine(
        PathOperation.difference,
        body,
        bite(-SlipCard._notchCenterOffset),
      ),
      bite(size.width + SlipCard._notchCenterOffset),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final shape = _shape(size);

    final fill = Paint()..isAntiAlias = true;
    if (gradient == null) {
      fill.color = AppColors.surface;
    } else {
      fill.shader = gradient!.createShader(Offset.zero & size);
    }
    canvas.drawPath(shape, fill);

    canvas.drawPath(
      shape,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_SlipPainter old) =>
      old.notch != notch ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth ||
      old.gradient != gradient;
}
