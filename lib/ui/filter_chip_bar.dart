import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_gap.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/status_chip.dart';

/// Dải chip lọc cuộn ngang — cách SoloDesk thay thế cột Kanban trên điện thoại.
///
/// **Dùng khi:** một danh sách có nhiều nhóm mà màn hình không đủ chỗ hiển thị
/// song song: sáu giai đoạn pipeline (MÀN 04), bốn trạng thái task (MÀN 09), các
/// tab con của một deal (MÀN 05), loại thông báo (MÀN 03), loại mẫu (MÀN 14),
/// giọng văn bản nhắc (MÀN 12), kỳ thanh toán gói (MÀN 13), kiểu xem file (MÀN 10).
///
/// **KHÔNG dùng khi:**
/// - Chỉ có hai lựa chọn loại trừ nhau và cả hai đều luôn nhìn thấy được — cân
///   nhắc một `SegmentedButton`, tuy bản phác thảo không dùng kiểu đó ở đâu cả.
/// - Muốn người dùng **kéo thả** giữa các nhóm. Đây là quy tắc 4 trong
///   `AGENTS.md`: Kanban trên mobile không kéo thả, vì thao tác trượt bằng ngón
///   cái không đáng tin. Đổi nhóm bằng một menu chọn rõ ràng. Đừng thêm
///   `Draggable`, `ReorderableListView`, hay bất kỳ thư viện kéo thả nào vào đây.
///
/// ## Chiều cao lớn hơn hình vẽ
///
/// Chip vẽ ra chỉ cao khoảng 24pt, dưới ngưỡng vùng chạm 44pt. Dải này tự chèn
/// đệm dọc để mỗi chip đủ [tapTarget] chiều cao, nên **cả dải cao 44** chứ không
/// phải 24. Khi đặt vào màn, trừ bớt khoảng cách trên dưới cho tương ứng.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppGap.screen),
  });

  /// Chiều cao vùng chạm tối thiểu của mỗi chip.
  static const double tapTarget = 44;

  /// Nhãn từng chip, chép nguyên văn từ bản phác thảo — gồm cả phần đếm:
  /// “Lead mới · 4”, “Đang làm · 2”.
  final List<String> labels;

  /// Vị trí đang chọn. Chip này dùng `Tone.solid`, các chip khác trung tính.
  final int selectedIndex;

  final ValueChanged<int>? onSelected;

  /// Đệm hai đầu dải. Mặc định bằng lề màn hình để chip đầu thẳng hàng với nội
  /// dung, trong khi phần cuộn vẫn chạy hết bề ngang máy.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tapTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppGap.betweenChips),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;

          return Semantics(
            button: true,
            selected: selected,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSelected == null ? null : () => onSelected!(index),
              child: Center(
                child: StatusChip(
                  labels[index],
                  tone: selected ? Tone.solid : Tone.neutral,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
