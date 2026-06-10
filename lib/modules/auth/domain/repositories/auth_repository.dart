import 'package:solodesk_mobile/modules/auth/domain/entities/auth_token.dart';

abstract interface class AuthRepository {
  Future<AuthToken> login({required String email, required String password});

  Future<AuthToken> loginWithGoogle({required String idToken});

  Future<AuthToken> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> logout();

  Future<AuthToken> refreshToken(String refreshToken);

  Future<void> requestPasswordReset(String email);
}
