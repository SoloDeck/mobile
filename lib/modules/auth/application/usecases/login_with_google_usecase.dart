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

    await _exchangeAndStore(idToken);
    return true;
  }

  /// Attempts to restore a session without user interaction.
  ///
  /// Returns `true` when a local session already exists or when silent Google
  /// authentication succeeds; `false` otherwise.
  Future<bool> trySilentLogin() async {
    final existing = await _tokenManager.getAccessToken();
    if (existing != null) return true;

    final idToken = await _googleSignIn.signInSilently();
    if (idToken == null) return false;

    await _exchangeAndStore(idToken);
    return true;
  }

  Future<void> _exchangeAndStore(String idToken) async {
    final token = await _repository.loginWithGoogle(idToken: idToken);
    await _tokenManager.saveTokens(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
    );
  }
}
