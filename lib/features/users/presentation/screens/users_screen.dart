import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/users_table.dart';
import '../state/users_providers.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Members', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filters row
                  _FiltersBar(),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      _QuickStat(label: 'Total Members', value: '1,248'),
                      _QuickStat(label: 'Active', value: '1,102'),
                      _QuickStat(label: 'Pending', value: '86'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const UsersTable(),
                  const SizedBox(height: 8),
                  const _PaginationBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(usersFilterProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search name or email'),
            onChanged: (v) => ref.read(usersFilterProvider.notifier).setSearch(v),
          ),
        ),
        DropdownButton<String>(
          value: filters.role,
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All Roles')),
            DropdownMenuItem(value: 'Admin', child: Text('Admin')),
            DropdownMenuItem(value: 'Member', child: Text('Member')),
          ],
          onChanged: (v) => v != null ? ref.read(usersFilterProvider.notifier).setRole(v) : null,
        ),
        DropdownButton<String>(
          value: filters.status,
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All Status')),
            DropdownMenuItem(value: 'Active', child: Text('Active')),
            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
          ],
          onChanged: (v) => v != null ? ref.read(usersFilterProvider.notifier).setStatus(v) : null,
        ),
        DropdownButton<int>(
          value: filters.rowsPerPage,
          items: const [10, 20, 30]
              .map((e) => DropdownMenuItem(value: e, child: Text('Rows: $e')))
              .toList(),
          onChanged: (v) => v != null ? ref.read(usersFilterProvider.notifier).setRowsPerPage(v) : null,
        ),
      ],
    );
  }
}

class _PaginationBar extends ConsumerWidget {
  const _PaginationBar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slice = ref.watch(usersPageProvider);
    final filters = ref.watch(usersFilterProvider);
    final totalPages = (slice.total / filters.rowsPerPage).ceil().clamp(1, 9999);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Showing ${slice.rows.length} of ${slice.total}'),
        Row(
          children: [
            IconButton(
              tooltip: 'Prev',
              onPressed: filters.page == 0 ? null : () => ref.read(usersFilterProvider.notifier).prevPage(),
              icon: const Icon(Icons.chevron_left),
            ),
            Text('Page ${filters.page + 1} / $totalPages'),
            IconButton(
              tooltip: 'Next',
              onPressed: (filters.page + 1) >= totalPages
                  ? null
                  : () => ref.read(usersFilterProvider.notifier).nextPage(slice.total),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}
