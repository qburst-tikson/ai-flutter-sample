import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/logout.dart';

part 'logout_state.dart';

/// Clears the session on logout; the widget listens for [LogoutSuccess].
class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit(this._logout) : super(const LogoutInitial());

  final Logout _logout;

  Future<void> logout() async {
    emit(const LogoutInProgress());
    try {
      await _logout(const NoParams());
      emit(const LogoutSuccess());
    } on Failure catch (failure) {
      emit(LogoutFailure(failure.message));
    } catch (_) {
      emit(const LogoutFailure('Something went wrong.'));
    }
  }
}
