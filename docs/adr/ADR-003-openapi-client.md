# ADR-003: Generated OpenAPI Client

**Status:** Accepted  
**Date:** 2026-06-04

## Context

The backend exposes a full OpenAPI 3.1.0 spec at `../backend/contracts/openapi.yaml`. Manually writing DTOs duplicates the schema and creates drift between frontend and backend types.

## Decision

Generate all API request/response DTOs from the OpenAPI spec. Generated code lives in `lib/shared/api/generated/`. The source of truth is `../backend/contracts/openapi.yaml`.

Hand-written DTOs are allowed only for request bodies where the generated model needs Flutter-specific customization (e.g., file upload).

## Consequences

**Positive:**
- Backend and mobile types are always in sync.
- Regenerating the client catches breaking changes at compile time.
- No manual DTO maintenance.

**Negative:**
- Requires running codegen after backend contract changes.
- Generated code can be verbose — use mappers to convert to clean domain entities.

## Codegen Command

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Never

Never edit files in `lib/shared/api/generated/` by hand. Regenerate instead.
