import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../cubit/main_shell_cubit.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MainShellCubit>(),
      child: const MainShellView(),
    );
  }
}

/// The UI only. Separated from [MainShellPage] so tests can inject a cubit.
///
/// The [PageView] (swipe) and the [NavigationBar] (tap) both go through the
/// cubit, so the selected tab and the visible screen always stay in sync:
/// a swipe reports `onPageChanged` to the cubit, and a tap emits a state
/// that the listener turns into an animated `animateToPage`.
class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  final PageController _pageController = PageController();

  static const List<Widget> _pages = [HomePage(), SearchPage(), SettingsPage()];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MainShellCubit, MainShellState>(
        listener: (context, state) {
          // Animate only when the page is not already there: swipes emit
          // through onPageChanged, so re-animating would fight the gesture.
          if (state is MainShellTabChanged &&
              state.index != _pageController.page?.round()) {
            _pageController.animateToPage(
              state.index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        },
        child: PageView(
          controller: _pageController,
          // Swiping clamps at the ends: a PageView cannot scroll past its
          // first or last page.
          onPageChanged: (index) =>
              context.read<MainShellCubit>().changeTab(index),
          children: _pages,
        ),
      ),
      bottomNavigationBar: BlocBuilder<MainShellCubit, MainShellState>(
        builder: (context, state) {
          final selectedIndex = state is MainShellTabChanged ? state.index : 0;
          return NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) =>
                context.read<MainShellCubit>().changeTab(index),
            destinations: _destinations,
          );
        },
      ),
    );
  }
}
