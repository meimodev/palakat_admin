import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/users_providers.dart';

class UsersTable extends ConsumerWidget {
  const UsersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slice = ref.watch(usersPageProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Status')),
        ],
        rows: [
          for (final u in slice.rows)
            DataRow(
              cells: [
                DataCell(Text(u.name)),
                DataCell(Text(u.email)),
                DataCell(_RoleChip(role: u.role)),
                DataCell(_StatusChip(status: u.status)),
              ],
            ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toLowerCase() == 'admin';
    final color = isAdmin ? Colors.indigo : Colors.grey;
    return Chip(
      label: Text(role),
      side: BorderSide(color: color.withOpacity(0.4)),
      backgroundColor: color.withOpacity(0.08),
      labelStyle: TextStyle(color: color.shade700, fontWeight: FontWeight.w600),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? Colors.green : Colors.orange;
    return Chip(
      label: Text(status),
      side: BorderSide(color: color.withOpacity(0.4)),
      backgroundColor: color.withOpacity(0.08),
      labelStyle: TextStyle(color: color.shade700, fontWeight: FontWeight.w600),
    );
  }
}
