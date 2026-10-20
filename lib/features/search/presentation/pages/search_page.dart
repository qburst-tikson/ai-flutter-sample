import 'package:flutter/material.dart';

import '../../../auth/presentation/widgets/logout_button.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => const SearchView();
}

/// The UI only. Separated from [SearchPage] so tests can build it directly.
class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [const LogoutButton()],
      ),
      body: const Center(child: Text('Search')),
    );
  }
}
