# ADR-001: Feature-First Modular Architecture

**Status:** Accepted  
**Date:** 2026-06-04

## Context

The initial mobile prototype used a folder-by-type structure (`screens/`, `models/`, `repositories/`). As the app grew to 9 business domains, every feature addition required touching 4+ unrelated top-level folders, making PRs noisy and making it hard for AI agents to understand the scope of a change.

## Decision

Adopt a Feature-First Modular Architecture where each business domain is a self-contained module under `lib/modules/<name>/`. Each module owns its full vertical slice: UI, business logic, data access.

## Consequences

**Positive:**
- All code for a feature lives in one folder — easy to navigate.
- AI agents can understand a feature by reading one module directory.
- Modules can be extracted into Dart packages if needed.
- Parallel development on different modules has zero merge conflicts.

**Negative:**
- Some code duplication across modules (e.g., list widgets) — mitigated by `shared/`.
- More folders to create upfront.

## Alternatives Considered

- **Folder-by-type** (rejected): Mixes all domains; hard to navigate for large codebases.
- **MVC** (rejected): Too coupled; doesn't support offline-first or proper testability.
- **Bloc pattern** (rejected): Overly verbose boilerplate for this scale.
