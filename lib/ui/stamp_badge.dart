import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/tone.dart';

/// Con dấu nghiêng đóng lên một chứng từ, `.stamp` trong bản phác thảo.
///
/// **Dùng khi:** nói tình trạng *pháp lý hoặc tài chính* của cả tấm phiếu hay cả
/// tài liệu — “Quá hạn 6 ngày”, “Đã thu”, “Bản nháp”. Nó nghiêng và có viền dày
/// vì phải đọc như một con dấu mực đóng lên giấy, không thể nhầm với nhãn thường.
///
/// **KHÔNG dùng khi:**
/// - Chỉ là một trạng thái phụ hoặc một bộ lọc — dùng `StatusChip`. Mỗi màn chỉ
///   nên có **một** con dấu; đóng nhiều dấu thì không cái nào còn sức nặng.
/// - Nó bấm được. Con dấu là nhận định, không phải hành động.
///
/// Ba dạng theo bản phác thảo: [StampBadge.due] tiền chưa thu, [StampBadge.paid]
/// đã xong, [StampBadge.draft] bản máy sinh chưa được duyệt.
class StampBadge extends StatelessWidget {
  const StampBadge(this.text, {super.key, this.tone = Tone.money});

  /// Chưa thu, quá hạn — hồng. MÀN 02, 05, 12.
  const StampBadge.due(this.text, {super.key}) : tone = Tone.money;

  /// Đã thu, đã xong — ngọc.
  const StampBadge.paid(this.text, {super.key}) : tone = Tone.ok;

  /// Bản nháp máy sinh, chờ người duyệt — tím. MÀN 08, 13.
  const StampBadge.draft(this.text, {super.key}) : tone = Tone.ai;

  /// Chữ viết thường; widget tự in hoa như `text-transform` của bản phác thảo.
  final String text;

  final Tone tone;

  /// Độ nghiêng của con dấu, theo `rotate(-7deg)`.
  static const double _tiltRadians = -7 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final color = tone.accent;

    return Transform.rotate(
      angle: _tiltRadians,
      child: Opacity(
        opacity: 0.92,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppGap.md,
            vertical: AppGap.chipVertical,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(AppRadius.stamp),
          ),
          child: Text(
            text.toUpperCase(),
            style: AppText.stamp.copyWith(color: color),
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
