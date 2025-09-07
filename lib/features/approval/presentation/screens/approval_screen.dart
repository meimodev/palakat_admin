import 'package:flutter/material.dart';

import '../widgets/approval_detail_drawer.dart';

class ApprovalScreen extends StatefulWidget {
  const ApprovalScreen({super.key});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 5;
  int _page = 0; // zero-based

  late final List<ApprovalRequest> _allRequests;

  @override
  void initState() {
    super.initState();
    _allRequests = _generateMockRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = _allRequests.where((r) {
      final q = _searchController.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return r.description.toLowerCase().contains(q) ||
          r.type.toLowerCase().contains(q) ||
          r.requester.toLowerCase().contains(q) ||
          r.authorizers.any((a) => a.name.toLowerCase().contains(q));
    }).toList();

    final total = filtered.length;
    final start = (_page * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    final pageRows = start < end
        ? filtered.sublist(start, end)
        : <ApprovalRequest>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Approvals', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          _ApprovalCard(
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search approvals...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() {
                    _page = 0; // reset to first page on new search
                  }),
                ),
                const SizedBox(height: 12),

                // Header Row (table-like)
                _RequestsHeader(),
                const Divider(height: 1),

                // Rows
                ...[
                  for (final req in pageRows)
                    _RequestRow(
                      req: req,
                      onTap: () => _showApprovalDetail(req),
                    ),
                ],

                const SizedBox(height: 8),
                // Pagination bar
                _PaginationBar(
                  showingCount: pageRows.length,
                  totalCount: total,
                  rowsPerPage: _rowsPerPage,
                  page: _page,
                  pageCount: (total / _rowsPerPage).ceil().clamp(1, 9999),
                  onRowsPerPageChanged: (v) => setState(() {
                    _rowsPerPage = v;
                    _page = 0;
                  }),
                  onPrev: () => setState(() {
                    if (_page > 0) _page -= 1;
                  }),
                  onNext: () => setState(() {
                    final maxPage = (total / _rowsPerPage).ceil() - 1;
                    if (_page < maxPage) _page += 1;
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _ApprovalCard(
            title: 'Approval Routing',
            subtitle: 'Map approval types to authorizer positions.',
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

  void _showApprovalDetail(ApprovalRequest request) {
    showGeneralDialog(
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
                child: ApprovalDetailDrawer(
                  request: request,
                  onClose: () => Navigator.of(ctx).pop(),
                  onUpdate: (updatedRequest) {
                    // Update the request in the list
                    setState(() {
                      final index = _allRequests.indexWhere(
                        (r) =>
                            r.description == request.description &&
                            r.date == request.date,
                      );
                      if (index != -1) {
                        _allRequests[index] = updatedRequest;
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

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

  List<ApprovalRequest> _generateMockRequests() {
    final now = DateTime(2024, 5, 18);
    return [
      ApprovalRequest(
        id: 'APR-1001',
        date: now,
        description: 'New sound system purchase',
        type: 'Expense',
        requester: 'John Doe',
        authorizers: [Authorizer('Pastor John', AuthorizerDecision.pending)],
        status: RequestStatus.pending,
      ),
      ApprovalRequest(
        id: 'APR-1000',
        date: now.subtract(const Duration(days: 1)),
        description: 'Youth group event budget',
        type: 'Expense',
        requester: 'Jane Smith',
        authorizers: [
          Authorizer(
            'Pastor John',
            AuthorizerDecision.approved,
            now.subtract(const Duration(days: 1, hours: 3)),
          ),
          Authorizer(
            'Deacon Mary',
            AuthorizerDecision.approved,
            now.subtract(const Duration(days: 1, hours: 1)),
          ),
        ],
        status: RequestStatus.approved,
      ),
      ApprovalRequest(
        id: 'APR-0999',
        date: now.subtract(const Duration(days: 2)),
        description: 'Building maintenance contract',
        type: 'Document',
        requester: 'Sam Wilson',
        authorizers: [
          Authorizer(
            'Pastor John',
            AuthorizerDecision.approved,
            now.subtract(const Duration(days: 2, hours: 6)),
          ),
          Authorizer(
            'Admin Bob',
            AuthorizerDecision.rejected,
            now.subtract(const Duration(days: 2, hours: 2)),
          ),
        ],
        status: RequestStatus.rejected,
        note: 'Budget constraints',
      ),
      ApprovalRequest(
        id: 'APR-0998',
        date: now.subtract(const Duration(days: 3)),
        description: 'Website redesign proposal',
        type: 'Service',
        requester: 'Alice Johnson',
        authorizers: [Authorizer('Deacon Mary', AuthorizerDecision.pending)],
        status: RequestStatus.pending,
      ),
      ApprovalRequest(
        id: 'APR-0997',
        date: now.subtract(const Duration(days: 4)),
        description: 'Mission trip funding',
        type: 'Income',
        requester: 'Chris Lee',
        authorizers: [Authorizer(
          'Pastor John',
          AuthorizerDecision.approved,
          now.subtract(const Duration(days: 4, hours: 4)),
        )],
        status: RequestStatus.approved,
      ),
    ];
  }
}

class _ApprovalCard extends StatelessWidget {
  final Widget child;
  final Widget? trailing;
  final String? title;
  final String? subtitle;
  const _ApprovalCard({
    required this.child,
    this.trailing,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RequestsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('ID'), flex: 2, style: textStyle),
          _cell(const Text('Date'), flex: 2, style: textStyle),
          _cell(const Text('Description'), flex: 4, style: textStyle),
          _cell(const Text('Type'), flex: 2, style: textStyle),
          _cell(const Text('Requester'), flex: 2, style: textStyle),
          _cell(const Text('Authorizer'), flex: 3, style: textStyle),
          _cell(const Text('Status'), flex: 2, style: textStyle),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1, TextStyle? style}) => Expanded(
    flex: flex,
    child: DefaultTextStyle.merge(style: style, child: child),
  );
}

class _RequestRow extends StatelessWidget {
  final ApprovalRequest req;
  final VoidCallback onTap;
  const _RequestRow({required this.req, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _cell(
                  Text(
                    req.id,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  flex: 2,
                ),
                _cell(
                  Text(
                    _formatDate(req.date),
                    style: theme.textTheme.bodyMedium,
                  ),
                  flex: 2,
                ),
                _cell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (req.note != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          req.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  flex: 4,
                ),
                _cell(_TypeChip(label: req.type), flex: 2),
                _cell(Text(req.requester), flex: 2),
                _cell(
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final a in req.authorizers)
                        _AuthorizerChip(authorizer: a),
                    ],
                  ),
                  flex: 3,
                ),
                _cell(_StatusChip(status: req.status), flex: 2),

              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Widget _cell(Widget child, {int flex = 1}) =>
      Expanded(flex: flex, child: child);
}

class _TypeChip extends StatelessWidget {
  final String label;
  const _TypeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(label, style: theme.textTheme.labelMedium),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final RequestStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AuthorizerChip extends StatelessWidget {
  final Authorizer authorizer;
  const _AuthorizerChip({required this.authorizer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;
    String? dateText;
    switch (authorizer.decision) {
      case AuthorizerDecision.approved:
        icon = Icons.check;
        color = Colors.green;
        if (authorizer.decisionAt != null) {
          final d = authorizer.decisionAt!;
          dateText = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        }
        break;
      case AuthorizerDecision.rejected:
        icon = Icons.close;
        color = Colors.red;
        if (authorizer.decisionAt != null) {
          final d = authorizer.decisionAt!;
          dateText = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        }
        break;
      case AuthorizerDecision.pending:
        icon = Icons.watch_later_outlined;
        color = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.badge, size: 16),
          const SizedBox(width: 6),
          Text(authorizer.name, style: theme.textTheme.labelMedium),
          if (dateText != null) ...[
            const SizedBox(width: 6),
            Text(
              dateText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(width: 6),
          Icon(icon, size: 14, color: color),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int showingCount;
  final int totalCount;
  final int rowsPerPage;
  final int page;
  final int pageCount;
  final ValueChanged<int> onRowsPerPageChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _PaginationBar({
    required this.showingCount,
    required this.totalCount,
    required this.rowsPerPage,
    required this.page,
    required this.pageCount,
    required this.onRowsPerPageChanged,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Showing $showingCount of $totalCount requests'),
          Row(
            children: [
              Row(
                children: [
                  const Text('Rows per page'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: rowsPerPage,
                    items: const [5, 10, 20]
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text('$e')),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onRowsPerPageChanged(v);
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Text('Page ${page + 1} of $pageCount'),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: onPrev, child: const Text('Previous')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: onNext, child: const Text('Next')),
            ],
          ),
        ],
      ),
    );
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

          // Authorized Positions
          Text('Authorized Positions', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(
                    _positions.length,
                  ), // Force rebuild when positions change
                  value: null, // Always null to allow selection
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
            children: [
              OutlinedButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
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

enum RequestStatus { pending, approved, rejected }

class ApprovalRequest {
  final String id;
  final DateTime date;
  final String description;
  final String type;
  final String requester;
  final List<Authorizer> authorizers;
  final RequestStatus status;
  final String? note;
  ApprovalRequest({
    required this.id,
    required this.date,
    required this.description,
    required this.type,
    required this.requester,
    required this.authorizers,
    required this.status,
    this.note,
  });
}

class Authorizer {
  final String name;
  final AuthorizerDecision decision;
  final DateTime? decisionAt;
  Authorizer(this.name, this.decision, [this.decisionAt]);
}

enum AuthorizerDecision { pending, approved, rejected }
