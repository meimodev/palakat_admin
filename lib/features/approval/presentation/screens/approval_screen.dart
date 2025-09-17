import 'package:flutter/material.dart';
import 'package:palakat_admin/core/widgets/surface_card.dart';
 

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Approvals', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Configure approval routing rules.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            SurfaceCard(
              title: 'Approval Routing',
              subtitle: 'Map approval types to approver positions.',
              trailing: FilledButton.icon(
                onPressed: () => _openRouteEditor(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Route'),
              ),
              child: Column(
                children: [
                  _RouteSection(
                    title: 'Income',
                    routes: _routes['Income'] ?? const [],
                    onTapRoute: (r) => _openRouteEditor(context, route: r),
                  ),
                  const SizedBox(height: 8),
                  _RouteSection(
                    title: 'Expense',
                    routes: _routes['Expense'] ?? const [],
                    onTapRoute: (r) => _openRouteEditor(context, route: r),
                  ),
                  const SizedBox(height: 8),
                  _RouteSection(
                    title: 'Document',
                    routes: _routes['Document'] ?? const [],
                    onTapRoute: (r) => _openRouteEditor(context, route: r),
                  ),
                  const SizedBox(height: 8),
                  _RouteSection(
                    title: 'Service',
                    routes: _routes['Service'] ?? const [],
                    onTapRoute: (r) => _openRouteEditor(context, route: r),
                  ),
                  const SizedBox(height: 8),
                  _RouteSection(
                    title: 'Announcement',
                    routes: _routes['Announcement'] ?? const [],
                    onTapRoute: (r) => _openRouteEditor(context, route: r),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mock routing data matching the design
  final Map<String, List<ApprovalRoute>> _routes = {
    'Income': [
      ApprovalRoute(
        name: 'General Income',
        type: 'Income',
        positions: const ['Senior Pastor', 'Administrator'],
      ),
      ApprovalRoute(
        name: 'Special Offering',
        type: 'Income',
        positions: const ['Senior Pastor', 'Deacon'],
      ),
      ApprovalRoute(
        name: 'Fundraiser Proceeds',
        type: 'Income',
        positions: const ['Administrator', 'Youth Leader'],
      ),
    ],
    'Expense': const [],
    'Document': const [],
    'Service': const [],
    'Announcement': const [],
  };

  

  Future<void> _openRouteEditor(
    BuildContext context, {
    ApprovalRoute? route,
  }) async {
    final result = await showGeneralDialog<ApprovalRoute?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      pageBuilder: (ctx, anim, secAnim) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, anim, secAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Stack(
          children: [
            // Dimmed background
            Opacity(
              opacity: 0.4 * curved.value,
              child: ModalBarrier(dismissible: true, color: Colors.black54),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: SizedBox(
                  width: 420,
                  height: double.infinity,
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 8,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: _RouteEditorSheet(
                      initial: route,
                      onCancel: () => Navigator.of(ctx).pop(),
                      onSubmit: (value) => Navigator.of(ctx).pop(value),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );

    if (result != null) {
      // Save or update in-memory mock state
      setState(() {
        final section = result.type;
        final list = List<ApprovalRoute>.from(_routes[section] ?? []);
        final idx = list.indexWhere((e) => e.id == result.id);
        if (idx == -1) {
          list.add(result);
        } else {
          list[idx] = result;
        }
        _routes[section] = list;
      });
    }
  }

  
}


class _RouteSection extends StatelessWidget {
  final String title;
  final List<ApprovalRoute> routes;
  final ValueChanged<ApprovalRoute> onTapRoute;

  const _RouteSection({
    required this.title,
    required this.routes,
    required this.onTapRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            if (routes.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('No routes configured'),
                ),
              )
            else ...[
              for (int i = 0; i < routes.length; i++) ...[
                _RouteRow(route: routes[i], onTap: () => onTapRoute(routes[i])),
                if (i != routes.length - 1) const Divider(height: 32),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final ApprovalRoute route;
  final VoidCallback onTap;

  const _RouteRow({required this.route, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Row(
          children: [
            Expanded(child: Text(route.name, style: theme.textTheme.bodyLarge)),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in route.positions)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(p, style: theme.textTheme.labelLarge),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApprovalRoute {
  final String id;
  final String name;
  final String type; // Section, e.g., Income, Expense
  final List<String> positions;

  ApprovalRoute({
    String? id,
    required this.name,
    required this.type,
    required this.positions,
  }) : id = id ?? UniqueKey().toString();

  ApprovalRoute copyWith({
    String? name,
    String? type,
    List<String>? positions,
  }) => ApprovalRoute(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
    positions: positions ?? this.positions,
  );
}

class _RouteEditorSheet extends StatefulWidget {
  final ApprovalRoute? initial;
  final VoidCallback onCancel;
  final ValueChanged<ApprovalRoute> onSubmit;

  const _RouteEditorSheet({
    required this.initial,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<_RouteEditorSheet> createState() => _RouteEditorSheetState();
}

class _RouteEditorSheetState extends State<_RouteEditorSheet> {
  late final TextEditingController _nameCtrl;
  String _type = 'Income';
  final List<String> _positions = [];
  final List<String> _allTypes = const [
    'Income',
    'Expense',
    'Document',
    'Service',
    'Announcement',
  ];
  final List<String> _availablePositions = const [
    'Senior Pastor',
    'Administrator',
    'Deacon',
    'Youth Leader',
    'Treasurer',
    'Secretary',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _type = widget.initial?.type ?? 'Income';
    _positions.clear();
    _positions.addAll(widget.initial?.positions ?? const []);

    // Add listener to make the button reactive to text changes
    _nameCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.initial == null
                          ? 'Add New Approval Route'
                          : 'Edit Approval Route',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create a new approval routing rule.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Approval Name
          Text('Approval Name', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g. General Income',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          // Approval Type
          Text('Approval Type', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _type,
            items: _allTypes
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? _type),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),

          const SizedBox(height: 16),

          // Approver Positions
          Text('Approver Positions', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_positions.length),
                  // Force rebuild when positions change
                  value: null,
                  // Always null to allow selection
                  items: _availablePositions
                      .where((p) => !_positions.contains(p))
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _positions.add(v);
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Add a position...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in _positions)
                Chip(
                  label: Text(p),
                  onDeleted: () => setState(() => _positions.remove(p)),
                ),
            ],
          ),

          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: _nameCtrl.text.trim().isEmpty || _positions.isEmpty
                    ? null
                    : () {
                        final result =
                            widget.initial?.copyWith(
                              name: _nameCtrl.text.trim(),
                              type: _type,
                              positions: List.of(_positions),
                            ) ??
                            ApprovalRoute(
                              name: _nameCtrl.text.trim(),
                              type: _type,
                              positions: List.of(_positions),
                            );
                        widget.onSubmit(result);
                      },
                child: Text(
                  widget.initial == null ? 'Create Route' : 'Save Changes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

 
