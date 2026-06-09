# Navigation Architecture

## Router

GoRouter configured in `lib/core/router/app_router.dart`.

Provider: `routerProvider` (Riverpod, keepAlive).

## Route Names

All route path strings are constants in `lib/core/router/route_names.dart`.

```dart
// Always use constants — never hardcode path strings.
context.go(RouteNames.dealDetail.replaceFirst(':id', deal.id));
```

## Auth Guard

`lib/core/router/route_guards.dart` — `authGuard()` function.

- Unauthenticated access to protected routes → redirect to `/login`.
- Authenticated access to auth routes → redirect to `/home`.
- Token check is async (reads from Flutter Secure Storage).

## Navigation Patterns

```dart
// Push a named route
context.go(RouteNames.clients);

// Push with path parameter
context.go('/deals/${deal.id}');

// Push preserving back stack
context.push(RouteNames.dealDetail.replaceFirst(':id', id));

// Replace current route (no back)
context.replace(RouteNames.home);
```

## Shell Route (Bottom Nav)

The main shell route wraps `home`, `clients`, `deals`, `analytics`, and `settings` in a persistent bottom navigation bar. Each tab maintains its own navigation stack.

## Deep Linking

Configure in `AndroidManifest.xml` and `Info.plist` for:
- Proposal response links: `solodesk://proposals/:id/respond`
- Invoice view links: `solodesk://invoices/:id`
