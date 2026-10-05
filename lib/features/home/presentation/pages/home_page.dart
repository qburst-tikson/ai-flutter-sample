import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: const HomeView(),
    );
  }
}

/// The UI only. Separated from [HomePage] so tests can inject a mock cubit.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) => switch (state) {
              HomeInitial() || HomeLoading() =>
                const CircularProgressIndicator(),
              HomeLoaded(:final greeting) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      greeting.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(greeting.message, textAlign: TextAlign.center),
                  ],
                ),
              HomeError(:final message) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.read<HomeCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
            },
          ),
        ),
      ),
    );
  }
}
