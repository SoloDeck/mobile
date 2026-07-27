import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';

/// Thẻ viền đứt nét — báo đây là khu vực tạm thời/hàng chờ
/// (`border-style:dashed` trong bản phác thảo), không phải một `Card` nội
/// dung cố định. `CardTheme` không có biến thể viền đứt nét sẵn nên vẽ tay
/// bằng [DashedRRectPainter], cùng cách `PerforatedDivider`
/// (`lib/ui/perforated_divider.dart`) vẽ đường xé bằng `CustomPaint`.
///
/// Trích từ MÀN 15 (`lib/features/offline/offline_screen.dart`, nguyên
/// `_EmptyOutboxCard` + `_DashedRRectPainter`) — phần khung tách khỏi phần
/// nội dung cụ thể ("Chưa gửi được tin nhắn nào") để dùng lại được ở nơi khác.
///
/// **Dùng khi:** một hộp trạng thái tạm thời/rỗng cần phân biệt trực quan với
/// `Card` nội dung thật, ví dụ hộp thư đi rỗng khi ngoại tuyến ở MÀN 02.
///
/// **KHÔNG dùng khi:** nội dung đã có dữ liệu thật và ổn định — dùng `Card`
/// thường; viền đứt nét sẽ đọc sai thành "tạm thời/chưa xong".
class DashedCard extends StatelessWidget {
  const DashedCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const DashedRRectPainter(),
      child: Padding(padding: const EdgeInsets.all(AppGap.card), child: child),
    );
  }
}

/// Vẽ nền trắng bo góc `AppRadius.card` cùng viền đứt nét quanh mép, đúng
/// cảm giác `border-style:dashed` của bản phác thảo.
///
/// Dùng trực tiếp bên trong [DashedCard]; để công khai phòng khi nơi khác
/// cần đúng nét vẽ này mà không muốn qua padding mặc định của [DashedCard].
class DashedRRectPainter extends CustomPainter {
  const DashedRRectPainter();

  static const Color _color = AppColors.line;
  static const double _radius = AppRadius.card;
  static const double _dash = 4;
  static const double _gap = 3;
  static const double _strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_radius),
    );

    canvas.drawRRect(rrect, Paint()..color = AppColors.surface);

    final outline = Path()..addRRect(rrect);
    final stroke = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + _dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), stroke);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectPainter old) => false;
}
