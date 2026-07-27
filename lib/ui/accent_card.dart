import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/tone.dart';

/// Thẻ có vạch màu chạy dọc mép trái, `.card` + `border-left` trong bản phác thảo.
///
/// **Dùng khi:** một thẻ trong danh sách cần nói ngay *loại* việc của nó mà
/// không tốn thêm dòng chữ nào. MÀN 02 xếp ba việc cạnh nhau và chỉ dựa vào vạch
/// này để phân biệt: hồng là tiền, tím là AI chờ duyệt, hổ phách là trễ hạn.
///
/// **KHÔNG dùng khi:**
/// - Mọi thẻ trong danh sách đều cùng loại — vạch màu lúc đó không phân biệt gì,
///   chỉ thêm nhiễu. Dùng `Card`.
/// - Nội dung là tiền và cần đọc như một chứng từ — dùng `SlipCard`.
/// - Muốn *cả thẻ* đổi màu nền để gây chú ý — đó là `NoticeCard`. Bản phác thảo
///   chỉ cho phép nền hồng ở thông báo tiền, và không quá một thẻ mỗi màn.
///
/// Vạch màu là tín hiệu phụ, không phải tín hiệu duy nhất: nội dung thẻ vẫn phải
/// nói rõ nó là việc gì, vì trạng thái không được truyền tải chỉ bằng màu.
class AccentCard extends StatelessWidget {
  const AccentCard({
    super.key,
    required this.child,
    this.tone = Tone.money,
    this.padding = const EdgeInsets.all(AppGap.card),
  });

  final Widget child;

  /// Loại việc mà thẻ này đại diện.
  final Tone tone;

  final EdgeInsetsGeometry padding;

  /// Bề dày vạch màu.
  static const double accentWidth = 3;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: AppColors.line),
      ),
      child: ClipRRect(
        // Bo góc trong nhỏ hơn bo góc ngoài đúng bề dày viền, để vạch màu không
        // nhô ra khỏi đường viền ở bốn góc.
        borderRadius: BorderRadius.circular(AppRadius.card - 1),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: tone.accent,
                child: const SizedBox(width: accentWidth),
              ),
              Expanded(
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
