import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/income_entry.dart';
import 'package:palakat_admin/core/widgets/side_drawer.dart';
import 'package:palakat_admin/core/widgets/info_section.dart';
import 'package:palakat_admin/core/widgets/status_chip.dart';
import 'package:palakat_admin/core/widgets/approver_card.dart';
import 'package:palakat_admin/core/models/approval_status.dart';

class IncomeDetailDrawer extends StatelessWidget {
  final IncomeEntry entry;
  final VoidCallback onClose;
  const IncomeDetailDrawer({
    super.key,
    required this.entry,
    required this.onClose,
  });

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
          InfoSection(
            title: 'Basic Information',
            children: [
              InfoRow(label: 'Account ID', value: entry.accountId),
              InfoRow(
                label: 'Date',
                value: DateFormat('y-MM-dd').format(entry.date),
              ),
              InfoRow(
                label: 'Amount',
                value: NumberFormat.currency(
                  locale: 'en_PH',
                  symbol: '₱ ',
                ).format(entry.amount),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Approval Information
          InfoSection(
            title: 'Approval Information',
            children: [
              InfoRow(label: 'Approval ID', value: entry.approvalId),
              InfoRow(
                label: 'Approved Date',
                value: entry.approvedAt != null
                    ? DateFormat('y-MM-dd').format(entry.approvedAt!)
                    : '—',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Current Status (full-width)
          InfoSection(
            title: 'Current Status',
            children: [
              Builder(
                builder: (context) {
                  final (bg, fg, label, icon) = switch (entry.approvalStatus) {
                    ApprovalStatus.pending => (
                      Colors.orange.shade100,
                      Colors.orange.shade800,
                      'Pending',
                      Icons.schedule,
                    ),
                    ApprovalStatus.approved => (
                      Colors.green.shade100,
                      Colors.green.shade800,
                      'Approved',
                      Icons.check_circle,
                    ),
                    ApprovalStatus.rejected => (
                      Colors.red.shade100,
                      Colors.red.shade800,
                      'Rejected',
                      Icons.cancel,
                    ),
                  };
                  return StatusChip(
                    label: label,
                    background: bg,
                    foreground: fg,
                    icon: icon,
                    elevated: true,
                    fontSize: 13.5,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    fullWidth: true,
                  );
                },
              ),
            ],
          ),

          if (entry.approvers.isNotEmpty) ...[
            const SizedBox(height: 24),
            InfoSection(
              title: 'Approvers',
              children: [
                for (final approver in entry.approvers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Builder(
                      builder: (context) {
                        IconData icon;
                        Color color;
                        String statusText;
                        String? dateText;

                        switch (approver.decision) {
                          case ApprovalStatus.approved:
                            icon = Icons.check_circle;
                            color = Colors.green;
                            statusText = 'Approved';
                            if (approver.decisionAt != null) {
                              final d = approver.decisionAt!;
                              dateText =
                                  'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                            }
                            break;
                          case ApprovalStatus.rejected:
                            icon = Icons.cancel;
                            color = Colors.red;
                            statusText = 'Rejected';
                            if (approver.decisionAt != null) {
                              final d = approver.decisionAt!;
                              dateText =
                                  'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                            }
                            break;
                          case ApprovalStatus.pending:
                            icon = Icons.pending;
                            color = Colors.orange;
                            statusText = 'Pending';
                            break;
                        }

                        return ApproverCard(
                          name: approver.name,
                          positions: approver.positions,
                          statusText: statusText,
                          statusColor: color,
                          leadingIcon: icon,
                          leadingColor: color,
                          trailingText: dateText,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Notes
          InfoSection(
            title: 'Notes',
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(entry.notes, style: theme.textTheme.bodyMedium),
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

 

 
