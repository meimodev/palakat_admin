import 'package:flutter/material.dart';
import '../../../../core/widgets/side_drawer.dart';
import '../../../../core/models/column.dart' as cm;
import '../../../../core/widgets/info_section.dart';

class ColumnEditDrawer extends StatefulWidget {
  final cm.Column? column;
  final Function(cm.Column) onSave;
  final VoidCallback? onDelete;
  final VoidCallback onClose;
  final int churchId;

  const ColumnEditDrawer({
    super.key,
    this.column,
    required this.onSave,
    this.onDelete,
    required this.onClose,
    required this.churchId,
  });

  @override
  State<ColumnEditDrawer> createState() => _ColumnEditDrawerState();
}

class _ColumnEditDrawerState extends State<ColumnEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.column?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final column = widget.column?.copyWith(
            name: _nameController.text.trim(),
            updatedAt: DateTime.now(),
          ) ??
          cm.Column(
            id: DateTime.now().millisecondsSinceEpoch,
            name: _nameController.text.trim(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            churchId: widget.churchId,
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
            InfoSection(
              title: 'Basic Information',
              titleSpacing: 16,
              children: [
                _FormField(
                  label: 'Column Name',
                  child: TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Enter column name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Column name is required';
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
