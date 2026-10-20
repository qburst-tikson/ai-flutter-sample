import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/session_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._sessionRepository) : super(const SettingsInitial());

  final SessionRepository _sessionRepository;

  /// Reads the current user from the session.
  void loadCurrentUser() {
    final user = _sessionRepository.currentUser;
    if (user == null) {
      emit(const SettingsNotLoggedIn());
    } else {
      emit(SettingsLoaded(user.email));
    }
  }
}
