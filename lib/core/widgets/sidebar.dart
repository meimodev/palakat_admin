import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();

    return Drawer(
      elevation: 0,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.church, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Palakat Admin',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    selected: route.startsWith('/dashboard'),
                    onTap: () => context.go('/dashboard'),
                    color: Colors.indigo,
                  ),
                  _NavItem(
                    icon: Icons.group_outlined,
                    label: 'Members',
                    selected: route.startsWith('/members'),
                    onTap: () => context.go('/members'),
                    color: Colors.teal,
                  ),
                  _NavItem(
                    icon: Icons.check_box_outlined,
                    label: 'Approvals',
                    selected: route.startsWith('/approval'),
                    onTap: () => context.go('/approval'),
                    color: Colors.cyan,
                  ),
                  _NavItem(
                    icon: Icons.event_note,
                    label: 'Activities',
                    selected: route.startsWith('/activities'),
                    onTap: () => context.go('/activities'),
                    color: Colors.deepOrange,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Text('Reports', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                  ),
                  _NavItem(
                    icon: Icons.attach_money,
                    label: 'Income',
                    selected: route.startsWith('/income'),
                    onTap: () => context.go('/income'),
                    color: Colors.green,
                  ),
                  _NavItem(
                    icon: Icons.credit_card,
                    label: 'Expenses',
                    selected: route.startsWith('/expenses'),
                    onTap: () => context.go('/expenses'),
                    color: Colors.purple,
                  ),
                  _NavItem(
                    icon: Icons.archive_outlined,
                    label: 'Inventory',
                    selected: route.startsWith('/inventory'),
                    onTap: () => context.go('/inventory'),
                    color: Colors.deepPurple,
                  ),
                  _NavItem(
                    icon: Icons.insert_drive_file_outlined,
                    label: 'Reports',
                    selected: route.startsWith('/reports'),
                    onTap: () => context.go('/reports'),
                    color: Colors.orange,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Text('Administration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                  ),
                  _NavItem(
                    icon: Icons.account_balance,
                    label: 'Church',
                    selected: route.startsWith('/church'),
                    onTap: () => context.go('/church'),
                    color: Colors.red,
                  ),
                  _NavItem(
                    icon: Icons.description_outlined,
                    label: 'Document',
                    selected: route.startsWith('/document'),
                    onTap: () => context.go('/document'),
                    color: Colors.orange,
                  ),
                  _NavItem(
                    icon: Icons.receipt_long,
                    label: 'Billing',
                    selected: route.startsWith('/billing'),
                    onTap: () => context.go('/billing'),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage('https://placehold.co/100x100.png'),
              ),
              title: const Text('Admin User'),
              subtitle: const Text('admin@palakat.com'),
              onTap: () => context.go('/account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: selected ? theme.colorScheme.onPrimary : color),
        ),
        title: Text(label),
        selected: selected,
        selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
