import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solodesk_mobile/core/security/token_manager.dart';
import 'package:solodesk_mobile/modules/auth/application/usecases/login_with_google_usecase.dart';
import 'package:solodesk_mobile/modules/auth/domain/entities/auth_token.dart';
import 'package:solodesk_mobile/modules/auth/domain/repositories/auth_repository.dart';
import 'package:solodesk_mobile/modules/auth/infrastructure/datasource/google_sign_in_service.dart';

class _MockGoogleSignInService extends Mock implements GoogleSignInService {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockTokenManager extends Mock implements TokenManager {}

void main() {
  late _MockGoogleSignInService google;
  late _MockAuthRepository repository;
  late _MockTokenManager tokenManager;
  late LoginWithGoogleUseCase useCase;

  setUp(() {
    google = _MockGoogleSignInService();
    repository = _MockAuthRepository();
    tokenManager = _MockTokenManager();
    useCase = LoginWithGoogleUseCase(google, repository, tokenManager);
  });

  const token = AuthToken(
    accessToken: 'access',
    refreshToken: 'refresh',
    tokenType: 'bearer',
    expiresIn: 900,
  );

  void stubExchangeAndSave() {
    when(() => repository.loginWithGoogle(idToken: 'id-token'))
        .thenAnswer((_) async => token);
    when(
      () => tokenManager.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      ),
    ).thenAnswer((_) async {});
  }

  group('call() — interactive sign-in', () {
    test('returns false and does not exchange when the user cancels', () async {
      when(() => google.signIn()).thenAnswer((_) async => null);

      final result = await useCase();

      expect(result, isFalse);
      verifyNever(() => repository.loginWithGoogle(idToken: any(named: 'idToken')));
    });

    test('exchanges the id token and saves the session on success', () async {
      when(() => google.signIn()).thenAnswer((_) async => 'id-token');
      stubExchangeAndSave();

      final result = await useCase();

      expect(result, isTrue);
      verify(
        () => tokenManager.saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        ),
      ).called(1);
    });
  });

  group('trySilentLogin()', () {
    test('returns true without calling Google when a local session exists', () async {
      when(() => tokenManager.getAccessToken()).thenAnswer((_) async => 'existing');

      final result = await useCase.trySilentLogin();

      expect(result, isTrue);
      verifyNever(() => google.signInSilently());
    });

    test('exchanges a silent id token when no local session exists', () async {
      when(() => tokenManager.getAccessToken()).thenAnswer((_) async => null);
      when(() => google.signInSilently()).thenAnswer((_) async => 'id-token');
      stubExchangeAndSave();

      final result = await useCase.trySilentLogin();

      expect(result, isTrue);
      verify(
        () => tokenManager.saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        ),
      ).called(1);
    });

    test('returns false when there is no session and silent auth fails', () async {
      when(() => tokenManager.getAccessToken()).thenAnswer((_) async => null);
      when(() => google.signInSilently()).thenAnswer((_) async => null);

      final result = await useCase.trySilentLogin();

      expect(result, isFalse);
      verifyNever(() => repository.loginWithGoogle(idToken: any(named: 'idToken')));
    });
  });
}
