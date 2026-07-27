import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Thẻ tô nền cả mảng để nổi hẳn khỏi danh sách, `.card` + nền `*-soft`.
///
/// **Dùng khi:** một điều kiện đang chặn người dùng hoặc sắp làm họ mất tiền,
/// và họ cần thấy nó trước mọi thứ khác — “Quá hạn thanh toán” (MÀN 03), “Còn 2
/// chỗ trống cần điền trước khi gửi” (MÀN 08), “Mẫu này thiếu điều khoản bản
/// quyền” (MÀN 14), cách thanh toán MoMo (MÀN 13).
///
/// **KHÔNG dùng khi:**
/// - Chỉ muốn phân loại một thẻ trong danh sách — dùng `AccentCard`, vạch màu
///   mép trái đủ để phân biệt mà không cướp sự chú ý.
/// - Có nhiều hơn một thứ cần nhấn mạnh trên cùng màn. Tô nền hai thẻ là không
///   thẻ nào còn nổi. Bản phác thảo mỗi màn chỉ dùng đúng một.
/// - Nội dung là tiền và cần đọc như chứng từ — dùng `SlipCard`.
///
/// Chữ dùng [ToneColors.onSoft] chứ không phải màu tone nguyên bản: hồng và hổ
/// phách nguyên bản không đủ tương phản để đọc một đoạn 12.5pt trên nền nhạt.
class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.tone,
    required this.icon,
    required this.message,
    this.title,
    this.trailing,
  });

  /// Loại cảnh báo. Hồng cho tiền, hổ phách cho việc sắp tới hạn.
  final Tone tone;

  final SoloIconData icon;

  /// Nội dung chính. Viết đủ số liệu để quyết định được ngay, đừng bắt người
  /// dùng mở chi tiết mới hiểu.
  final String message;

  /// Dòng đậm phía trên [message]. `null` = chỉ có một đoạn.
  final String? title;

  /// Thứ đứng ở mép phải: giờ nhận, hoặc một `StatusChip` hành động.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final accent = tone.foreground;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.card,
        vertical: AppGap.lg,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.cardAll,
        border: Border.all(color: tone.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SoloIcon(icon, label: null, size: SoloIcon.sm, color: accent),
              const SizedBox(width: AppGap.row),
              Expanded(
                child: title != null
                    ? Text(
                        title!,
                        style: AppText.bodyStrong.copyWith(color: accent),
                      )
                    : Text(
                        message,
                        style: AppText.sub.copyWith(color: tone.onSoft),
                      ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppGap.row),
                trailing!,
              ],
            ],
          ),
          if (title != null) ...[
            const SizedBox(height: AppGap.xs),
            Text(message, style: AppText.sub.copyWith(color: tone.onSoft)),
          ],
        ],
      ),
    );
  }
}
