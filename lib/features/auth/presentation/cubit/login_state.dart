part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

/// The last submit failed validation. Either error may be null.
final class LoginInvalid extends LoginState {
  const LoginInvalid({this.emailError, this.passwordError});

  final String? emailError;
  final String? passwordError;

  @override
  List<Object?> get props => [emailError, passwordError];
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess();
}

final class LoginError extends LoginState {
  const LoginError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
