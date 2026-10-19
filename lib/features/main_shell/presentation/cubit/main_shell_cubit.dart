import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'main_shell_state.dart';

/// Holds the index of the tab currently shown by the main shell.
class MainShellCubit extends Cubit<MainShellState> {
  MainShellCubit() : super(const MainShellInitial());

  int _index = 0;

  /// Index of the currently selected tab (0 = Home, 1 = Search, 2 = Settings).
  int get index => _index;

  /// Selects the tab at [index]. Setting the current index is a no-op.
  void changeTab(int index) {
    if (index == _index) return;
    _index = index;
    emit(MainShellTabChanged(index));
  }
}
