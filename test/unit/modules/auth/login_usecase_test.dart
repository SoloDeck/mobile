import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/login_usecase.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/auth_token.dart';
import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';
import 'package:solodesk_mobile/shared/errors/app_exception.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockTokenManager extends Mock implements TokenManager {}

void main() {
  late _MockAuthRepository repository;
  late _MockTokenManager tokenManager;
  late LoginUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    tokenManager = _MockTokenManager();
    useCase = LoginUseCase(repository, tokenManager);
  });

  const email = 'user@example.com';
  const password = 'Test@1234!';
  const token = AuthToken(
    accessToken: 'access',
    refreshToken: 'refresh',
    tokenType: 'bearer',
    expiresIn: 900,
  );

  group('LoginUseCase', () {
    test('saves tokens on successful login', () async {
      when(
        () => repository.login(email: email, password: password),
      ).thenAnswer((_) async => token);
      when(
        () => tokenManager.saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        ),
      ).thenAnswer((_) async {});

      await useCase(email: email, password: password);

      verify(
        () => tokenManager.saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        ),
      ).called(1);
    });

    test('propagates AuthException on invalid credentials', () async {
      when(
        () => repository.login(email: email, password: password),
      ).thenThrow(AuthException.invalidCredentials());

      expect(
        () => useCase(email: email, password: password),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
