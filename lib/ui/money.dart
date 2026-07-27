import 'package:flutter/material.dart';
import 'package:solodesk_mobile/theme/app_colors.dart';
import 'package:solodesk_mobile/theme/app_text.dart';
import 'package:solodesk_mobile/theme/tone.dart';
import 'package:solodesk_mobile/ui/mono_text.dart';

/// Một khoản tiền chính xác, định dạng theo cách người Việt đọc.
///
/// **Dùng khi:** hiển thị một số tiền cụ thể — công nợ, giá trị hợp đồng, đợt
/// thanh toán, doanh thu đã thu.
///
/// **KHÔNG dùng khi:**
/// - Số không phải tiền — dùng `MonoText`.
/// - Tiền không chính xác: khoảng giá, ước tính có dấu `~`, số rút gọn “16,7 tr”.
///   Bản phác thảo viết những thứ đó như chữ, dùng `MonoText`.
///
/// ## Màu là nghĩa, không phải trang trí
///
/// Đừng mặc định mọi số tiền đều màu hồng. Bản phác thảo phân biệt rất rõ:
/// - [Tone.money] hồng — tiền **đang phải đòi**: công nợ, đợt quá hạn, số cần thu.
/// - [Tone.ok] ngọc — tiền **đã vào tài khoản**.
/// - [Tone.neutral] mực — số tiền chỉ để tham chiếu: giá trị hợp đồng ở MÀN 05,
///   tổng doanh thu đã thu ở MÀN 11, giá gói ở MÀN 13.
///
/// Tô hồng một con số không phải công nợ là làm hỏng quy ước “thấy hồng biết
/// đang nói tới tiền phải đòi”.
class Money extends StatelessWidget {
  const Money(this.amount, {super.key, this.tone = Tone.money, this.style});

  /// Cỡ chữ mặc định — số nằm trong một dòng thông tin.
  const Money.inline(this.amount, {super.key, this.tone = Tone.money})
    : style = AppText.num;

  /// Con số chính của cả màn hình. MÀN 02, 11.
  const Money.hero(this.amount, {super.key, this.tone = Tone.money})
    : style = AppText.numHero;

  /// Số nổi bật trong một thẻ. MÀN 05, 12.
  const Money.card(this.amount, {super.key, this.tone = Tone.money})
    : style = AppText.numMd;

  /// Số tiền theo đơn vị đồng.
  final num amount;

  /// Ngữ nghĩa của khoản tiền này. Xem phần “Màu là nghĩa” ở trên.
  final Tone tone;

  /// Ghi đè cỡ chữ. Mặc định [AppText.num].
  final TextStyle? style;

  /// Định dạng số tiền theo cách viết của người Việt: chấm ngăn nghìn, ký hiệu
  /// ₫ đứng sau, cách một khoảng trắng.
  ///
  /// Tự viết thay vì gọi `intl` để kết quả không phụ thuộc dữ liệu locale được
  /// nạp hay chưa — ảnh vàng phải giống nhau ở mọi máy.
  static String format(num amount) {
    final rounded = amount.round();
    final digits = rounded.abs().toString();
    final grouped = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write('.');
      grouped.write(digits[i]);
    }

    return '${rounded < 0 ? '-' : ''}$grouped ₫';
  }

  /// Màu chữ của số tiền.
  ///
  /// Không dùng thẳng `tone.accent`: màu trung tính của [Tone] là `ink3` — màu
  /// *mờ*, đúng cho vạch tiến độ nhưng quá nhạt cho một con số phải đọc được.
  /// Bản phác thảo để số tiền tham chiếu ở màu mực chính (MÀN 05, 11, 13).
  Color get _color => switch (tone) {
    Tone.neutral => AppColors.ink,
    _ => tone.accent,
  };

  @override
  Widget build(BuildContext context) {
    return MonoText(format(amount), style: style ?? AppText.num, color: _color);
  }
}
