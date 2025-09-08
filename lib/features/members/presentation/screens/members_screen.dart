import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/models/membership.dart';

import '../widgets/members_table.dart';
import '../widgets/edit_member_drawer.dart';
import '../state/members_providers.dart';
import 'package:palakat_admin/core/widgets/surface_card.dart';
import 'package:palakat_admin/core/widgets/pagination_bar.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Members', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Manage church members and their information.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            title: 'Member Directory',
            subtitle: 'A record of all church members.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick stats row
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
                // Search / filters
                _FiltersBar(),
                const SizedBox(height: 16),
                // Table-like list
                const MembersTable(),
                const SizedBox(height: 8),
                // Pagination bar
                const _PaginationBar(),
              ],
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
    final filters = ref.watch(membersFilterProvider);
    final availablePositions = ref.watch(availablePositionsProvider);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search members...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) =>
                    ref.read(membersFilterProvider.notifier).setSearch(v),
              ),
            ),
            const SizedBox(width: 8),
            IntrinsicWidth(
              child: DropdownButtonFormField<String?>(
                value: filters.selectedPosition,
                decoration: const InputDecoration(
                  labelText: 'Filter by Position',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'All Positions',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...availablePositions.map(
                    (position) => DropdownMenuItem<String?>(
                      value: position,
                      child: Text(
                        position,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    ref.read(membersFilterProvider.notifier).setPosition(value),
              ),
            ),
            const SizedBox(width: 16),
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
    return PaginationBar(
      showingCount: slice.rows.length,
      totalCount: slice.total,
      rowsPerPage: filters.rowsPerPage,
      page: filters.page,
      pageCount: totalPages,
      onRowsPerPageChanged: (v) => 
          ref.read(membersFilterProvider.notifier).setRowsPerPage(v),
      onPrev: () => ref.read(membersFilterProvider.notifier).prevPage(),
      onNext: () => ref
          .read(membersFilterProvider.notifier)
          .nextPage(slice.total),
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

