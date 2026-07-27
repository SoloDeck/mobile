import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solodesk_mobile/core/app/app.dart';
import 'package:solodesk_mobile/core/config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    print('=== ENV CONFIG ===');

    print('API URL: ${AppConfig.apiBaseUrl}');
    print('App Environment: ${AppConfig.appEnv}');
    print('Google Web Client ID: ${AppConfig.googleWebClientId}');
    print('Google Android Client ID: ${AppConfig.googleAndroidClientId}');
    print('Google iOS Client ID: ${AppConfig.googleIosClientId}');
    print('==================');
  }
  runApp(const ProviderScope(child: SoloDeskApp()));
}
