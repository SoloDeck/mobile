# ADR-004: Offline-First with Drift

**Status:** Accepted  
**Date:** 2026-06-04

## Context

Vietnamese freelancers often work in areas with unstable connectivity. The app must be usable when offline, syncing changes when connectivity is restored.

## Decision

Implement an offline-first repository pattern using Drift (SQLite) as the local cache.

```
UI → Provider → Repository → RemoteDatasource (Dio)
                           → LocalDatasource  (Drift)
```

**Read strategy:** Return local data immediately; refresh from remote in background.  
**Write strategy:** Write to remote first; on success update local cache; on failure enqueue in `pending_sync` table.

## Why Drift over sqflite

- Type-safe SQL with Dart codegen.
- Reactive streams — widgets rebuild when data changes.
- Migration support built-in.
- Better test support (in-memory database).

## Sync Rules

- Conflict resolution: server `updated_at` timestamp wins.
- `pending_sync` table stores failed writes with retry count.
- Exponential backoff for retries.
- User is shown a "pending sync" indicator when offline changes exist.

## Consequences

**Positive:**
- App works fully offline.
- Instant UI response (no loading spinners for cached data).
- Graceful degradation on poor connectivity.

**Negative:**
- More complex repository layer.
- Must handle conflict resolution.
- Drift codegen adds to build time.
