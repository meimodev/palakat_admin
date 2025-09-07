import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int showingCount;
  final int totalCount;
  final int rowsPerPage;
  final int page; // zero-based
  final int pageCount; // total pages
  final ValueChanged<int> onRowsPerPageChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const PaginationBar({
    super.key,
    required this.showingCount,
    required this.totalCount,
    required this.rowsPerPage,
    required this.page,
    required this.pageCount,
    required this.onRowsPerPageChanged,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Text(
            'Showing $showingCount of $totalCount records',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text('Rows per page', style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: rowsPerPage,
            items: const [5, 10, 20]
                .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                .toList(),
            onChanged: (v) {
              if (v != null) onRowsPerPageChanged(v);
            },
          ),
          const SizedBox(width: 16),
          Text('Page', style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: (page + 1).clamp(1, pageCount),
            items: [for (int i = 1; i <= pageCount; i++) i]
                .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                .toList(),
            onChanged: (_) {},
          ),
          const SizedBox(width: 8),
          Text('of $pageCount', style: theme.textTheme.bodySmall),
          const SizedBox(width: 12),
          OutlinedButton(onPressed: onPrev, child: const Text('Previous')),
          const SizedBox(width: 8),
          FilledButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}
