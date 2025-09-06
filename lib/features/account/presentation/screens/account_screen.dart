import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundImage: NetworkImage('https://placehold.co/100x100.png')),
                title: Text('Admin User'),
                subtitle: Text('admin@palakat.com'),
              ),
              SizedBox(height: 12),
              Text('Role: Administrator'),
              Text('Member since: 2023-01-01'),
            ],
          ),
        ),
      ],
    );
  }
}
