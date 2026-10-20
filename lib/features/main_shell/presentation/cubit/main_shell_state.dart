part of 'main_shell_cubit.dart';

sealed class MainShellState extends Equatable {
  const MainShellState();

  @override
  List<Object?> get props => [];
}

final class MainShellInitial extends MainShellState {
  const MainShellInitial();
}

final class MainShellTabChanged extends MainShellState {
  const MainShellTabChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}
