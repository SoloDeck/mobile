import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Nút icon vuông, `.iconbtn` trong bản phác thảo.
///
/// **Dùng khi:** một hành động chỉ cần icon — quay lại, chuông thông báo, tìm
/// kiếm, menu ba chấm. Gần như luôn nằm trong `SoloAppBar`.
///
/// **KHÔNG dùng khi:**
/// - Hành động là việc chính của màn hình. Bản phác thảo luôn đặt việc chính
///   thành nút chữ ở 1/3 dưới màn — một icon 20pt ở góc trên không phải chỗ cho
///   “Duyệt và gửi”.
/// - Chỉ muốn hiển thị một icon không bấm được — dùng thẳng `SoloIcon`.
/// - Cần nút nổi tròn ở đáy màn (MÀN 09) — đó là hình dáng khác, dựng riêng.
///
/// ## Vùng chạm khác kích thước thị giác
///
/// Bản phác thảo vẽ ô 38 × 38, còn quy tắc tiếp cận đòi vùng chạm tối thiểu
/// 44 × 44. Widget này giữ cả hai: phần vẽ ra đúng [visualSize], còn hộp bố cục
/// là [tapTarget]. Nghĩa là nó chiếm rộng hơn hình vẽ [overhang] mỗi bên — chỗ
/// nào cần mép icon thẳng hàng với lề nội dung thì trừ đi [overhang], như
/// `SoloAppBar` đang làm.
class IconButtonBox extends StatelessWidget {
  const IconButtonBox(
    this.icon, {
    super.key,
    required this.label,
    this.onTap,
    this.ghost = false,
    this.tone,
    this.showDot = false,
    this.visualSize = defaultVisualSize,
    this.iconColor,
  });

  /// Cạnh ô vẽ ra, `.iconbtn` = 38.
  static const double defaultVisualSize = 38;

  /// Cạnh vùng chạm tối thiểu theo quy tắc tiếp cận.
  static const double tapTarget = 44;

  /// Phần hộp bố cục thò ra mỗi bên so với hình vẽ, ở cỡ mặc định.
  static const double overhang = (tapTarget - defaultVisualSize) / 2;

  final SoloIconData icon;

  /// Nhãn tiếng Việt cho trình đọc màn hình. Bắt buộc — đây là một nút, người
  /// dùng trình đọc màn hình không có gì khác để biết nó làm gì.
  final String label;

  final VoidCallback? onTap;

  /// `.iconbtn.ghost` — không nền, không viền. Dùng cho nút quay lại.
  final bool ghost;

  /// Tô nền theo ngữ nghĩa, ví dụ nút nhắn Zalo màu ngọc ở MÀN 05.
  /// `null` = nền trắng viền xám như mặc định.
  final Tone? tone;

  /// Chấm báo có việc mới, `.dot` — hồng, viền trắng, góc trên phải.
  final bool showDot;

  /// Đổi cạnh ô vẽ. MÀN 05 dùng 34 cho nút phụ nằm trong thẻ.
  final double visualSize;

  /// Ép màu icon. Mặc định lấy theo [tone], hoặc màu mực nếu không có tone.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? (tone?.foreground ?? AppColors.ink);

    final box = Container(
      width: visualSize,
      height: visualSize,
      decoration: BoxDecoration(
        color: ghost
            ? Colors.transparent
            : (tone?.background ?? AppColors.surface),
        borderRadius: BorderRadius.circular(AppRadius.iconButton),
        border: Border.all(
          color: ghost ? Colors.transparent : (tone?.border ?? AppColors.line),
        ),
      ),
      child: Center(
        child: SoloIcon(icon, label: null, color: resolvedIconColor),
      ),
    );

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: visualSize < tapTarget ? tapTarget : visualSize,
          height: visualSize < tapTarget ? tapTarget : visualSize,
          child: Center(
            child: showDot
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      box,
                      const Positioned(top: 7, right: 8, child: _Dot()),
                    ],
                  )
                : box,
          ),
        ),
      ),
    );
  }
}

/// Chấm báo việc mới. Hồng vì thông báo đáng quan tâm nhất luôn là chuyện tiền.
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.momo,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
    );
  }
}
