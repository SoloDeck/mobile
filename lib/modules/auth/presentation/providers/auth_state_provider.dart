import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';

part 'auth_state_provider.g.dart';

@Riverpod(keepAlive: true)
Future<bool> isAuthenticated(Ref ref) async {
  final tokenManager = ref.read(tokenManagerProvider);
  final token = await tokenManager.getAccessToken();
  return token != null;
}
