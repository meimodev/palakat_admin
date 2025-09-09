import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/document.dart';
import '../../../../core/widgets/surface_card.dart';
// Removed pagination import as the card no longer paginates
import '../../../../core/widgets/side_drawer.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen({super.key});

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  late final List<Document> _allDocuments;
  String _identityNumberTemplate = 'DOC-2024-001';

  @override
  void initState() {
    super.initState();
    _allDocuments = _mockDocuments();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pageRows = _allDocuments;

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Document Settings', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Manage document identity numbers and view recent approvals.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Document Identity Number card
            SurfaceCard(
              title: 'Document Identity Number',
              subtitle: 'Current template used for new documents.',
              trailing: FilledButton.icon(
                onPressed: _openIdentityDrawer,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      'Template:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _identityNumberTemplate,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recently Approved Documents Section
            SurfaceCard(
              title: 'Recently Approved Documents',
              subtitle: 'A list of the most recently approved documents.',
              child: Column(
                children: [
                  // Header
                  const _DocumentHeader(),
                  const Divider(height: 1),

                  // Rows
                  ...[for (final doc in pageRows) _DocumentRow(document: doc)],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openIdentityDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      pageBuilder: (ctx, anim, secAnim) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Stack(
          children: [
            Opacity(
              opacity: 0.4 * curved.value,
              child: const ModalBarrier(
                dismissible: true,
                color: Colors.black54,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: _IdentityNumberEditDrawer(
                  currentTemplate: _identityNumberTemplate,
                  onSave: (val) {
                    setState(() => _identityNumberTemplate = val);
                    Navigator.of(ctx).pop();
                  },
                  onClose: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  List<Document> _mockDocuments() {
    return [
      Document(
        id: '1',
        name: 'Financial Report Q1 2024',
        identityNumber: 'FR-2024-Q1-001',
        approvedDate: DateTime(2024, 3, 15),
        type: 'Financial Report',
        status: 'Approved',
      ),
      Document(
        id: '2',
        name: 'Budget Proposal 2024',
        identityNumber: 'BP-2024-002',
        approvedDate: DateTime(2024, 3, 12),
        type: 'Budget Proposal',
        status: 'Approved',
      ),
      Document(
        id: '3',
        name: 'Church Event Plan',
        identityNumber: 'CEP-2024-003',
        approvedDate: DateTime(2024, 3, 10),
        type: 'Event Plan',
        status: 'Approved',
      ),
      Document(
        id: '4',
        name: 'Membership Report',
        identityNumber: 'MR-2024-004',
        approvedDate: DateTime(2024, 3, 8),
        type: 'Report',
        status: 'Approved',
      ),
      Document(
        id: '5',
        name: 'Facility Maintenance Plan',
        identityNumber: 'FMP-2024-005',
        approvedDate: DateTime(2024, 3, 5),
        type: 'Maintenance Plan',
        status: 'Approved',
      ),
      Document(
        id: '6',
        name: 'Annual Ministry Report',
        identityNumber: 'AMR-2024-006',
        approvedDate: DateTime(2024, 3, 3),
        type: 'Ministry Report',
        status: 'Approved',
      ),
      Document(
        id: '7',
        name: 'Youth Program Proposal',
        identityNumber: 'YPP-2024-007',
        approvedDate: DateTime(2024, 3, 1),
        type: 'Program Proposal',
        status: 'Approved',
      ),
      Document(
        id: '8',
        name: 'Community Outreach Report',
        identityNumber: 'REP-CO-2024-004',
        approvedDate: DateTime(2024, 2, 28),
        type: 'Report',
        status: 'Approved',
      ),
    ];
  }
}

class _DocumentHeader extends StatelessWidget {
  const _DocumentHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Document Name'), flex: 3, style: style),
          _cell(const Text('Identity Number'), flex: 2, style: style),
          _cell(const Text('Type'), flex: 2, style: style),
          _cell(const Text('Date'), flex: 2, style: style),
        ],
      ),
    );
  }

  Widget _cell(
    Widget child, {
    int flex = 1,
    TextStyle? style,
    bool alignEnd = false,
  }) {
    return Expanded(
      flex: flex,
      child: DefaultTextStyle(
        style: style ?? const TextStyle(),
        child: Align(
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final Document document;

  const _DocumentRow({required this.document});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          _cell(Text(document.name, overflow: TextOverflow.ellipsis, style: textStyle), flex: 3),
          _cell(Text(document.identityNumber, style: textStyle), flex: 2),
          _cell(Text(document.type, style: textStyle), flex: 2),
          _cell(Text(DateFormat('y-MM-dd').format(document.approvedDate), style: textStyle), flex: 2),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1, bool alignEnd = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      ),
    );
  }
}

class _IdentityNumberEditDrawer extends StatefulWidget {
  final String currentTemplate;
  final ValueChanged<String> onSave;
  final VoidCallback onClose;

  const _IdentityNumberEditDrawer({
    required this.currentTemplate,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<_IdentityNumberEditDrawer> createState() => _IdentityNumberEditDrawerState();
}

class _IdentityNumberEditDrawerState extends State<_IdentityNumberEditDrawer> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTemplate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SideDrawer(
      title: 'Edit Document Identity Number',
      subtitle: 'Update the template used for new documents',
      onClose: widget.onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Template',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'e.g., DOC-2024-001',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Changing the identity number template may cause certain numbers to be skipped.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: () => widget.onSave(_controller.text.trim()),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
