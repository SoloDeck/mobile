import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository, this._tokenManager);

  final AuthRepository _repository;
  final TokenManager _tokenManager;

  Future<void> call({required String email, required String password}) async {
    final token = await _repository.login(email: email, password: password);
    await _tokenManager.saveTokens(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
    );
  }
}
