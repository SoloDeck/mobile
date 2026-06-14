import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/config/app_config.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

part 'google_sign_in_service.g.dart';

/// Thin wrapper around the google_sign_in v7 SDK.
///
/// Returns the Google **ID token**, which the backend exchanges for app tokens
/// via `POST /auth/google`.
class GoogleSignInService {
  GoogleSignInService();

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    if (!AppConfig.isGoogleSignInConfigured) {
      throw const AuthException(
        'Google Sign-In is not configured. Set GOOGLE_SERVER_CLIENT_ID in your .env.',
      );
    }
    await GoogleSignIn.instance.initialize(
      clientId: AppConfig.googleIosClientId.isNotEmpty
          ? AppConfig.googleIosClientId
          : null,
      serverClientId: AppConfig.googleServerClientId,
    );
    _initialized = true;
  }

  /// Launches the interactive Google sign-in flow and returns an ID token.
  ///
  /// Returns `null` if the user cancels. Throws [AuthException] on failure.
  Future<String?> signIn() async {
    await _ensureInitialized();

    final signIn = GoogleSignIn.instance;
    if (!signIn.supportsAuthenticate()) {
      throw const AuthException(
        'Google Sign-In is not supported on this platform.',
      );
    }

    try {
      final account = await signIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google did not return an ID token.');
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AuthException(e.description ?? 'Google Sign-In failed.');
    }
  }

  /// Attempts non-interactive (silent) authentication from a previously
  /// authorized session. Returns the ID token, or `null` when no session can be
  /// restored without showing UI (e.g. first launch or signed-out).
  Future<String?> signInSilently() async {
    await _ensureInitialized();
    try {
      final attempt = GoogleSignIn.instance.attemptLightweightAuthentication();
      final account = attempt == null ? null : await attempt;
      return account?.authentication.idToken;
    } on GoogleSignInException {
      return null;
    }
  }

  Future<void> signOut() => GoogleSignIn.instance.signOut();
}

@Riverpod(keepAlive: true)
GoogleSignInService googleSignInService(Ref ref) => GoogleSignInService();
