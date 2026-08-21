import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/last_login_account.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/datasource/last_login_local_datasource.dart';

part 'last_login_provider.g.dart';

/// Tài khoản đăng nhập gần nhất trên máy này, để MÀN 01 vẽ thẻ "Lần đăng nhập
/// gần nhất". `null` = chưa từng đăng nhập, màn ẩn thẻ đó đi.
///
/// `keepAlive` vì đọc từ keychain: giá trị không đổi trong suốt một phiên chạy,
/// đọc lại mỗi lần dựng lại màn là phí. `AuthController` gọi `invalidate` sau
/// mỗi lần đăng nhập thành công.
@Riverpod(keepAlive: true)
Future<LastLoginAccount?> lastLoginAccount(Ref ref) {
  return ref.read(lastLoginLocalDatasourceProvider).read();
}
