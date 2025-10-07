import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/constants/enums.dart';

import '../../../../core/models/activity.dart';
import '../../../../core/widgets/side_drawer.dart';
import '../../../../core/widgets/info_section.dart';
import '../../../../core/widgets/supervisor_card.dart';
import '../../../../core/widgets/approver_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/services/approver_service.dart';
import '../../../../core/utils/date_utils.dart';

class ActivityDetailView extends ConsumerWidget {
  final Activity activity;
  final VoidCallback onClose;

  const ActivityDetailView({
    super.key,
    required this.activity,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvers = ref.watch(activityApproversProvider(activity));
    final approvalStatus = ref.watch(activityApprovalStatusProvider(activity));
    final approverService = ref.watch(approverServiceProvider);

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
              InfoRow(label: 'Activity ID', value: activity.id ?? '-'),
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
                value: AppDateUtils.formatDateTime(activity.startDate),
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

          // Approvers (using shared ApproverService)
          InfoSection(
            title: 'Approvers',
            children: [
              for (final approver in approvers)
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
                            dateText =
                                'on ${AppDateUtils.formatStandardDate(approver.decisionAt!)}';
                          }
                          break;
                        case ApprovalStatus.rejected:
                          icon = Icons.cancel;
                          color = Colors.red;
                          statusText = 'Rejected';
                          if (approver.decisionAt != null) {
                            dateText =
                                'on ${AppDateUtils.formatStandardDate(approver.decisionAt!)}';
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
              final statusDisplay = approverService.getStatusDisplay(
                approvalStatus,
              );
              return StatusChip(
                label: statusDisplay.label,
                background: Color(
                  statusDisplay.colorValue,
                ).withValues(alpha: 0.2),
                foreground: Color(statusDisplay.colorValue),
                icon: IconData(
                  statusDisplay.iconCodePoint,
                  fontFamily: 'MaterialIcons',
                ),
                fontSize: 13.5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
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
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
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
      ActivityType.service => (
        Colors.teal.shade50,
        Colors.teal.shade700,
        Icons.handshake,
      ),
      ActivityType.event => (
        Colors.red.shade50,
        Colors.red.shade700,
        Icons.event,
      ),
      ActivityType.announcement => (
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

// Approver logic moved to shared ApproverService
