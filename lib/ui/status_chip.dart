import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Nhãn trạng thái nhỏ, `.chip` trong bản phác thảo.
///
/// **Dùng khi:** cần gắn một trạng thái ngắn lên thẻ hoặc dòng — “Quá hạn 6
/// ngày”, “Chờ AI”, “Đã thu”. Màu do [tone] quyết định và màu ở đây *mang nghĩa*:
/// hồng là tiền, tím là nội dung AI chờ duyệt, ngọc là xong, hổ phách là sắp đến
/// hạn.
///
/// **KHÔNG dùng khi:**
/// - Nó là nút bấm thật sự — chip không có vùng chạm 44pt. Hành động dùng
///   `FilledButton`/`OutlinedButton`, hoặc `IconButtonBox` nếu chỉ có icon.
/// - Muốn nhấn mạnh một con số tiền — dùng `Money`, chip là nhãn chứ không phải
///   chỗ đặt số chính.
/// - Cần chip trên nền tối như MÀN 06. Bản phác thảo dùng nền và chữ trong suốt
///   riêng ở đó; đó là chuyện của một màn, dựng private trong màn đó. Nếu có màn
///   thứ hai cần nền tối thì mới nâng biến thể ấy lên đây.
///
/// Trạng thái không được truyền tải chỉ bằng màu, nên [label] luôn phải nói đủ
/// nghĩa: “Quá hạn”, không phải một chip hồng trống.
class StatusChip extends StatelessWidget {
  const StatusChip(
    this.label, {
    super.key,
    this.tone = Tone.neutral,
    this.icon,
    this.trailingIcon,
    this.mono = false,
  });

  /// Chữ hiển thị. Viết tiếng Việt, giọng như bản phác thảo.
  final String label;

  /// Ngữ nghĩa màu. Mặc định trung tính.
  final Tone tone;

  /// Icon nhỏ đứng trước chữ, ví dụ tia AI trong chip “AI soạn”.
  final SoloIconData? icon;

  /// Icon nhỏ đứng sau chữ, ví dụ mũi chevron trong chip chọn năm ở MÀN 11.
  final SoloIconData? trailingIcon;

  /// Đổi sang chữ mono — dùng cho tên biến `{{client_name}}` ở MÀN 14.
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final foreground = tone.foreground;
    final textStyle = (mono ? AppText.chipMono : AppText.chip).copyWith(
      color: foreground,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppGap.md,
        vertical: AppGap.chipVertical,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.chipAll,
        border: Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SoloIcon(icon!, label: null, size: SoloIcon.xs, color: foreground),
            const SizedBox(width: AppGap.xs),
          ],
          Text(label, style: textStyle, softWrap: false),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppGap.xs),
            SoloIcon(
              trailingIcon!,
              label: null,
              size: SoloIcon.xs,
              color: foreground,
            ),
          ],
        ],
      ),
    );
  }
}
