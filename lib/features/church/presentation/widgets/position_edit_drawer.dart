import 'package:flutter/material.dart';
import '../../../../core/widgets/side_drawer.dart';
import '../../../../core/models/church_profile.dart';

class PositionEditDrawer extends StatefulWidget {
  final ChurchPosition? position;
  final Function(ChurchPosition) onSave;
  final VoidCallback? onDelete;
  final VoidCallback onClose;

  const PositionEditDrawer({
    super.key,
    this.position,
    required this.onSave,
    this.onDelete,
    required this.onClose,
  });

  @override
  State<PositionEditDrawer> createState() => _PositionEditDrawerState();
}

class _PositionEditDrawerState extends State<PositionEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.position?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final position =
          widget.position?.copyWith(name: _nameController.text) ??
          ChurchPosition(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text,
            createdAt: DateTime.now(),
          );

      widget.onSave(position);
      widget.onClose();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Position ${widget.position == null ? 'added' : 'updated'} successfully',
          ),
        ),
      );
    }
  }

  void _deletePosition() {
    if (widget.onDelete != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Position'),
          content: const Text(
            'Are you sure you want to delete this position? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete!();
                widget.onClose();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Position deleted successfully'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SideDrawer(
      title: 'Edit Position',
      subtitle: 'Update position information',
      onClose: widget.onClose,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoSection(
              title: 'Position Information',
              children: [
                _FormField(
                  label: 'Position Name',
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter position name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) => value?.isEmpty == true
                        ? 'Position name is required'
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Members using this position
            if (widget.position != null) ...[
              _InfoSection(
                title: 'Members in this Position',
                children: [_MembersListWidget(positionId: widget.position!.id)],
              ),
            ],
          ],
        ),
      ),
      footer: Row(
        children: [
          if (widget.onDelete != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _deletePosition,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                child: const Text('Delete'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Save'),
            ),
          ),
        ],
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
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _MembersListWidget extends StatelessWidget {
  final String positionId;

  const _MembersListWidget({required this.positionId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = _getMembersForPosition(positionId);

    if (members.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'No members assigned to this position',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${members.length} member${members.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ...members.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            final isLast = index == members.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 0.5,
                        ),
                      ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      member.split(' ').map((n) => n[0]).take(2).join(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(member, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Mock method to get members for a position - replace with actual data source
  List<String> _getMembersForPosition(String positionId) {
    // This is mock data - replace with actual member data from your data source
    final mockMembers = {
      'pos1': ['John Doe', 'Jane Smith'],
      'pos2': ['Mike Johnson', 'Sarah Wilson', 'David Brown'],
      'pos3': ['Emily Davis'],
    };

    // For now, return mock data based on position ID
    // In a real app, you'd query your member database
    return mockMembers[positionId] ?? [];
  }
}
