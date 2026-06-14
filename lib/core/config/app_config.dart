import 'package:envied/envied.dart';

part 'app_config.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class AppConfig {
  @EnviedField(varName: 'API_BASE_URL')
  static final String apiBaseUrl = _AppConfig.apiBaseUrl;

  @EnviedField(varName: 'APP_ENV', defaultValue: 'development')
  static final String appEnv = _AppConfig.appEnv;

  @EnviedField(varName: 'GOOGLE_SERVER_CLIENT_ID', defaultValue: '')
  static final String googleServerClientId = _AppConfig.googleServerClientId;

  @EnviedField(varName: 'GOOGLE_IOS_CLIENT_ID', defaultValue: '')
  static final String googleIosClientId = _AppConfig.googleIosClientId;

  @EnviedField(varName: 'GOOGLE_ANDROID_CLIENT_ID', defaultValue: '')
  static final String googleAndroidClientId = _AppConfig.googleAndroidClientId;

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
  static bool get isGoogleSignInConfigured => googleServerClientId.isNotEmpty;
}
