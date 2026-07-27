import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';

/// Sáu giai đoạn của một thương vụ, vẽ thành một dải vạch ngang.
///
/// Đây là cách bản phác thảo giữ *ngôn ngữ sáu giai đoạn* của bản web mà không
/// cần sáu cột Kanban: người dùng vẫn thấy đủ sáu bước, chỉ khác là đọc theo
/// chiều ngang.
///
/// **Dùng khi:** cần cho thấy hình dáng của cả pipeline (MÀN 04) hoặc vị trí của
/// một deal trong sáu bước (MÀN 05).
///
/// **KHÔNG dùng khi:**
/// - Muốn thể hiện phần trăm của một đại lượng liên tục — dùng `ProgressBar`.
/// - Muốn người dùng **kéo** deal từ đoạn này sang đoạn khác. Quy tắc 4: đổi
///   giai đoạn bằng menu chọn. Dải này chỉ để đọc, không nhận thao tác.
///
/// Hai dạng, đừng trộn: [StageBar.proportional] cho thấy *bao nhiêu deal* đang
/// nằm ở mỗi giai đoạn, [StageBar.steps] cho thấy *một deal* đã đi tới bước mấy.
class StageBar extends StatelessWidget {
  /// Bề rộng mỗi đoạn tỉ lệ với số deal đang đứng ở giai đoạn đó. MÀN 04.
  ///
  /// Liếc một cái là biết deal đang dồn ở đâu.
  const StageBar.proportional({
    super.key,
    required this.weights,
    this.height = 3,
    this.gap = 3,
  }) : filledSteps = null;

  /// Sáu đoạn đều nhau, tô đầy tới bước hiện tại. MÀN 05.
  const StageBar.steps({
    super.key,
    required int this.filledSteps,
    this.height = 5,
    this.gap = 0,
  }) : weights = null;

  /// Sáu màu giai đoạn, đúng thứ tự `--stage-1` … `--stage-6`.
  static const List<Color> stageColors = [
    AppColors.stage1,
    AppColors.stage2,
    AppColors.stage3,
    AppColors.stage4,
    AppColors.stage5,
    AppColors.stage6,
  ];

  static const int stageCount = 6;

  /// Số deal ở mỗi giai đoạn. Phải có đúng [stageCount] phần tử.
  final List<int>? weights;

  /// Số bước đã hoàn thành, 0–[stageCount].
  final int? filledSteps;

  final double height;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        // Không stretch thì `DecoratedBox` rỗng co về chiều cao 0 và cả dải
        // biến mất, dù hộp ngoài vẫn đúng chiều cao.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stageCount; i++) ...[
            if (i > 0 && gap > 0) SizedBox(width: gap),
            Expanded(flex: _flexOf(i), child: _segment(i)),
          ],
        ],
      ),
    );
  }

  /// Đoạn rỗng vẫn phải chiếm chỗ tối thiểu, nếu không dải sẽ mất hẳn một giai
  /// đoạn và người dùng tưởng pipeline chỉ có năm bước.
  int _flexOf(int i) {
    if (weights == null) return 1;
    final weight = weights![i];
    return weight <= 0 ? 1 : weight;
  }

  Widget _segment(int i) {
    final Color color;
    if (weights != null) {
      color = stageColors[i];
    } else {
      color = i < filledSteps! ? AppColors.stage5 : AppColors.line;
    }

    // Dạng steps không có khe hở nên chỉ bo hai đầu ngoài cùng của cả dải.
    final BorderRadius radius;
    if (gap > 0) {
      radius = AppRadius.pillAll;
    } else if (i == 0) {
      radius = const BorderRadius.horizontal(
        left: Radius.circular(AppRadius.pill),
      );
    } else if (i == stageCount - 1) {
      radius = const BorderRadius.horizontal(
        right: Radius.circular(AppRadius.pill),
      );
    } else {
      radius = BorderRadius.zero;
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: radius),
    );
  }
}
