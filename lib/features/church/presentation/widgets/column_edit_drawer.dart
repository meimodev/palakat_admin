import 'package:flutter/material.dart';
import '../../../../core/widgets/side_drawer.dart';
import '../../../../core/models/church_profile.dart';

class ColumnEditDrawer extends StatefulWidget {
  final ChurchColumn? column;
  final Function(ChurchColumn) onSave;
  final VoidCallback? onDelete;
  final VoidCallback onClose;

  const ColumnEditDrawer({
    super.key,
    this.column,
    required this.onSave,
    this.onDelete,
    required this.onClose,
  });

  @override
  State<ColumnEditDrawer> createState() => _ColumnEditDrawerState();
}

class _ColumnEditDrawerState extends State<ColumnEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(
      text: widget.column?.number.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final column =
          widget.column?.copyWith(number: int.parse(_numberController.text)) ??
          ChurchColumn(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            number: int.parse(_numberController.text),
            name:
                'Column ${_numberController.text}', // Auto-generate name from number
            createdAt: DateTime.now(),
          );

      widget.onSave(column);
      widget.onClose();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Column ${widget.column == null ? 'added' : 'updated'} successfully',
          ),
        ),
      );
    }
  }

  void _deleteColumn() {
    if (widget.onDelete != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Column'),
          content: const Text(
            'Are you sure you want to delete this column? This action cannot be undone.',
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
                  const SnackBar(content: Text('Column deleted successfully')),
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
      title: 'Edit Column',
      subtitle: 'Update column information',
      onClose: widget.onClose,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            _InfoSection(
              title: 'Basic Information',
              children: [
                _FormField(
                  label: 'Column Number',
                  child: TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter column number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return 'Column number is required';
                      }
                      if (int.tryParse(value!) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      footer: Row(
        children: [
          if (widget.onDelete != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _deleteColumn,
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
