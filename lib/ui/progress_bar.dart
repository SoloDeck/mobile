import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';

/// Thanh tiến độ bo tròn, `.bar` trong bản phác thảo.
///
/// **Dùng khi:** thể hiện một tỉ lệ của cùng một đại lượng — 7/11 việc đã xong
/// (MÀN 09), 1,8/10 GB đã dùng (MÀN 10, 13), 18/80 lượt AI (MÀN 13), tỉ trọng
/// từng nhóm tuổi nợ (MÀN 11), độ hoàn thiện của một deal (MÀN 04).
///
/// **KHÔNG dùng khi:**
/// - Cần so sánh nhiều đại lượng khác nhau cạnh nhau — đó là biểu đồ, dựng riêng
///   trong màn cần nó.
/// - Muốn thể hiện *các bước* của một quy trình — dùng `StageBar`, nó chia đoạn
///   rời và nói được “bước 5/6”, còn thanh này chỉ nói được phần trăm.
/// - Đang chờ tải dữ liệu. Đây là thanh tĩnh, không có trạng thái vô định; dùng
///   `LoadingShimmer` của tầng `shared`.
///
/// [value] là tỉ lệ trong khoảng 0–1, tự kẹp lại nếu truyền ngoài khoảng.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = standard,
    this.color = AppColors.ink,
    this.gradient,
    this.trackColor = AppColors.line,
  });

  /// Chiều cao mặc định.
  static const double standard = 6;

  /// Chiều cao khi thanh là số liệu chính của một thẻ. MÀN 09.
  static const double thick = 8;

  final double value;
  final double height;

  /// Màu phần đã đầy. Bỏ qua nếu có [gradient].
  final Color color;

  /// Nền chuyển sắc cho phần đã đầy. MÀN 09 dùng tím → hồng.
  final Gradient? gradient;

  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final ratio = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: AppRadius.pillAll,
      child: SizedBox(
        height: height,
        child: ColoredBox(
          color: trackColor,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: ratio,
              // Không có heightFactor thì DecoratedBox rỗng co về chiều cao 0 và
              // thanh chỉ còn cái rãnh.
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: gradient == null ? color : null,
                  gradient: gradient,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
