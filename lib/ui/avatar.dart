import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_radius.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/solo_icons.dart';

/// Ô vuông bo góc đại diện cho một người hoặc một việc, `.av` trong bản phác thảo.
///
/// **Dùng khi:** cần nhận diện nhanh một khách hàng, một công ty, hoặc loại của
/// một việc trong danh sách.
///
/// **KHÔNG dùng khi:**
/// - Muốn một ô icon bấm được — dùng `IconButtonBox`.
/// - Có ảnh đại diện thật. Bản phác thảo cố ý chỉ dùng chữ cái viết tắt: khách
///   của freelancer Việt phần lớn là công ty, không có ảnh, và chữ cái đọc nhanh
///   hơn một ảnh mờ.
///
/// ## Màu vẫn mang nghĩa
///
/// [tone] không phải màu ngẫu nhiên gán cho từng người. Trong bản phác thảo màu
/// avatar bám theo *trạng thái của dòng đó*: hồng khi liên quan tiền phải đòi,
/// tím khi là nội dung AI, ngọc khi là lead mới hoặc đã xong, hổ phách khi sắp
/// đến hạn, xám khi deal đã nguội. Chọn tone theo dòng, đừng chọn theo tên người.
class Avatar extends StatelessWidget {
  const Avatar.initials(
    String this.initials, {
    super.key,
    this.tone = Tone.solid,
    this.size = sm,
    this.radius,
  }) : icon = null;

  const Avatar.icon(
    SoloIconData this.icon, {
    super.key,
    this.tone = Tone.solid,
    this.size = sm,
    this.radius,
  }) : initials = null;

  /// Cỡ trong danh sách. MÀN 02, 04, 10, 12, 14, 15.
  static const double sm = 36;

  /// Cỡ ở thẻ khách hàng đầu màn chi tiết. MÀN 05.
  static const double md = 44;

  /// Cỡ logo ở màn đăng nhập. MÀN 01.
  static const double lg = 56;

  /// Chữ cái viết tắt, thường 2 ký tự: “HL”, “MA”, “TN”.
  final String? initials;

  /// Icon thay cho chữ cái, khi avatar đại diện một *loại việc* chứ không phải
  /// một người — tia AI ở MÀN 02, tờ tài liệu ở MÀN 14.
  final SoloIconData? icon;

  final Tone tone;
  final double size;

  /// Bo góc. Mặc định suy ra từ [size] theo đúng ba cỡ của bản phác thảo.
  final double? radius;

  /// `linear-gradient(140deg, …)` của CSS quy về hai đầu của một ô vuông.
  static const double _gradientAngleDeg = 140;

  static final Alignment _gradientBegin = _alignmentFor(
    _gradientAngleDeg + 180,
  );
  static final Alignment _gradientEnd = _alignmentFor(_gradientAngleDeg);

  static Alignment _alignmentFor(double degrees) {
    final radians = degrees * math.pi / 180;
    return Alignment(math.sin(radians), -math.cos(radians));
  }

  double get _radius =>
      radius ??
      switch (size) {
        lg => 18,
        md => 14,
        _ => AppRadius.avatar,
      };

  TextStyle get _textStyle => switch (size) {
    lg => AppText.avatar.copyWith(
      fontFamily: AppFontFamily.display,
      fontSize: 22,
      fontWeight: FontWeight.w800,
    ),
    md => AppText.avatar.copyWith(fontSize: 15),
    _ => AppText.avatar,
  };

  /// Nền: chuyển sắc cho bốn tone có nghĩa, màu đặc cho hai tone còn lại.
  Decoration get _decoration {
    final radius = BorderRadius.circular(_radius);

    final pair = switch (tone) {
      Tone.money => (AppColors.momo, AppColors.avP2),
      Tone.ai => (AppColors.ai, AppColors.avV2),
      Tone.ok => (AppColors.jade, AppColors.avJ2),
      Tone.warn => (AppColors.amber, AppColors.avA2),
      Tone.solid => null,
      Tone.neutral => null,
    };

    if (pair == null) {
      return BoxDecoration(
        color: tone == Tone.solid ? AppColors.ink : AppColors.ink3,
        borderRadius: radius,
      );
    }

    return BoxDecoration(
      gradient: LinearGradient(
        colors: [pair.$1, pair.$2],
        begin: _gradientBegin,
        end: _gradientEnd,
      ),
      borderRadius: radius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: _decoration,
      alignment: Alignment.center,
      child: icon != null
          ? SoloIcon(
              icon!,
              label: null,
              size: size * 0.44,
              color: AppColors.surface,
            )
          : Text(initials!, style: _textStyle),
    );
  }
}
