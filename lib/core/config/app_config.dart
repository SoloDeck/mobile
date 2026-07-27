import 'package:envied/envied.dart';

part 'app_config.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class AppConfig {
  @EnviedField(varName: 'API_BASE_URL')
  static final String _apiBaseUrl = _AppConfig._apiBaseUrl;

  static String get apiBaseUrl {
    final base = _apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    if (RegExp(r'/api/v\d+$').hasMatch(base)) return base;
    return '$base/api/v1';
  }

  @EnviedField(varName: 'APP_ENV', defaultValue: 'development')
  static final String appEnv = _AppConfig.appEnv;

  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID', defaultValue: '')
  static final String googleWebClientId = _AppConfig.googleWebClientId;

  @EnviedField(varName: 'GOOGLE_IOS_CLIENT_ID', defaultValue: '')
  static final String googleIosClientId = _AppConfig.googleIosClientId;

  /// Diagnostics only — never pass this to the Google Sign-In SDK.
  /// Credential Manager's `serverClientId` must be [googleWebClientId]; the
  /// Android client only has to exist in Cloud Console with the package name
  /// and signing SHA-1 so Play services can attest the app.
  @EnviedField(varName: 'GOOGLE_ANDROID_CLIENT_ID', defaultValue: '')
  static final String googleAndroidClientId = _AppConfig.googleAndroidClientId;

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
  static bool get isGoogleSignInConfigured => googleWebClientId.isNotEmpty;
}
