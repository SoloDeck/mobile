import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/ui/icon_button_box.dart';

/// Thanh tiêu đề của một màn, `.appbar` trong bản phác thảo.
///
/// **Dùng khi:** mở đầu bất kỳ màn nào trừ MÀN 01. Gồm một chỗ đứng bên trái
/// (nút quay lại hoặc avatar), tiêu đề, và các hành động bên phải.
///
/// **KHÔNG dùng khi:**
/// - Cần `AppBar` của Material với elevation, `SliverAppBar` co giãn, hay nút
///   back tự sinh. Bản phác thảo không có bóng đổ dưới thanh tiêu đề và nút quay
///   lại luôn là `IconButtonBox` ghost đặt thẳng tay.
/// - Màn hình không có tiêu đề — MÀN 01 cố ý bỏ trống phần này để câu chào chiếm
///   trọn phần trên.
///
/// ## Cỡ tiêu đề
///
/// Bản phác thảo dùng năm cỡ, tuỳ độ dài của cái tên phải hiển thị. Đừng tự
/// nghĩ ra cỡ mới — chọn một trong năm hằng số dưới đây và tra lại xem màn của
/// mình giống màn nào.
class SoloAppBar extends StatelessWidget {
  const SoloAppBar({
    super.key,
    required this.title,
    this.leading,
    this.overline,
    this.actions = const [],
    this.titleSize = lg,
    this.onDark = false,
  });

  /// Tên mục cố định: Pipeline, Doanh thu, Thông báo. MÀN 03, 04, 11.
  static const double lg = 22;

  /// Tiêu đề có dòng ngày tháng bên trên. MÀN 02, 15.
  static const double md = 20;

  /// Màn con của một mục lớn. MÀN 09, 10, 12, 13, 14.
  static const double sm = 18;

  /// Tên một tài liệu: “Kết quả chấm điểm”, “Báo giá BG-2026-0042”. MÀN 07, 08.
  static const double xs = 17;

  /// Tên khách hoặc dự án, thường dài nhất. MÀN 05.
  static const double xxs = 15;

  /// Chữ hiển thị, tiếng Việt, chép từ bản phác thảo.
  final String title;

  /// Nút quay lại hoặc avatar người dùng. `null` = tiêu đề bắt đầu từ lề trái.
  final Widget? leading;

  /// Dòng nhỏ phía trên tiêu đề: “Thứ Bảy, 25/07”, “Dự án”.
  final String? overline;

  /// Hành động bên phải: nút icon, chip, hoặc con dấu.
  final List<Widget> actions;

  final double titleSize;

  /// Đảo màu chữ cho màn nền tối. MÀN 06.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    // `IconButtonBox` rộng hơn hình vẽ 3pt mỗi bên để đủ vùng chạm 44. Trừ lại
    // đúng phần đó để mép ô icon thẳng hàng với lề nội dung 18 của bản phác thảo.
    final leftPad = leading is IconButtonBox
        ? AppGap.screen - IconButtonBox.overhang
        : AppGap.screen;
    final rightPad = actions.isNotEmpty && actions.last is IconButtonBox
        ? AppGap.screen - IconButtonBox.overhang
        : AppGap.screen;

    final titleColor = onDark ? AppColors.surface : AppColors.ink;
    final overlineColor = onDark ? AppColors.line : AppColors.ink3;

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPad, 4, rightPad, AppGap.card),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: AppGap.lg)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (overline != null)
                  Text(
                    overline!,
                    style: AppText.overline.copyWith(color: overlineColor),
                  ),
                Text(
                  title,
                  style: AppText.title.copyWith(
                    fontSize: titleSize,
                    // `letter-spacing:-.02em` theo đúng cỡ chữ đang dùng.
                    letterSpacing: titleSize * -0.02,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          for (final action in actions) ...[
            const SizedBox(width: AppGap.lg),
            action,
          ],
        ],
      ),
    );
  }
}
