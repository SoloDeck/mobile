import 'package:mobile/domain/models/user.dart';

/// Interface cho repository xác thực người dùng.
///
/// Khi chuyển sang API thực, chỉ cần tạo class mới implements interface này
/// mà không cần thay đổi UI hay State layer.
abstract class AuthRepository {
  /// Đăng nhập bằng email và mật khẩu.
  Future<User> login(String email, String password);

  /// Đăng xuất.
  Future<void> logout();

  /// Lấy thông tin user hiện tại (null nếu chưa đăng nhập).
  Future<User?> getCurrentUser();

  /// Stream theo dõi trạng thái xác thực.
  Stream<User?> watchAuthState();
}
