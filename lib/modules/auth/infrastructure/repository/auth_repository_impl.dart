import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/network/api_client.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/auth_token.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/auth_user.dart';
import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/datasource/auth_remote_datasource.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/dto/login_request_dto.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/mapper/auth_mapper.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenManager);

  final AuthRemoteDatasource _remote;
  final TokenManager _tokenManager;

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async {
    final dto = await _remote.login(
      LoginRequestDto(email: email, password: password),
    );
    return dto.toDomain();
  }

  @override
  Future<AuthToken> loginWithGoogle({required String idToken}) async {
    final dto = await _remote.loginWithGoogle(idToken);
    return dto.toDomain();
  }

  @override
  Future<AuthToken> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final dto = await _remote.register(
      email: email,
      password: password,
      fullName: fullName,
    );
    return dto.toDomain();
  }

  @override
  Future<void> logout() => _remote.logout();

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    final dto = await _remote.refreshToken(refreshToken);
    final token = dto.toDomain();
    await _tokenManager.saveTokens(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
    );
    return token;
  }

  @override
  Future<void> requestPasswordReset(String email) =>
      _remote.requestPasswordReset(email);

  @override
  Future<void> confirmPasswordReset(String token, String newPassword) =>
      _remote.confirmPasswordReset(token, newPassword);

  @override
  Future<AuthUser> fetchMe() async {
    final dto = await _remote.fetchMe();
    return dto.toDomain();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final client = ref.read(apiClientProvider);
  final tokenManager = ref.read(tokenManagerProvider);
  return AuthRepositoryImpl(AuthRemoteDatasource(client), tokenManager);
}
