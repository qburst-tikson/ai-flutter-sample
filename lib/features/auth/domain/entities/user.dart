import 'package:equatable/equatable.dart';

/// The logged-in account.
///
/// Held in memory only for the lifetime of the process; no persistence yet.
class User extends Equatable {
  const User({required this.email});

  /// The email exactly as entered (trimmed), not a rewritten one.
  final String email;

  @override
  List<Object?> get props => [email];
}
