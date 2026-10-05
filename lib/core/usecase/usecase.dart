/// Contract for a single unit of business logic.
///
/// Use cases throw a `Failure` (see `core/error/failure.dart`) when they fail.
abstract interface class UseCase<Output, Params> {
  Future<Output> call(Params params);
}

/// Pass this when a use case takes no input.
final class NoParams {
  const NoParams();
}
