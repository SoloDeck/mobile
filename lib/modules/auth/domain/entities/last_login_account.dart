import 'package:freezed_annotation/freezed_annotation.dart';

part 'last_login_account.freezed.dart';

/// Tài khoản đã đăng nhập thành công gần nhất **trên chính máy này**.
///
/// Không phải phiên đang mở: nó vẫn còn sau khi đăng xuất, vì đó chính là mục
/// đích — MÀN 01 hiện lại tên chủ máy để đăng nhập lại chỉ bằng một chạm.
/// Chỉ giữ đúng những gì cần vẽ tấm thẻ đó, không giữ token hay quyền.
@freezed
abstract class LastLoginAccount with _$LastLoginAccount {
  const factory LastLoginAccount({
    required String fullName,
    required String email,
  }) = _LastLoginAccount;

  const LastLoginAccount._();

  /// Chữ cái viết tắt cho `Avatar.initials` — tối đa hai ký tự, viết hoa.
  /// Lấy chữ đầu của hai từ đầu tiên trong tên; tên chỉ một từ thì lấy hai ký
  /// tự đầu; không tách được từ nào thì rơi về ký tự đầu của email.
  String get initials {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      final trimmed = email.trim();
      return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
    }
    if (words.length == 1) {
      final word = words.first;
      return (word.length > 2 ? word.substring(0, 2) : word).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
