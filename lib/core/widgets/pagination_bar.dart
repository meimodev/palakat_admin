import 'package:flutter/material.dart';

class PaginationBar extends StatefulWidget {
  final int showingCount;
  final int totalCount;
  final int rowsPerPage;
  final int page; // zero-based
  final int pageCount; // total pages
  final ValueChanged<int> onRowsPerPageChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final List<int> rowSizes;

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
    this.rowSizes = const [5, 10, 20, 50, 100],
  });

  @override
  State<PaginationBar> createState() => _PaginationBarState();
}

class _PaginationBarState extends State<PaginationBar> {
  int value = 0;

  @override
  void initState() {
    super.initState();
    if (widget.rowsPerPage != 0) {
      value = widget.rowsPerPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Text(
            'Showing ${widget.showingCount} of ${widget.totalCount} records',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text('Rows per page', style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: value,
            items: widget.rowSizes
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      '$e',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                value = v ?? 0;
              });
              if (v != null) widget.onRowsPerPageChanged(v);
            },
          ),
          const SizedBox(width: 16),
          Text('Page', style: theme.textTheme.bodySmall),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: (widget.page + 1).clamp(1, widget.pageCount),
            items: [for (int i = 1; i <= widget.pageCount; i++) i]
                .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                .toList(),
            onChanged: (_) {},
          ),
          const SizedBox(width: 8),
          Text('of ${widget.pageCount}', style: theme.textTheme.bodySmall),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: widget.onPrev,
            child: const Text('Previous'),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: widget.onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}
