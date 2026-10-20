import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/widgets/logout_button.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SettingsCubit>()..loadCurrentUser(),
      child: const SettingsView(),
    );
  }
}

/// The UI only. Separated from [SettingsPage] so tests can inject a mock cubit.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [const LogoutButton()],
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: switch (state) {
              // Transient: the cubit loads on creation, so this is never
              // visible in practice.
              SettingsInitial() => const SizedBox.shrink(),
              SettingsLoaded(:final email) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Logged in as'),
                    subtitle: Text(email),
                  ),
                ),
              SettingsNotLoggedIn() => const Text('Not logged in'),
            },
          ),
        ),
      ),
    );
  }
}
