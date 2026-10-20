import 'package:flutter/material.dart';

import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../di/injection.dart';
import '../usecase/usecase.dart';

/// App-bar logout button shared by the tab screens.
///
/// Shows a confirm dialog; cancelling stays where the user is, confirming
/// clears the session and navigates to the [LoginPage] with the whole
/// navigation stack removed, so the system Back button cannot return to
/// the tabs.
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
      // Capture the navigator before the async gap so it stays valid.
      final navigator = Navigator.of(context);
      await sl<Logout>()(const NoParams());
      navigator.pushAndRemoveUntil(
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
