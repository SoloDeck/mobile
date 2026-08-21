import 'dart:io';

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
        'Chưa cấu hình đăng nhập Google. Hãy đặt GOOGLE_WEB_CLIENT_ID trong file .env.',
      );
    }
    try {
      await GoogleSignIn.instance.initialize(
        clientId: Platform.isIOS && AppConfig.googleIosClientId.isNotEmpty
            ? AppConfig.googleIosClientId
            : null,
        // iOS: skip serverClientId to avoid AppAuth invalid_audience error;
        // GID SDK still returns idToken with iOS client ID as audience.
        //
        // Android: Credential Manager only accepts a **web** OAuth client ID
        // here. Passing GOOGLE_ANDROID_CLIENT_ID makes Play services reject the
        // request with "Developer console is not set up correctly"
        // (DEVELOPER_ERROR) and the account picker closes without a token.
        // The Android client ID is never handed to the SDK — it only has to
        // exist in Cloud Console carrying the package name + signing SHA-1 so
        // Google can attest the app.
        serverClientId: Platform.isIOS ? null : AppConfig.googleWebClientId,
      );
    } catch (e) {
      throw AuthException(
        'Khởi tạo đăng nhập Google thất bại: ${e.toString()}',
      );
    }
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
        'Thiết bị này không hỗ trợ đăng nhập bằng Google.',
      );
    }

    try {
      final account = await signIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Google không trả về ID token.');
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AuthException(e.description ?? 'Đăng nhập Google thất bại.');
    } catch (e) {
      throw AuthException(e.toString());
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
