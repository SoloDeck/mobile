import 'package:flutter/material.dart';

/// Bo góc lấy nguyên từ bản phác thảo.
///
/// **Dùng khi:** đặt `borderRadius` cho bất kỳ thứ gì trong `lib/ui/` và
/// `lib/features/`.
///
/// **KHÔNG dùng khi:** cần một bán kính không có ở đây — tra lại bản phác thảo
/// trước, vì bo góc trong SoloDesk đi theo *loại thành phần* chứ không theo kích
/// thước, và dùng sai bán kính là dấu hiệu dùng sai thành phần.
abstract final class AppRadius {
  /// `Card` và `SlipCard`.
  static const double card = 18;

  /// Chip trạng thái và chip lọc.
  static const double chip = 8;

  /// Nút cao 46.
  static const double button = 14;

  /// Nút cao 38.
  static const double buttonSm = 11;

  /// Avatar chữ cái.
  static const double avatar = 11;

  /// Nút icon vuông 38 × 38.
  static const double iconButton = 12;

  /// Ô lưới file bằng chứng, ô ảnh vuông.
  static const double tile = 13;

  /// Nút nổi ở giữa thanh tab.
  static const double fab = 17;

  /// Ô tick của một task.
  static const double checkbox = 6;

  /// Con dấu nghiêng.
  static const double stamp = 7;

  /// Bo tròn hoàn toàn — thanh tiến độ, chip hình viên thuốc.
  static const double pill = 99;

  /// Bán kính vết cắt răng cưa hai bên `SlipCard` (đường kính 18).
  static const double slipNotch = 9;

  static BorderRadius get cardAll => BorderRadius.circular(card);
  static BorderRadius get chipAll => BorderRadius.circular(chip);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
}
