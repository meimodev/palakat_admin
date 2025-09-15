import 'package:flutter/material.dart';
import 'package:palakat_admin/core/widgets/side_drawer.dart';
import 'package:palakat_admin/core/widgets/type_chip.dart';
import 'package:palakat_admin/core/widgets/status_chip.dart';
import 'package:palakat_admin/core/widgets/info_section.dart';
import 'package:palakat_admin/core/widgets/supervisor_card.dart';
import 'package:palakat_admin/core/widgets/approver_card.dart';

import '../screens/approval_screen.dart';

class ApprovalDetailDrawer extends StatefulWidget {
  final ApprovalRequest request;
  final VoidCallback onClose;
  final Function(ApprovalRequest) onUpdate;

  const ApprovalDetailDrawer({
    super.key,
    required this.request,
    required this.onClose,
    required this.onUpdate,
  });

  @override
  State<ApprovalDetailDrawer> createState() => _ApprovalDetailDrawerState();
}

class _ApprovalDetailDrawerState extends State<ApprovalDetailDrawer> {
  late ApprovalRequest _currentRequest;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SideDrawer(
      title: 'Approval Details',
      subtitle: 'Review and take action on this request',
      onClose: widget.onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Info
          InfoSection(
            title: 'Request Information',
            children: [
              InfoRow(
                label: 'Date',
                value: _formatDate(_currentRequest.date),
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              InfoRow(
                label: 'Type',
                value: _currentRequest.type,
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: TypeChip(label: _currentRequest.type),
                ),
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              InfoRow(
                label: 'Description',
                value: _currentRequest.description,
                isMultiline: true,
                labelWidth: 100,
                spacing: 12,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              if (_currentRequest.note != null)
                InfoRow(
                  label: 'Note',
                  value: _currentRequest.note!,
                  isMultiline: true,
                  labelWidth: 100,
                  spacing: 12,
                  contentPadding: const EdgeInsets.only(bottom: 8),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Supervisor Information
          InfoSection(
            title: 'Supervisor Information',
            children: [
              SupervisorCard(
                name: _currentRequest.supervisor,
                positions: _currentRequest.supervisorPositions,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Approvers
          InfoSection(
            title: 'Approvers',
            children: [
              for (final approver in _currentRequest.approvers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Builder(
                    builder: (context) {
                      IconData icon;
                      Color color;
                      String statusText;
                      String? dateText;

                      switch (approver.decision) {
                        case ApproverDecision.approved:
                          icon = Icons.check_circle;
                          color = Colors.green;
                          statusText = 'Approved';
                          if (approver.decisionAt != null) {
                            final d = approver.decisionAt!;
                            dateText =
                                'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                          }
                          break;
                        case ApproverDecision.rejected:
                          icon = Icons.cancel;
                          color = Colors.red;
                          statusText = 'Rejected';
                          if (approver.decisionAt != null) {
                            final d = approver.decisionAt!;
                            dateText =
                                'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                          }
                          break;
                        case ApproverDecision.pending:
                          icon = Icons.pending;
                          color = Colors.orange;
                          statusText = 'Pending';
                          break;
                      }

                      return ApproverCard(
                        name: approver.name,
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

          const SizedBox(height: 24),

          // Status
          InfoSection(
            title: 'Current Status',
            children: [
              Builder(
                builder: (context) {
                  final (bg, fg, label) = switch (_currentRequest.status) {
                    RequestStatus.pending => (
                      Colors.orange.shade50,
                      Colors.orange.shade700,
                      'Pending',
                    ),
                    RequestStatus.approved => (
                      Colors.green.shade50,
                      Colors.green.shade700,
                      'Approved',
                    ),
                    RequestStatus.rejected => (
                      Colors.red.shade50,
                      Colors.red.shade700,
                      'Rejected',
                    ),
                  };
                  return StatusChip(
                    label: label,
                    background: bg,
                    foreground: fg,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      footer: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Approval can only be approved or rejected on the mobile app by each approver',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

 

 
