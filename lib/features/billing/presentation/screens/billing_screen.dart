import 'package:flutter/material.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Billing', style: theme.textTheme.headlineMedium),
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
              Text('Current Plan: Pro'),
              SizedBox(height: 8),
              Text('Next Billing Date: 2025-10-01'),
              SizedBox(height: 12),
              _InvoicesTable(),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvoicesTable extends StatelessWidget {
  const _InvoicesTable();

  @override
  Widget build(BuildContext context) {
    final rows = List.generate(6, (i) => (
      'INV-2025-${1000 + i}',
      '2025-09-${10 + i}',
      i.isEven ? 'Paid' : 'Due',
      i.isEven ? '₱ 1,499.00' : '₱ 1,499.00',
    ));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Invoice #')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Amount')),
        ],
        rows: [
          for (final r in rows)
            DataRow(cells: [
              DataCell(Text(r.$1)),
              DataCell(Text(r.$2)),
              DataCell(_StatusChip(status: r.$3)),
              DataCell(Text(r.$4)),
            ])
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final paid = status.toLowerCase() == 'paid';
    final color = paid ? Colors.green : Colors.orange;
    return Chip(
      label: Text(status),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      backgroundColor: color.withValues(alpha: 0.08),
      labelStyle: TextStyle(color: color.shade700, fontWeight: FontWeight.w600),
    );
  }
}
