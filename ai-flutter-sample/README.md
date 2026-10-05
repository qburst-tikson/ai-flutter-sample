# AI Flutter Sample

Flutter sample app built by an AI pipeline:
**Jira ticket → Claude plans → human approves → Claude implements → Pull Request.**

## How work gets done here

1. Write a ticket in Jira (project **SCRUM**) and add the label `ai`.
2. Drag it to **Ready to work**. Claude reads the ticket and this codebase, then posts a plan as a Jira comment.
3. Review the plan.
   - Approve: drag to **In development**.
   - Changes needed: comment your feedback, drag back to **Open**, then to **Ready to work** again.
4. Claude implements the plan on `feature/SCRUM-<n>-<slug>`, one Conventional Commit per step, runs format + analyze + tests, and opens a PR. The ticket moves to **In review**.
5. A human reviews and merges.

Setup details: [`docs/AI_PIPELINE_SETUP.md`](docs/AI_PIPELINE_SETUP.md).
Rules the AI follows: [`CLAUDE.md`](CLAUDE.md).

## Architecture

Clean Architecture, feature-first, with BLoC:

```
lib/
  core/
    di/          get_it service locator
    error/       Failure types
    usecase/     UseCase contract
  features/
    home/
      data/          repository implementations, data sources
      domain/        entities, repository contracts, use cases
      presentation/  cubit/, pages/
  app.dart
  main.dart
```

## Run locally

```bash
flutter pub get
flutter run
```

## Checks (same as CI)

```bash
dart format .
flutter analyze
flutter test
```
