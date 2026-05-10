import 'dart:async';

import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/data/mock_data/mock_data.dart';
import 'package:mobile/domain/models/user.dart';
import 'package:mobile/domain/repositories/auth_repository.dart';

/// Mock implementation của [AuthRepository].
///
/// Dùng để phát triển UI mà không cần backend thực.
/// Credentials: test@solodesk.vn / 123456
class MockAuthRepository implements AuthRepository {
  final _authController = StreamController<User?>.broadcast();

  User? _currentUser;

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(AppConstants.mockNetworkDelay);

    if (email == 'test@solodesk.vn' && password == '123456') {
      _currentUser = MockData.mockUser;
      _authController.add(_currentUser);
      return _currentUser!;
    }

    throw Exception('Email hoặc mật khẩu không chính xác.');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authController.add(null);
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Stream<User?> watchAuthState() => _authController.stream;
}
