import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Thanh tab đáy màn với nút ghi nhanh ở giữa, `.tabbar` + `.fab`.
///
/// **Dùng khi:** màn hình là một trong bốn mục gốc — Hôm nay, Pipeline, Dự án,
/// Tôi. Chỉ bốn màn có thanh này: MÀN 02, 04, 11, 15.
///
/// **KHÔNG dùng khi:**
/// - Màn hình mở ra từ một mục gốc. Màn chi tiết, màn duyệt, màn nhắc thu tiền
///   đều không có thanh tab — chúng có nút quay lại, và thường có
///   `BottomActionBar` chiếm chỗ ở đáy.
/// - Muốn thêm mục thứ năm hay thứ sáu. Năm chỗ đã kín, chỗ giữa là nút ghi
///   nhanh chứ không phải một tab.
///
/// Nút ＋ ở giữa mở thẳng màn ghi nhanh bằng giọng nói, không qua menu — đó là
/// quyết định trong bản phác thảo, đừng biến nó thành nút mở danh sách lựa chọn.
class SoloNavBar extends StatelessWidget {
  const SoloNavBar({
    super.key,
    required this.index,
    this.onSelect,
    this.onQuickCapture,
    this.offline = false,
  });

  /// Chiều cao cả thanh.
  static const double height = 84;

  /// Cỡ icon trong tab, lớn hơn icon thường vì phải nhận ra khi liếc.
  static const double iconSize = 22;

  static const double _fabSize = 50;

  /// Bốn mục gốc, đúng thứ tự và đúng chữ của bản phác thảo.
  static const List<(SoloIconData, String)> destinations = [
    (SoloIcons.home, 'Hôm nay'),
    (SoloIcons.board, 'Pipeline'),
    (SoloIcons.folder, 'Dự án'),
    (SoloIcons.user, 'Tôi'),
  ];

  /// Mục đang mở, 0–3 theo [destinations].
  final int index;

  final ValueChanged<int>? onSelect;

  /// Bấm nút ＋ ở giữa.
  final VoidCallback? onQuickCapture;

  /// Mất mạng: nút ＋ chuyển xám để báo trước rằng tạo được nhưng AI phải đợi có
  /// mạng mới chạy. Các tab khác vẫn dùng bình thường — ngoại tuyến không chặn
  /// thao tác.
  final bool offline;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(
        top: AppGap.md,
        left: AppGap.lg,
        right: AppGap.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tab(0),
          _tab(1),
          Expanded(child: _fab()),
          _tab(2),
          _tab(3),
        ],
      ),
    );
  }

  Widget _tab(int slot) {
    final (icon, label) = destinations[slot];
    final selected = slot == index;
    final color = selected ? AppColors.ink : AppColors.ink3;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        // Nhãn đã nói đủ; để `Text` bên trong tự sinh node nữa thì trình đọc màn
        // hình đọc tên mục hai lần.
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSelect == null ? null : () => onSelect!(slot),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SoloIcon(icon, label: null, size: iconSize, color: color),
              const SizedBox(height: 4),
              Text(label, style: AppText.nav.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fab() {
    return Semantics(
      button: true,
      label: 'Ghi nhanh bằng giọng nói',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onQuickCapture,
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -16),
            child: Container(
              width: _fabSize,
              height: _fabSize,
              decoration: BoxDecoration(
                color: offline ? AppColors.ink3 : AppColors.ink,
                borderRadius: BorderRadius.circular(AppRadius.fab),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.72),
                    offset: const Offset(0, 10),
                    blurRadius: 22,
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: const Center(
                child: SoloIcon(
                  SoloIcons.plus,
                  label: null,
                  size: 24,
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
