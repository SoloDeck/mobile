# Module Boundaries

## Rule

Modules are isolated vertical slices. They must not import each other's internals.

## Allowed Imports

| From | Can import |
|---|---|
| `modules/<name>/presentation/` | `core/`, `shared/`, own `application/` |
| `modules/<name>/application/` | `core/`, `shared/`, own `domain/`, own `infrastructure/` |
| `modules/<name>/domain/` | `shared/models/`, `shared/errors/` only |
| `modules/<name>/infrastructure/` | `core/network/`, `core/database/`, `shared/api/`, own `domain/` |
| `core/` | `shared/` only |
| `shared/` | Nothing from `modules/` or `core/` |

## Forbidden

```dart
// WRONG — deals importing proposals internals
import 'package:solodesk_mobile/modules/proposals/domain/entities/proposal.dart';

// CORRECT — reference proposal ID as a plain String in the Deal entity
// Full Proposal data is fetched separately by the proposals module.
```

## Cross-Module Data

When a module needs data from another module, it:
1. Stores the foreign ID (e.g., `proposal_id`) in its own entity.
2. Calls the other module's repository via a shared interface in `shared/`.
3. Never imports the other module's implementation classes.

## Shared Types

Types that multiple modules reference live in `lib/shared/`:

- `shared/models/api_response.dart` — API envelope
- `shared/models/pagination.dart` — pagination metadata
- `shared/errors/app_exception.dart` — base exception hierarchy
- `shared/api/api_endpoints.dart` — URL constants
