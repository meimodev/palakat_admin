import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/income_entry.dart';
import 'package:palakat_admin/core/widgets/side_drawer.dart';
import 'package:palakat_admin/core/models/approval_status.dart';

class IncomeDetailDrawer extends StatelessWidget {
  final IncomeEntry entry;
  final VoidCallback onClose;
  const IncomeDetailDrawer({super.key, required this.entry, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SideDrawer(
      title: 'Income Details',
      subtitle: 'View detailed information about this income entry',
      onClose: onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          _InfoSection(
            title: 'Basic Information',
            children: [
              _InfoRow(label: 'Account ID', value: entry.accountId),
              _InfoRow(label: 'Date', value: DateFormat('y-MM-dd').format(entry.date)),
              _InfoRow(label: 'Amount', value: NumberFormat.currency(locale: 'en_PH', symbol: '₱ ').format(entry.amount)),
            ],
          ),

          const SizedBox(height: 24),

          // Approval Information
          _InfoSection(
            title: 'Approval Information',
            children: [
              _InfoRow(
                label: 'Status',
                value: entry.approvalStatus.toString(),
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: _CompactStatusChip(status: entry.approvalStatus),
                ),
              ),
              _InfoRow(
                label: 'Approval ID',
                value: entry.approvalId,
              ),
              _InfoRow(
                label: 'Approved Date',
                value: entry.approvedAt != null
                    ? DateFormat('y-MM-dd').format(entry.approvedAt!)
                    : '—',
              ),
            ],
          ),

          if (entry.approvers.isNotEmpty) ...[
            const SizedBox(height: 24),
            _InfoSection(
              title: 'Approvers',
              children: [
                for (final approver in entry.approvers)
                  _ApproverCard(approver: approver),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Notes
          _InfoSection(
            title: 'Notes',
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  entry.notes,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
      footer: Center(
        child: FilledButton.icon(
          onPressed: () {
            // Placeholder for future actions (e.g., edit, export)
          },
          icon: const Icon(Icons.print),
          label: const Text('Export Receipt'),
        ),
      ),
    );
  }

 
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;
  final bool isMultiline;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueWidget,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: isMultiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                valueWidget ?? Text(value, style: theme.textTheme.bodyMedium),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: valueWidget ?? Text(value, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
    );
  }
}

class _CompactStatusChip extends StatelessWidget {
  final ApprovalStatus status;
  
  const _CompactStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      ApprovalStatus.pending => (
        Colors.orange.shade50,
        Colors.orange.shade700,
        'Pending',
      ),
      ApprovalStatus.approved => (
        Colors.green.shade50,
        Colors.green.shade700,
        'Approved',
      ),
      ApprovalStatus.rejected => (
        Colors.red.shade50,
        Colors.red.shade700,
        'Rejected',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg, 
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ApproverCard extends StatelessWidget {
  final dynamic approver;

  const _ApproverCard({required this.approver});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  approver.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                approver.decisionAt != null
                    ? DateFormat('y-MM-dd').format(approver.decisionAt!)
                    : '—',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (approver.positions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final position in approver.positions)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Text(
                      position,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
