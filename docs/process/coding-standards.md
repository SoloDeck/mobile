# Coding Standards

## Dart Style

- Follow `flutter_lints` + custom rules in `analysis_options.yaml`.
- Use `prefer_single_quotes: true`.
- Use `require_trailing_commas: true` for widget arguments.
- Never use `dynamic` unless wrapping JSON deserialization.
- Use `sealed` classes for exhaustive state modeling.
- Use `final` for all local variables unless mutation is required.

## Naming

| Type | Convention | Example |
|---|---|---|
| File | `snake_case.dart` | `deal_repository.dart` |
| Class | `PascalCase` | `DealRepository` |
| Provider | `camelCaseProvider` | `dealListProvider` |
| Riverpod notifier | `PascalCaseController` extends `_$PascalCaseController` | `DealsController` |
| Route name constant | `camelCase` | `RouteNames.dealDetail` |
| Drift table | `PluralCamelCase` | `DealsTable` |
| Freezed entity | `@freezed class Singular` | `@freezed class Deal` |

## Riverpod Patterns

```dart
// Provider — always use @riverpod annotation
@riverpod
Future<List<Deal>> dealList(Ref ref) async { ... }

// Notifier — for mutable state
@riverpod
class DealsController extends _$DealsController {
  @override
  AsyncValue<List<Deal>> build() => const AsyncValue.data([]);
}
```

## Error Handling

```dart
// Repository — map DioException to AppException
} on DioException catch (e) {
  throw e.error is AppException
      ? e.error as AppException
      : NetworkException.unknown(e.message);
}

// Provider — let Riverpod surface errors via AsyncValue.error
final deals = ref.watch(dealListProvider); // AsyncValue<List<Deal>>

// Widget — use AsyncValueWidget helper
AsyncValueWidget(
  value: deals,
  data: (items) => DealList(items: items),
  onRetry: () => ref.invalidate(dealListProvider),
)
```

## Freezed Entities

```dart
@freezed
class Deal with _$Deal {
  const factory Deal({
    required String id,
    required String title,
    required DealStage stage,
    double? estimatedValue,
  }) = _Deal;

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);
}
```

## Comments

Write comments only when the WHY is non-obvious. Never document WHAT — the code does that. Never write TODOs without a linked issue.
