import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/datasource/google_sign_in_service.dart';

class LoginWithGoogleUseCase {
  const LoginWithGoogleUseCase(
    this._googleSignIn,
    this._repository,
    this._tokenManager,
  );

  final GoogleSignInService _googleSignIn;
  final AuthRepository _repository;
  final TokenManager _tokenManager;

  /// Returns `true` on success, `false` if the user cancelled the Google flow.
  Future<bool> call() async {
    final idToken = await _googleSignIn.signIn();
    if (idToken == null) return false;

    final token = await _repository.loginWithGoogle(idToken: idToken);
    await _tokenManager.saveTokens(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
    );
    return true;
  }
}
