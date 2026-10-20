part of 'settings_cubit.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// A user is logged in; [email] is the one they logged in with.
final class SettingsLoaded extends SettingsState {
  const SettingsLoaded(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// No user is set (should not happen through the normal flow).
final class SettingsNotLoggedIn extends SettingsState {
  const SettingsNotLoggedIn();
}
