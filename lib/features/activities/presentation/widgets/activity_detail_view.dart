import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/activity.dart';
import '../../../../core/widgets/side_drawer.dart';

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
          _InfoSection(
            title: 'Basic Information',
            children: [
              _InfoRow(label: 'Activity ID', value: activity.id),
              _InfoRow(label: 'Title', value: activity.title),
              _InfoRow(label: 'Description', value: activity.description),
              _InfoRow(
                label: 'Type',
                value: activity.type.displayName,
                valueWidget: _ActivityTypeChip(type: activity.type),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Schedule Information
          _InfoSection(
            title: 'Schedule Information',
            children: [
              _InfoRow(
                label: 'Start Date',
                value: DateFormat(
                  'MMM dd, yyyy - HH:mm',
                ).format(activity.startDate),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Organizer Information
          _InfoSection(
            title: 'Organizer Information',
            children: [
              _OrganizerCard(
                name: activity.organizer,
                positions: activity.organizerPositions,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Location & Participants
          _InfoSection(
            title: 'Location',
            children: [
              _InfoRow(
                label: 'Location Name',
                value: activity.location ?? 'Not specified',
              ),
              _InfoRow(
                label: 'Position',
                value: '1.12341232423, -2.42345424452',
              ),
              _InfoRow(
                label: 'Link Google Maps',
                value: 'https://maps.app.goo.gl/123456789',
              ),
            ],
          ),

          if (activity.notes != null) ...[
            const SizedBox(height: 24),
            _InfoSection(
              title: 'Notes',
              children: [
                _InfoRow(label: 'Additional Notes', value: activity.notes!),
              ],
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
      footer: Container(
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
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Published activities can only be managed on mobile app by the corresponding organizer.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

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

  const _InfoRow({required this.label, required this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
            child:
                valueWidget ?? Text(value, style: theme.textTheme.bodyMedium),
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

class _OrganizerCard extends StatelessWidget {
  final String name;
  final List<String> positions;

  const _OrganizerCard({required this.name, required this.positions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (positions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final position in positions)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(position, style: theme.textTheme.labelSmall),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
