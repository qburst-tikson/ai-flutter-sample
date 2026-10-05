import 'package:equatable/equatable.dart';

/// Base class for every error the domain layer exposes.
///
/// The data layer catches raw exceptions (network, parsing, storage) and maps
/// them to a [Failure]. The presentation layer only ever sees failures.
sealed class Failure extends Equatable implements Exception {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Something went wrong talking to a remote server.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

/// The device has no usable network connection.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Reading or writing local storage failed.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local data.']);
}

/// Anything we did not anticipate.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}
