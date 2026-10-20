import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';

/// App-bar logout button shared by the tab screens.
///
/// Shows a confirm dialog; cancelling stays where the user is, confirming
/// navigates to the [LoginPage] and clears the whole navigation stack, so
/// the system Back button cannot return to the tabs.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        (route) => false,
      );
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
