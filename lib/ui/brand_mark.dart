import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/ui/avatar.dart';

/// Logo SoloDesk — cùng một file vector với favicon của bản web
/// (`web/public/favicon.svg`), nên hai nền tảng không bao giờ lệch hình.
///
/// **Dùng khi:** một màn ngoài phiên đăng nhập cần nhận diện thương hiệu ở đầu
/// màn — đăng nhập bằng email, đăng ký, quên mật khẩu.
///
/// **KHÔNG dùng khi:**
/// - Cần đại diện cho một *người* hay một *việc* — đó là `Avatar`.
/// - Muốn một icon trong dòng chữ — bộ icon của bản phác thảo là `SoloIcons`,
///   logo không phải icon và không đổi màu theo ngữ cảnh.
///
/// Bo góc và cỡ mặc định bám theo `Avatar.lg` (56, bo 18) để logo đứng đúng ô
/// mà bản phác thảo dành cho khối nhận diện ở MÀN 01.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = Avatar.lg, this.label = 'SoloDesk'});

  final double size;

  /// Nhãn tiếng Việt cho trình đọc màn hình. Logo luôn đứng một mình nên đây là
  /// thứ duy nhất nói cho người dùng biết họ đang ở app nào.
  final String label;

  /// Tỉ lệ bo góc trên cạnh, lấy từ `Avatar.lg`: 18 / 56.
  static const double _radiusRatio = 18 / Avatar.lg;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * _radiusRatio),
        child: SvgPicture.asset(
          'assets/brand/solodesk-logo.svg',
          width: size,
          height: size,
          // File vector được trace từ ảnh nên nó tự mang màu; đừng đặt
          // `colorFilter` — tô một màu duy nhất sẽ biến logo thành vệt đặc.
          fit: BoxFit.cover,
          // Ô vuông màu giấy trong lúc giải mã file, để khối nhận diện không
          // nhảy chỗ khi logo hiện ra.
          placeholderBuilder: (_) => SizedBox.square(
            dimension: size,
            child: const ColoredBox(color: AppColors.paper),
          ),
        ),
      ),
    );
  }
}
