import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/sidebar.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: isSmall
          ? AppBar(
              title: const Text('Palakat Admin'),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                _AvatarMenu(onProfile: () => context.go('/account')),
              ],
            )
          : null,
      drawer: isSmall ? const AppSidebar() : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSmall) const SizedBox(width: 280, child: AppSidebar()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarMenu extends StatelessWidget {
  const _AvatarMenu({required this.onProfile});
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage('https://placehold.co/100x100.png'),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'profile') onProfile();
      },
    );
  }
}
