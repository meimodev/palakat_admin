import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/core/models/column_detail.dart';
import '../../../../core/widgets/side_drawer.dart';
import '../../../../core/models/column.dart' as cm;
import '../../../../core/widgets/info_section.dart';
import '../../../../core/widgets/app_snackbars.dart';
import '../../application/church_controller.dart';

class ColumnEditDrawer extends ConsumerStatefulWidget {
  final Function(cm.Column) onSave;
  final VoidCallback? onDelete;
  final VoidCallback onClose;
  final int? columnId;
  final int churchId;

  const ColumnEditDrawer({
    super.key,
    required this.onSave,
    this.onDelete,
    required this.onClose,
    this.columnId,
    required this.churchId,
  });

  @override
  ConsumerState<ColumnEditDrawer> createState() => _ColumnEditDrawerState();
}

class _ColumnEditDrawerState extends ConsumerState<ColumnEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  ColumnDetail? _columnDetail; // latest column copy (fetched)
  bool _loading = false;
  List<ColumnDetailMembership> _memberships = const [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Only fetch when editing an existing column
    if (widget.columnId != null) {
      _fetchColumnAndMemberships();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchColumnAndMemberships() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final latest = await ref
          .read(churchControllerProvider.notifier)
          .fetchColumn(widget.columnId!);

      setState(() {
        _loading = false;
        _errorMessage = null;
        _columnDetail = latest;
        _memberships = latest.memberships;
        _nameController.text = latest.name;
      });
    } catch (e) {
      // Surface error but keep drawer open
      setState(() {
        _errorMessage = 'Failed to load column details';
      });
      AppSnackbars.showError(
        context,
        title: 'Load failed',
        message: 'Failed to load column details',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final column = cm.Column(
        id: widget.columnId,
        name: _nameController.text.trim(),
        createdAt: _columnDetail?.createdAt ?? DateTime.now(),
        churchId: widget.churchId,
      );

      widget.onSave(column);
      widget.onClose();

      AppSnackbars.showSuccess(
        context,
        title: 'Saved',
        message:
            'Column ${_columnDetail == null ? 'created' : 'updated'} successfully',
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
                AppSnackbars.showSuccess(
                  context,
                  title: 'Deleted',
                  message: 'Column deleted successfully',
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
      title: _columnDetail == null ? 'Add Column' : 'Edit Column',
      subtitle: _columnDetail == null
          ? 'Create a new column'
          : 'Update column information',
      onClose: widget.onClose,
      isLoading: widget.columnId != null && _loading,
      loadingMessage: 'Loading column details...',
      errorMessage: widget.columnId != null ? _errorMessage : null,
      onRetry: widget.columnId != null ? _fetchColumnAndMemberships : null,
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
                // Show ID field only when editing existing column
                if (_columnDetail != null) ...[
                  _FormField(
                    label: 'Column ID',
                    child: Text(
                      _columnDetail!.id.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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

            const SizedBox(height: 16),

            // Memberships listing (read-only)
            if (_columnDetail != null)
              InfoSection(
                title: 'Registered Members (${_memberships.length})',
                titleSpacing: 16,
                children: [
                  if (_memberships.isEmpty)
                    Text(
                      'No members register in this column.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ..._memberships.map(
                      (m) => Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '#${m.membershipId} • ${m.name}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      footer: Row(
        children: [
          if (widget.onDelete != null && _columnDetail != null) ...[
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
              child: Text(_columnDetail == null ? 'Create' : 'Save'),
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
