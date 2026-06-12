import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/auth_user.dart';

part 'auth_state_provider.g.dart';

@Riverpod(keepAlive: true)
Future<bool> isAuthenticated(Ref ref) async {
  final tokenManager = ref.read(tokenManagerProvider);
  final token = await tokenManager.getAccessToken();
  return token != null;
}

/// Holds the currently logged-in user. `null` when signed out.
@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  @override
  AuthUser? build() => null;

  void set(AuthUser? user) => state = user;

  void clear() => state = null;
}
