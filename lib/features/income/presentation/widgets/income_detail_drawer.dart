import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/income_entry.dart';
import 'package:palakat_admin/core/widgets/status_chip.dart';

class IncomeDetailDrawer extends StatelessWidget {
  final IncomeEntry entry;
  final VoidCallback onClose;
  const IncomeDetailDrawer({super.key, required this.entry, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 420,
      height: double.infinity,
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Income Details', style: theme.textTheme.titleLarge),
                          Text(
                            entry.accountId,
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(label: 'Account ID', value: entry.accountId),
                _InfoRow(label: 'Date', value: DateFormat('y-MM-dd').format(entry.date)),
                _InfoRow(label: 'Amount', value: NumberFormat.currency(locale: 'en_PH', symbol: '₱ ').format(entry.amount)),
                const SizedBox(height: 12),
                Text('Approval', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusChip(status: entry.approvalStatus),
                    const SizedBox(width: 8),
                    Text(
                      entry.approvedAt != null
                          ? DateFormat('y-MM-dd').format(entry.approvedAt!)
                          : '—',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Text(entry.approvalId, style: theme.textTheme.labelMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (entry.approvers.isNotEmpty) ...[
                  Column(
                    children: [
                      for (final a in entry.approvers)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.name, style: theme.textTheme.bodyMedium),
                                    if (a.positions.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          for (final p in a.positions)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.surfaceContainerHighest,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: theme.colorScheme.outlineVariant),
                                              ),
                                              child: Text(
                                                p,
                                                style: theme.textTheme.labelSmall,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                a.decisionAt != null
                                    ? DateFormat('y-MM-dd').format(a.decisionAt!)
                                    : '—',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text('Notes', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Text(entry.notes),
                ),
                const Spacer(),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        // Placeholder for future actions (e.g., edit, export)
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Export Receipt'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
