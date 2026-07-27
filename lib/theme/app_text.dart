import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';

/// Ba họ chữ của bản phác thảo, bundle trong `assets/fonts/`.
///
/// **KHÔNG** dùng package `google_fonts` (AGENTS.md quy tắc 6) — app phải chạy
/// ngoại tuyến ngay lần mở đầu tiên.
abstract final class AppFontFamily {
  /// Tiêu đề màn hình. Có trục `wdth`, bản phác thảo đặt 90–96.
  static const String display = 'Bricolage Grotesque';

  /// Chữ thân bài. Bộ chữ do người Việt thiết kế, dấu không đè dòng.
  static const String body = 'Be Vietnam Pro';

  /// Số tiền, mã hợp đồng, ngày — chữ số đều cột.
  static const String mono = 'IBM Plex Mono';
}

/// Thang chữ lấy nguyên từ `design/solodesk-mobile-ui.html`.
///
/// **Dùng khi:** đặt bất kỳ `TextStyle` nào trong `lib/ui/` hoặc `lib/features/`.
///
/// **KHÔNG dùng khi:** cần một cỡ chữ không có ở đây. Đừng `copyWith(fontSize:)`
/// một con số tự nghĩ ra — tra lại bản phác thảo, nếu đúng là cỡ mới thì thêm
/// vào đây để màn khác dùng lại được.
///
/// Cỡ nhỏ nhất là 10pt cho [label] và [stamp] — hai kiểu chữ in hoa giãn cách,
/// đọc được ở cỡ đó. Chữ thường không bao giờ nhỏ hơn 11.5pt.
abstract final class AppText {
  /// Số tiền và chữ số phải đều cột giữa các dòng.
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  // ─── Bricolage Grotesque — tiêu đề ────────────────────────────────

  /// Câu chào đầu màn đăng nhập. `34px/800`, MÀN 01.
  static const TextStyle hero = TextStyle(
    fontFamily: AppFontFamily.display,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: -1.02,
    color: AppColors.ink,
  );

  /// Tiêu đề màn hình trong thanh tiêu đề. `22px/700`.
  static const TextStyle title = TextStyle(
    fontFamily: AppFontFamily.display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.44,
    color: AppColors.ink,
  );

  /// Tiêu đề màn hình khi tên dài phải thu nhỏ. `17px/700`, MÀN 05, 07, 08.
  static const TextStyle titleSm = TextStyle(
    fontFamily: AppFontFamily.display,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.34,
    color: AppColors.ink,
  );

  /// Tiêu đề khối lớn giữa thân màn. `23px/800`, MÀN 07 “Lead nóng”.
  static const TextStyle display = TextStyle(
    fontFamily: AppFontFamily.display,
    fontSize: 23,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.46,
    color: AppColors.ink,
  );

  // ─── Be Vietnam Pro — thân bài ────────────────────────────────────

  /// Chữ nền của khung máy. `14px`.
  static const TextStyle body = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.ink,
  );

  /// Tên khách, tên việc — dòng đậm đứng đầu một thẻ. `13.5px/600`.
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.ink,
  );

  /// Dòng đậm cỡ lớn hơn, dùng ở thẻ chính của màn. `15px/600`, MÀN 05.
  static const TextStyle bodyStrongLg = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.ink,
  );

  /// Đoạn giải thích dưới một dòng đậm. `12.5px`, màu chữ phụ.
  static const TextStyle sub = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.ink2,
  );

  /// Dòng nhỏ đứng trên tiêu đề màn: ngày tháng, tên nhóm. `11px`.
  static const TextStyle overline = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.ink3,
  );

  /// Chú thích mờ: thời gian, dung lượng, ghi chú phụ. `11.5px`.
  static const TextStyle mut = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.ink3,
  );

  /// Liên kết nhỏ ở mép phải một nhãn mục: “Chi tiết”, “Tất cả”, “Thử lại”.
  /// `11.5px/600`, màu tím vì đây là lối đi tiếp chứ không phải hành động chính.
  static const TextStyle link = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.ai,
  );

  /// Chữ trong chip. `11px/600`.
  static const TextStyle chip = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Chữ trong chip khi nội dung là mã hoặc tên biến. `10px`, MÀN 14.
  static const TextStyle chipMono = TextStyle(
    fontFamily: AppFontFamily.mono,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Chữ trên nút cao 46. `14px/600`.
  static const TextStyle button = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Chữ trên nút cao 38. `13px/600`.
  static const TextStyle buttonSm = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Nhãn dưới icon trong thanh tab. `10px/600`.
  static const TextStyle nav = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Chữ cái viết tắt trong avatar. `13px/700`.
  static const TextStyle avatar = TextStyle(
    fontFamily: AppFontFamily.body,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1,
    color: AppColors.surface,
  );

  // ─── IBM Plex Mono — số và nhãn ───────────────────────────────────

  /// Nhãn mục in hoa giãn cách. `10px`, `.lbl` trong bản phác thảo.
  static const TextStyle label = TextStyle(
    fontFamily: AppFontFamily.mono,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 1.4,
    color: AppColors.ink3,
  );

  /// Con dấu nghiêng “Quá hạn / Đã thu / Bản nháp”. `10px`, in hoa.
  static const TextStyle stamp = TextStyle(
    fontFamily: AppFontFamily.mono,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 1.3,
  );

  /// Số chạy trong một dòng chữ. `12.5px`, chữ số đều cột.
  static const TextStyle num = TextStyle(
    fontFamily: AppFontFamily.mono,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
    fontFeatures: _tabular,
    color: AppColors.ink,
  );

  /// Số chạy bên trong một dòng chú thích mờ. `11.5px` — cùng cỡ với [mut] để
  /// không phá nhịp dòng, chỉ khác họ chữ và độ đậm.
  static const TextStyle numSm = TextStyle(
    fontFamily: AppFontFamily.mono,
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.23,
    fontFeatures: _tabular,
    color: AppColors.ink,
  );

  /// Số nổi bật trong một thẻ. `17px`.
  static const TextStyle numMd = TextStyle(
    fontFamily: AppFontFamily.mono,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.34,
    fontFeatures: _tabular,
    color: AppColors.ink,
  );

  /// Số lớn của một khối chỉ số. `21px`, MÀN 11.
  static const TextStyle numLg = TextStyle(
    fontFamily: AppFontFamily.mono,
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.42,
    fontFeatures: _tabular,
    color: AppColors.ink,
  );

  /// Con số chính của cả màn hình. `32px`, MÀN 02, 11.
  static const TextStyle numHero = TextStyle(
    fontFamily: AppFontFamily.mono,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.64,
    fontFeatures: _tabular,
    color: AppColors.ink,
  );
}
