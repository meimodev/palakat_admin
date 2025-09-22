import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/activity.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/date_range_filter.dart';
import '../widgets/activity_detail_view.dart';
import '../../../../core/widgets/supervisor_chip.dart';
import '../../../../core/widgets/status_chip.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

// --- Approver model and chip for Activities (mirrors approvals list UI) ---

enum _ActApproverDecision { pending, approved, rejected }

class _ActApprover {
  final String name;
  final _ActApproverDecision decision;
  final DateTime? decisionAt;

  _ActApprover(this.name, this.decision, [this.decisionAt]);
}

List<_ActApprover> _approversFor(Activity a) {
  // Mocked approvers per activity, similar to approvals list behavior
  // You can later replace this with real data from backend
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

class _ActivityApproverChip extends StatelessWidget {
  final _ActApprover approver;

  const _ActivityApproverChip({required this.approver});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;
    String? dateText;
    switch (approver.decision) {
      case _ActApproverDecision.approved:
        icon = Icons.check;
        color = Colors.green;
        if (approver.decisionAt != null) {
          final d = approver.decisionAt!;
          dateText =
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        }
        break;
      case _ActApproverDecision.rejected:
        icon = Icons.close;
        color = Colors.red;
        if (approver.decisionAt != null) {
          final d = approver.decisionAt!;
          dateText =
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        }
        break;
      case _ActApproverDecision.pending:
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
      child: Wrap(
        spacing: 3,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.person, size: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(approver.name, style: theme.textTheme.labelMedium),
              if (dateText != null) ...[
                Text(
                  dateText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          Icon(icon, size: 14, color: color),
        ],
      ),
    );
  }
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 5;
  int _page = 0; // zero-based
  DateTimeRange? _dateRange;

  late final List<Activity> _allActivities;

  @override
  void initState() {
    super.initState();
    _allActivities = _generateMockActivities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool inDateRange(DateTime d) {
      if (_dateRange == null) return true;
      final s = DateUtils.dateOnly(_dateRange!.start);
      final e = DateUtils.dateOnly(_dateRange!.end);
      final dd = DateUtils.dateOnly(d);
      final afterStart = dd.isAtSameMomentAs(s) || dd.isAfter(s);
      final beforeEnd = dd.isAtSameMomentAs(e) || dd.isBefore(e);
      return afterStart && beforeEnd;
    }

    final filtered = _allActivities.where((activity) {
      final q = _searchController.text.trim().toLowerCase();
      final startDateStr = DateFormat(
        'y-MM-dd',
      ).format(activity.startDate).toLowerCase();
      final endDateStr = activity.endDate != null
          ? DateFormat('y-MM-dd').format(activity.endDate!).toLowerCase()
          : '';

      final matchesQuery =
          q.isEmpty ||
          activity.id.toLowerCase().contains(q) ||
          activity.title.toLowerCase().contains(q) ||
          activity.description.toLowerCase().contains(q) ||
          activity.type.displayName.toLowerCase().contains(q) ||
          activity.status.displayName.toLowerCase().contains(q) ||
          activity.supervisor.toLowerCase().contains(q) ||
          (activity.location?.toLowerCase().contains(q) ?? false) ||
          startDateStr.contains(q) ||
          endDateStr.contains(q) ||
          activity.participants.any((p) => p.toLowerCase().contains(q));

      return matchesQuery && inDateRange(activity.startDate);
    }).toList();

    final total = filtered.length;
    final start = (_page * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    final pageRows = start < end ? filtered.sublist(start, end) : <Activity>[];

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activities', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Monitor and manage all church activities.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: 'Activities',
              subtitle: 'Manage church activities and events.',
              child: Column(
                children: [
                  // Search + Date Range
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search activities...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {
                            _page = 0;
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DateRangeFilter(
                        value: _dateRange,
                        onChanged: (r) => setState(() {
                          _dateRange = r;
                          _page = 0;
                        }),
                        onClear: () => setState(() {
                          _dateRange = null;
                          _page = 0;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Header Row (table-like)
                  _ActivitiesHeader(),
                  const Divider(height: 1),

                  // Rows
                  ...[
                    for (final activity in pageRows)
                      _ActivityRow(
                        activity: activity,
                        onTap: () => _showActivityDetail(activity),
                      ),
                  ],

                  const SizedBox(height: 8),
                  // Pagination
                  PaginationBar(
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
          ],
        ),
      ),
    );
  }

  void _showActivityDetail(Activity? activity) {
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
                child: ActivityDetailView(
                  activity: activity!,
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

  List<Activity> _generateMockActivities() {
    final now = DateTime.now();
    return [
      Activity(
        id: 'ACT-1001',
        title: 'Sunday Morning Worship',
        description: 'Weekly worship service with sermon and communion',
        type: ActivityType.service,
        status: ActivityStatus.ongoing,
        startDate: now.subtract(const Duration(days: 0)),
        endDate: now
            .subtract(const Duration(days: 0))
            .add(const Duration(hours: 2)),
        supervisor: 'Pastor John',
        supervisorPositions: ['Senior Pastor', 'Head of Worship'],
        participants: ['Pastor John', 'Worship Team', 'Congregation'],
        location: 'Main Sanctuary',
        notes: 'Special guest speaker this week',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      Activity(
        id: 'ACT-1002',
        title: 'Youth Bible Study',
        description: 'Weekly Bible study for teenagers and young adults',
        type: ActivityType.service,
        status: ActivityStatus.planned,
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 2, hours: 1, minutes: 30)),
        supervisor: 'Youth Pastor Sarah',
        supervisorPositions: ['Youth Pastor', 'Education Coordinator'],
        participants: ['Youth Pastor Sarah', 'Teen Group'],
        location: 'Youth Room',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Activity(
        id: 'ACT-1003',
        title: 'Community Food Drive',
        description: 'Monthly food collection for local food bank',
        type: ActivityType.event,
        status: ActivityStatus.completed,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 8)),
        supervisor: 'Deacon Mary',
        supervisorPositions: ['Deacon', 'Outreach Coordinator'],
        participants: ['Deacon Mary', 'Volunteers', 'Community Members'],
        location: 'Church Parking Lot',
        notes: 'Collected 500 pounds of food items',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      Activity(
        id: 'ACT-1004',
        title: 'Church Budget Update',
        description: 'Important announcement regarding church budget changes',
        type: ActivityType.announcement,
        status: ActivityStatus.completed,
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now
            .subtract(const Duration(days: 15))
            .add(const Duration(hours: 2)),
        supervisor: 'Administrator Bob',
        supervisorPositions: ['Administrator', 'Financial Secretary'],
        participants: ['Pastor John', 'Deacon Mary', 'Treasurer', 'Secretary'],
        location: 'Conference Room',
        notes: 'Discussed budget and upcoming events',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Activity(
        id: 'ACT-1005',
        title: 'Christmas Concert',
        description: 'Annual Christmas musical performance',
        type: ActivityType.event,
        status: ActivityStatus.planned,
        startDate: now.add(const Duration(days: 45)),
        endDate: now.add(const Duration(days: 45, hours: 3)),
        supervisor: 'Music Director',
        supervisorPositions: ['Music Director', 'Worship Leader'],
        participants: ['Choir', 'Orchestra', 'Soloists'],
        location: 'Main Sanctuary',
        notes: 'Rehearsals start next month',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Activity(
        id: 'ACT-1006',
        title: 'Fellowship Dinner',
        description: 'Monthly potluck dinner for church members',
        type: ActivityType.event,
        status: ActivityStatus.planned,
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 7, hours: 2)),
        supervisor: 'Fellowship Committee',
        supervisorPositions: ['Fellowship Coordinator', 'Event Planner'],
        participants: ['Church Members', 'Families'],
        location:
            'Fellowship Hall - Main dining area with kitchen facilities and seating for up to 200 people',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}

class _ActivitiesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Title'), flex: 3, style: textStyle),
          _cell(const Text('Type'), flex: 2, style: textStyle),
          _cell(const Text('Start Date'), flex: 2, style: textStyle),
          _cell(const Text('Supervisor'), flex: 3, style: textStyle),
          _cell(const Text('Approver'), flex: 3, style: textStyle),
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

class _ActivityRow extends StatelessWidget {
  final Activity activity;
  final VoidCallback onTap;

  const _ActivityRow({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hoverColor = theme.colorScheme.primary.withValues(alpha: 0.04);
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              hoverColor: hoverColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _cell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      flex: 3,
                    ),
                    _cell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _TypeChip(type: activity.type),
                      ),
                      flex: 2,
                    ),
                    _cell(
                      Text(
                        _formatDate(activity.startDate),
                        style: theme.textTheme.bodyMedium,
                      ),
                      flex: 2,
                    ),
                    _cell(
                      flex: 3,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SupervisorChip(
                          name: activity.supervisor,
                          positions: activity.supervisorPositions,
                        ),
                      ),
                    ),
                    _cell(
                      Wrap(
                        spacing: 8,
                        direction: Axis.vertical,
                        runSpacing: 8,
                        children: [
                          for (final a in _approversFor(activity))
                            _ActivityApproverChip(approver: a),
                        ],
                      ),
                      flex: 3,
                    ),
                    _cell(
                      Builder(
                        builder: (context) {
                          // Derive overall approval status from approvers
                          // - Rejected if any approver rejected
                          // - Approved if all approvers approved
                          // - Unconfirmed otherwise
                          final approvers = _approversFor(activity);
                          final hasRejected = approvers.any(
                            (a) => a.decision == _ActApproverDecision.rejected,
                          );
                          final allApproved = approvers.isNotEmpty && approvers.every(
                            (a) => a.decision == _ActApproverDecision.approved,
                          );

                          final (bg, fg, label, icon) = hasRejected
                              ? (
                                  Colors.red.shade50,
                                  Colors.red.shade700,
                                  'Rejected',
                                  Icons.cancel,
                                )
                              : (allApproved
                                  ? (
                                      Colors.green.shade50,
                                      Colors.green.shade700,
                                      'Approved',
                                      Icons.check_circle,
                                    )
                                  : (
                                      Colors.orange.shade50,
                                      Colors.orange.shade700,
                                      'Unconfirmed',
                                      Icons.pending,
                                    ));
                          return StatusChip(
                            label: label,
                            background: bg,
                            foreground: fg,
                            icon: icon,
                          );
                        },
                      ),
                      flex: 2,
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
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
  final ActivityType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon) = switch (type) {
      ActivityType.service => (Colors.teal, Icons.handshake),
      ActivityType.event => (Colors.red, Icons.event),
      ActivityType.announcement => (Colors.orange, Icons.campaign),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            type.displayName,
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}


