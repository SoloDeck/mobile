# ADR-002: Riverpod for State Management

**Status:** Accepted  
**Date:** 2026-06-04

## Context

The app needs state management that:
- Supports async data fetching with loading/error/data states.
- Enables dependency injection for testability.
- Scales across 9 feature modules without a central state store.
- Works well with code generation to reduce boilerplate.

## Decision

Use `flutter_riverpod` with `riverpod_annotation` (codegen via `@riverpod`).

All providers use the generated `@riverpod` annotation. State classes extend `AsyncNotifier<T>` or `Notifier<T>`.

## Consequences

**Positive:**
- `AsyncValue<T>` built-in handles loading/error/data — no custom state wrappers.
- Providers are compile-time safe and auto-disposed.
- Dependency injection is trivial: `ref.read(someProvider)`.
- Excellent DevTools support.

**Negative:**
- Requires `build_runner` codegen — extra CI step.
- Steeper learning curve than `setState`.

## Forbidden Alternatives

- `Provider` package — superseded by Riverpod.
- `Bloc` — overly verbose for this scale.
- `GetX` — couples routing, DI, and state; not composable.
- `MobX` — reactive annotations conflict with Freezed codegen.
