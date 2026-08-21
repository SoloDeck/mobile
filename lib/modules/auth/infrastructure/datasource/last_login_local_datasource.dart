import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/storage/secure_storage.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/last_login_account.dart';

part 'last_login_local_datasource.g.dart';

/// Lưu tên + email của lần đăng nhập thành công gần nhất trên máy này.
///
/// Nằm cùng `SecureStorage` với token vì đây cũng là dữ liệu cá nhân, nhưng
/// **cố ý không** bị `TokenManager.clearTokens()` xoá: đăng xuất xong người
/// dùng vẫn phải thấy lại tên mình ở MÀN 01. Chỉ [clear] mới xoá — dành cho
/// lúc muốn máy quên hẳn tài khoản.
class LastLoginLocalDatasource {
  const LastLoginLocalDatasource(this._storage);

  final SecureStorage _storage;

  static const _nameKey = 'last_login_full_name';
  static const _emailKey = 'last_login_email';

  /// `null` khi máy này chưa từng đăng nhập thành công lần nào — MÀN 01 ẩn
  /// hẳn thẻ "Lần đăng nhập gần nhất" trong trường hợp đó.
  Future<LastLoginAccount?> read() async {
    final email = await _storage.read(_emailKey);
    if (email == null || email.isEmpty) return null;
    final fullName = await _storage.read(_nameKey);
    return LastLoginAccount(
      // Tên có thể rỗng nếu hồ sơ chưa điền: email luôn có, nên nó là chỗ dựa.
      fullName: (fullName == null || fullName.isEmpty) ? email : fullName,
      email: email,
    );
  }

  Future<void> save({required String fullName, required String email}) async {
    await _storage.write(_emailKey, email);
    await _storage.write(_nameKey, fullName);
  }

  Future<void> clear() async {
    await _storage.delete(_emailKey);
    await _storage.delete(_nameKey);
  }
}

@Riverpod(keepAlive: true)
LastLoginLocalDatasource lastLoginLocalDatasource(Ref ref) {
  return LastLoginLocalDatasource(ref.read(secureStorageProvider));
}
