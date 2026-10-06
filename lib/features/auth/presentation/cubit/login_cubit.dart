import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/usecases/login.dart';
import '../../domain/validators/login_validator.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._login) : super(const LoginInitial());

  final Login _login;

  Future<void> login(String email, String password) async {
    if (state is LoginLoading) return;

    final emailError = LoginValidator.validateEmail(email);
    final passwordError = LoginValidator.validatePassword(password);
    if (emailError != null || passwordError != null) {
      emit(LoginInvalid(emailError: emailError, passwordError: passwordError));
      return;
    }

    emit(const LoginLoading());
    try {
      await _login(LoginParams(email: email.trim(), password: password));
      emit(const LoginSuccess());
    } on Failure catch (failure) {
      emit(LoginError(failure.message));
    } catch (_) {
      emit(const LoginError('Something went wrong.'));
    }
  }

  /// Clears the inline error of a field once the user edits it.
  void clearFieldError({bool email = false, bool password = false}) {
    final current = state;
    if (current is! LoginInvalid) return;

    final emailError = email ? null : current.emailError;
    final passwordError = password ? null : current.passwordError;
    if (emailError == current.emailError &&
        passwordError == current.passwordError) {
      return;
    }
    emit(
      emailError == null && passwordError == null
          ? const LoginInitial()
          : LoginInvalid(emailError: emailError, passwordError: passwordError),
    );
  }
}
