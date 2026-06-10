# Auth Module — Mobile

## Purpose

Authenticate the freelancer and maintain their session. This module is the gateway to all protected screens.

## Responsibilities

- Email + password login
- Registration
- JWT access token storage (Flutter Secure Storage)
- Auto-refresh of access token on 401 (AuthInterceptor)
- Logout and token clearing
- Password reset flow

## Key Files

| File | Role |
|---|---|
| `domain/entities/auth_token.dart` | Freezed entity holding access + refresh tokens |
| `domain/repositories/auth_repository.dart` | Abstract interface |
| `infrastructure/repository/auth_repository_impl.dart` | Dio-backed implementation |
| `application/usecases/login_usecase.dart` | Orchestrates login + token save |
| `presentation/controllers/auth_controller.dart` | Riverpod AsyncNotifier |
| `presentation/providers/auth_state_provider.dart` | `isAuthenticated` provider |

## API Endpoints

- `POST /auth/login` — credential login
- `POST /auth/register` — new account
- `POST /auth/refresh` — token refresh (called by AuthInterceptor)
- `POST /auth/logout` — revoke refresh token
- `POST /auth/forgot-password` — request reset email

## State

```dart
// Check auth state
final isAuth = ref.watch(isAuthenticatedProvider);

// Trigger login
ref.read(authControllerProvider.notifier).login(email: ..., password: ...);
```

## Token Storage

- Access token → `flutter_secure_storage` key: `access_token`
- Refresh token → `flutter_secure_storage` key: `refresh_token`
- Never stored in SharedPreferences or Hive.
