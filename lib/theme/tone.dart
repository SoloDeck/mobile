import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';

/// Ngữ nghĩa màu của SoloDesk, không phải sắc thái trang trí.
///
/// **Dùng khi:** cần tô màu một chip, một viền trái, một nền cảnh báo — tức là
/// mọi chỗ mà màu đang *nói một điều gì đó* với người dùng.
///
/// **KHÔNG dùng khi:** chỉ muốn một màu đẹp. Gọi thẳng [AppColors] cũng không
/// phải cách đúng — nếu cần một màu không nằm trong bảng này thì đó là dấu hiệu
/// thiếu token, thêm vào `design/solodesk-mobile-ui.html` rồi chạy lại
/// `tools/sync_tokens.py`.
///
/// Quy ước cứng (AGENTS.md quy tắc 2), phá là hỏng quy ước thị giác cả app:
/// - [money] hồng — chỉ dùng cho tiền: doanh thu, công nợ, thanh toán.
/// - [ai] tím — chỉ dùng cho nội dung máy sinh đang chờ người duyệt.
/// - [ok] ngọc — đã thu, đã xong.
/// - [warn] hổ phách — sắp đến hạn.
/// - [neutral] trung tính — mọi thứ còn lại.
/// - [solid] nền mực đặc — chỉ cho mục *đang được chọn* trong một dải lọc.
enum Tone { neutral, money, ai, ok, warn, solid }

/// Bảng tra màu của [Tone]. Bốn mặt của một tone, dùng đúng chỗ:
/// [background] nền, [foreground] chữ trên nền đó, [border] viền, [accent] màu
/// đặc để vẽ vạch/icon, [onSoft] chữ khi cần độ tương phản cao hơn [foreground].
extension ToneColors on Tone {
  /// Nền của chip, thẻ cảnh báo, ô trạng thái.
  Color get background => switch (this) {
    Tone.neutral => AppColors.paper,
    Tone.money => AppColors.momoSoft,
    Tone.ai => AppColors.aiSoft,
    Tone.ok => AppColors.jadeSoft,
    Tone.warn => AppColors.amberSoft,
    Tone.solid => AppColors.ink,
  };

  /// Màu chữ và icon đặt trên [background].
  Color get foreground => switch (this) {
    Tone.neutral => AppColors.ink2,
    Tone.money => AppColors.momo,
    Tone.ai => AppColors.ai,
    Tone.ok => AppColors.jade,
    Tone.warn => AppColors.amber,
    Tone.solid => AppColors.surface,
  };

  /// Viền 1px bao quanh [background].
  Color get border => switch (this) {
    Tone.neutral => AppColors.line,
    Tone.money => AppColors.momoLine,
    Tone.ai => AppColors.aiLine,
    Tone.ok => AppColors.jadeLine,
    Tone.warn => AppColors.amberLine,
    Tone.solid => AppColors.ink,
  };

  /// Màu đặc — vạch viền trái, thanh tiến độ, icon đứng một mình trên nền giấy.
  Color get accent => switch (this) {
    Tone.neutral => AppColors.ink3,
    Tone.money => AppColors.momo,
    Tone.ai => AppColors.ai,
    Tone.ok => AppColors.jade,
    Tone.warn => AppColors.amber,
    Tone.solid => AppColors.ink,
  };

  /// Chữ đậm hơn [foreground], dùng cho đoạn văn dài đặt trên [background].
  ///
  /// Hồng và hổ phách nguyên bản không đủ tương phản với chữ 12.5px trên nền
  /// soft, nên bản phác thảo dùng riêng hai màu đậm cho hai tone này.
  Color get onSoft => switch (this) {
    Tone.money => AppColors.momoDeep,
    Tone.warn => AppColors.amberDeep,
    _ => foreground,
  };
}
