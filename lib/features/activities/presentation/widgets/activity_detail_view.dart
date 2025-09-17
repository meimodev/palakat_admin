import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/activity.dart';
import '../../../../core/widgets/side_drawer.dart';
import '../../../../core/widgets/info_section.dart';
import '../../../../core/widgets/supervisor_card.dart';
import '../../../../core/widgets/approver_card.dart';
import '../../../../core/widgets/status_chip.dart';

class ActivityDetailView extends StatelessWidget {
  final Activity activity;
  final VoidCallback onClose;

  const ActivityDetailView({
    super.key,
    required this.activity,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SideDrawer(
      title: 'Activity Details',
      subtitle: 'View detailed information about this activity',
      onClose: onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          InfoSection(
            title: 'Basic Information',
            children: [
              InfoRow(label: 'Activity ID', value: activity.id),
              InfoRow(label: 'Title', value: activity.title),
              InfoRow(label: 'Description', value: activity.description),
              InfoRow(
                label: 'Type',
                value: activity.type.displayName,
                valueWidget: _ActivityTypeChip(type: activity.type),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Schedule Information
          InfoSection(
            title: 'Schedule Information',
            children: [
              InfoRow(
                label: 'Start Date',
                value: DateFormat(
                  'MMM dd, yyyy - HH:mm',
                ).format(activity.startDate),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Supervisor Information
          InfoSection(
            title: 'Supervisor Information',
            children: [
              SupervisorCard(
                name: activity.supervisor,
                positions: activity.supervisorPositions,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Approvers (mirrors approval drawer UI)
          InfoSection(
            title: 'Approvers',
            children: [
              for (final approver in _approversFor(activity))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Builder(
                    builder: (context) {
                      IconData icon;
                      Color color;
                      String statusText;
                      String? dateText;

                      switch (approver.decision) {
                        case _ActApproverDecision.approved:
                          icon = Icons.check_circle;
                          color = Colors.green;
                          statusText = 'Approved';
                          if (approver.decisionAt != null) {
                            final d = approver.decisionAt!;
                            dateText =
                                'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                          }
                          break;
                        case _ActApproverDecision.rejected:
                          icon = Icons.cancel;
                          color = Colors.red;
                          statusText = 'Rejected';
                          if (approver.decisionAt != null) {
                            final d = approver.decisionAt!;
                            dateText =
                                'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                          }
                          break;
                        case _ActApproverDecision.pending:
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

          const SizedBox(height: 24),

          // Location & Participants
          InfoSection(
            title: 'Location',
            children: [
              InfoRow(
                label: 'Location Name',
                value: activity.location ?? 'Not specified',
              ),
              InfoRow(
                label: 'Position',
                value: '1.12341232423, -2.42345424452',
              ),
              InfoRow(
                label: 'Link Google Maps',
                value: 'https://maps.app.goo.gl/123456789',
              ),
            ],
          ),

          if (activity.notes != null) ...[
            const SizedBox(height: 24),
            InfoSection(
              title: 'Notes',
              children: [
                InfoRow(label: 'Additional Notes', value: activity.notes!),
              ],
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
      footer: Column(
        children: [
          Builder(
            builder: (context) {
              final approvers = _approversFor(activity);
              final hasRejected = approvers.any(
                    (a) => a.decision == _ActApproverDecision.rejected,
              );
              final allApproved = approvers.isNotEmpty && approvers.every(
                    (a) => a.decision == _ActApproverDecision.approved,
              );

              final (bg, fg, label, icon) = hasRejected
                  ? (
              Colors.red.shade100,
              Colors.red.shade800,
              'Rejected',
              Icons.cancel,
              )
                  : (allApproved
                  ? (
              Colors.green.shade100,
              Colors.green.shade800,
              'Approved',
              Icons.check_circle,
              )
                  : (
              Colors.orange.shade100,
              Colors.orange.shade800,
              'Unconfirmed',
              Icons.pending,
              ));

              return StatusChip(
                label: label,
                background: bg,
                foreground: fg,
                icon: icon,
                fontSize: 13.5,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                fullWidth: true,
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Published activities can only be managed on mobile app by the corresponding supervisor.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _ActivityTypeChip extends StatelessWidget {
  final ActivityType type;

  const _ActivityTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (type) {
      ActivityType.service =>
      (
      Colors.teal.shade50,
      Colors.teal.shade700,
      Icons.handshake,
      ),
      ActivityType.event =>
      (
      Colors.red.shade50,
      Colors.red.shade700,
      Icons.event,
      ),
      ActivityType.announcement =>
      (
      Colors.blue.shade50,
      Colors.blue.shade700,
      Icons.campaign,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            type.displayName,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Local approver model and generator for Activity detail (mirrors approvals UI) ---

enum _ActApproverDecision { pending, approved, rejected }

class _ActApprover {
  final String name;
  final _ActApproverDecision decision;
  final DateTime? decisionAt;

  _ActApprover(this.name, this.decision, [this.decisionAt]);
}

List<_ActApprover> _approversFor(Activity a) {
  switch (a.status) {
    case ActivityStatus.planned:
      return [
        _ActApprover('Pastor John', _ActApproverDecision.pending),
      ];
    case ActivityStatus.ongoing:
      return [
        _ActApprover(
          'Pastor John',
          _ActApproverDecision.approved,
          a.startDate.subtract(const Duration(hours: 2)),
        ),
        _ActApprover('Deacon Mary', _ActApproverDecision.pending),
      ];
    case ActivityStatus.completed:
      return [
        _ActApprover(
          'Pastor John',
          _ActApproverDecision.approved,
          a.startDate.subtract(const Duration(days: 1, hours: 3)),
        ),
        _ActApprover(
          'Admin Bob',
          _ActApproverDecision.approved,
          a.startDate.subtract(const Duration(days: 1, hours: 1)),
        ),
      ];
    case ActivityStatus.cancelled:
      return [
        _ActApprover(
          'Admin Bob',
          _ActApproverDecision.rejected,
          a.startDate.subtract(const Duration(hours: 4)),
        ),
      ];
  }
}
