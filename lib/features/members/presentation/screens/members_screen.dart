import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/models/membership.dart';

import '../widgets/members_table.dart';
import '../widgets/edit_member_drawer.dart';
import '../state/members_providers.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Members', style: Theme.of(context).textTheme.headlineMedium),
              FilledButton.icon(
                onPressed: () {
                  showEditMemberDrawer(
                    context,
                    member: const Membership(
                      name: '',
                      email: '',
                      phone: '',
                      positions: [],
                      isBaptized: false,
                      isSidi: false,
                      isLinked: false,
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Member'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Filters row
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      _QuickStat(label: 'Total Members', value: '1,248'),
                      _QuickStat(label: 'Claimed Members', value: '1,248'),
                      _QuickStat(label: 'Baptize', value: '1,102'),
                      _QuickStat(label: 'Sidi', value: '86'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FiltersBar(),

                  const SizedBox(height: 16),
                  const MembersTable(),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search name or email',
            ),
            onChanged: (v) =>
                ref.read(membersFilterProvider.notifier).setSearch(v),
          ),
        ),

      ],
    );
  }
}

class _PaginationBar extends ConsumerWidget {
  const _PaginationBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slice = ref.watch(membersPageProvider);
    final filters = ref.watch(membersFilterProvider);
    final totalPages = (slice.total / filters.rowsPerPage).ceil().clamp(
      1,
      9999,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [

          Text('Showing ${slice.rows.length} of ${slice.total}'),
          const SizedBox(width: 12),
          DropdownButton<int>(
            value: filters.rowsPerPage,
            items: const [10, 20, 30]
                .map((e) => DropdownMenuItem(value: e, child: Text('Rows: $e')))
                .toList(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onChanged: (v) => v != null
                ? ref.read(membersFilterProvider.notifier).setRowsPerPage(v)
                : null,
          ),

        ],),
         Row(
          children: [
            IconButton(
              tooltip: 'Prev',
              onPressed: filters.page == 0
                  ? null
                  : () => ref.read(membersFilterProvider.notifier).prevPage(),
              icon: const Icon(Icons.chevron_left),
            ),
            Text('Page ${filters.page + 1} / $totalPages'),
            IconButton(
              tooltip: 'Next',
              onPressed: (filters.page + 1) >= totalPages
                  ? null
                  : () => ref
                        .read(membersFilterProvider.notifier)
                        .nextPage(slice.total),
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
      width: 150,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}
