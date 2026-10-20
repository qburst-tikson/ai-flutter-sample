import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../cubit/logout_cubit.dart';
import '../pages/login_page.dart';

/// App-bar logout button shared by the tab screens.
///
/// Shows a confirm dialog; cancelling stays where the user is, confirming
/// asks [LogoutCubit] to clear the session and a [BlocListener] navigates to
/// the [LoginPage] with the whole navigation stack removed, so the system
/// Back button cannot return to the tabs.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LogoutCubit>(),
      child: BlocListener<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: const _LogoutIcon(),
      ),
    );
  }
}

/// The icon and confirm dialog. A separate widget so its [context] sits
/// below the BlocProvider and can read [LogoutCubit].
class _LogoutIcon extends StatelessWidget {
  const _LogoutIcon();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      // No use case calls in the widget: the cubit clears the session and
      // the BlocListener above navigates once it succeeds.
      context.read<LogoutCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () => _confirmLogout(context),
    );
  }
}
