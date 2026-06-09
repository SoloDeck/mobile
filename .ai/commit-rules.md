# Commit Rules

The canonical commit and branch convention for this repository. Read before every commit.

## Commit Scope

One logical change per commit. Never bundle unrelated changes.

## Branch Per Purpose (REQUIRED)

Before committing, check the current branch. If on `main`/default, you **MUST** create a new
branch named `<type>/<scope-or-purpose>` and commit there. Never commit directly to `main`.

```
feat/deals-stage-card
fix/auth-token-refresh
refactor/network-error-interceptor
```

## Message Format

`<type>(<scope>): <short summary>`

```
feat(deals): add pipeline stage card widget
fix(auth): handle 401 token refresh race condition
refactor(network): extract error interceptor to own file
test(clients): add unit test for create client use case
```

- **Allowed types:** `feat` · `fix` · `docs` · `refactor` · `test` · `chore`
- **Scope:** the module name or `core`, `shared`, `ci`, `deps`.

## Never Commit

- `assets/env/.env` (real secrets).
- `*.g.dart` or `*.freezed.dart` in a broken state.
- Files from failed `build_runner` runs.

## Version Bump (REQUIRED before a deployable change is done)

Once tests pass and the change is deployable, you **MUST** bump the application version in
`pubspec.yaml` (`version: X.Y.Z+B` — semver `X.Y.Z` plus build number `B`) as part of the same
change:

- `fix` → patch (`1.0.0+1` → `1.0.1+2`)
- `feat` → minor (`1.0.0+1` → `1.1.0+2`)
- breaking change → major (`1.0.0+1` → `2.0.0+2`)

Always increment the build number `+B` on every deployable bump (stores require a higher build
number per upload). Pure `docs`/`test`/`chore`/`refactor` changes that are not independently
deployable do not require a bump. Commit the bump as `chore(version): bump to X.Y.Z+B` (or fold it
into the deployable commit).
