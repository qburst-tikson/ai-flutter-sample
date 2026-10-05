# CLAUDE.md — rules for the AI agent on this Flutter project

Edit this file to match your project. The planning and implementation agents read it on every run.

## Project
- Flutter (stable channel), Dart 3, null-safe.
- Targets: Android + iOS.

## Architecture
- Clean Architecture, feature-first folders:
  ```
  lib/
    core/            # shared: di, network, error, theme, utils, widgets
    features/<name>/
      data/          # models (DTOs), datasources, repository implementations
      domain/        # entities, repository contracts, use cases
      presentation/  # bloc/, pages/, widgets/
  ```
- State management: **flutter_bloc** only. Cubit for simple flows, Bloc when there are many events.
  One per screen or flow. States are `sealed` classes extending `Equatable`
  (see `features/home/presentation/cubit/home_state.dart`; copy that pattern).
- Dependency injection: plain `get_it` in `lib/core/di/injection.dart` (no code generation).
  Repositories and use cases are `registerLazySingleton`; cubits/blocs are `registerFactory`.
  Add a commented block per feature. Never instantiate repositories inside widgets.
- Errors: data layer catches raw exceptions and throws a `Failure` subtype from
  `lib/core/error/failure.dart`. Cubits catch `Failure` and emit an error state.
  The UI never sees raw exceptions. Do not add dartz/fpdart.
- Use cases implement `UseCase<Output, Params>` from `lib/core/usecase/usecase.dart`.
- Pages: a `XxxPage` that provides the cubit via `sl<XxxCubit>()`, and a separate
  `XxxView` with the UI so widget tests can inject a mock cubit.
- Networking: no HTTP client yet. If a ticket needs one, add `dio` (listed in the plan)
  with a remote data source under `features/<name>/data/datasources/`.
- No business logic in widgets. Widgets render state and call cubit methods.
- The `home` feature is the reference implementation; follow its structure.

## Code style
- Must pass `dart format .` and `flutter analyze` with zero issues.
- Prefer `const` constructors. Keep widgets small; extract when a build method gets long.
- No new packages unless the approved plan lists them. Pin versions in pubspec.yaml.
- No hard-coded secrets, API keys or URLs — use the existing config/env mechanism.
- User-facing strings go through the existing localisation setup if the project has one.

## Tests
- Every new Bloc/Cubit gets `bloc_test` tests (success, failure, edge cases).
- Every new use case and repository gets unit tests (mock with `mocktail`).
- Widget tests for new screens covering the main states (loading / loaded / error).

## Git commit format (MANDATORY)
Conventional Commits, Jira key at the end:

```
<type>(<scope>): <short imperative summary, max 72 chars> [<JIRA-KEY>]

<body: what changed and WHY, wrapped at 72 chars>
```

- `type`: feat | fix | refactor | test | docs | chore | style | perf | build | ci
- `scope`: the feature folder or area (auth, profile, core, deps …)
- One logical change per commit. Tests may go with the code they test.
- Examples:
  - `feat(auth): add LoginBloc with email/password flow [SCRUM-12]`
  - `test(auth): cover LoginBloc success and failure states [SCRUM-12]`
  - `chore(deps): add flutter_bloc 9.x [SCRUM-12]`

## Never
- Push, rebase, reset, force anything, or touch other branches.
- Modify `.github/workflows/`, `scripts/jira.sh`, signing configs, `android/key.properties`,
  `ios/Runner.xcodeproj` signing settings, or anything under `.ai/` in commits.
- Delete or skip existing tests to make the suite pass.
