import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/income_entry.dart';
import '../widgets/income_detail_drawer.dart';
import 'package:palakat_admin/core/models/approval_status.dart';
import 'package:palakat_admin/core/widgets/surface_card.dart';
import 'package:palakat_admin/core/widgets/approval_id_cell.dart';
import 'package:palakat_admin/core/widgets/pagination_bar.dart';
import 'package:palakat_admin/core/models/approver.dart';
import 'package:palakat_admin/core/widgets/date_range_filter.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 5;
  int _page = 0; // zero-based
  DateTimeRange? _dateRange;

  late final List<IncomeEntry> _allEntries;

  @override
  void initState() {
    super.initState();
    _allEntries = _mockEntries();
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

    final filtered = _allEntries.where((e) {
      final q = _searchController.text.trim().toLowerCase();
      final dateStr = DateFormat('y-MM-dd').format(e.date).toLowerCase();
      final approvedStr = e.approvedAt != null
          ? DateFormat('y-MM-dd').format(e.approvedAt!).toLowerCase()
          : '';
      final matchesQuery = q.isEmpty ||
          e.accountId.toLowerCase().contains(q) ||
          e.notes.toLowerCase().contains(q) ||
          e.approvalId.toLowerCase().contains(q) ||
          e.approvalStatus.name.toLowerCase().contains(q) ||
          dateStr.contains(q) ||
          approvedStr.contains(q);
      return matchesQuery && inDateRange(e.date);
    }).toList();

    final total = filtered.length;
    final start = (_page * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    final pageRows = start < end
        ? filtered.sublist(start, end)
        : <IncomeEntry>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Income', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Track and manage all income sources.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Card container similar to Approval page
          SurfaceCard(
            title: 'Income Log',
            subtitle: 'A record of all logged income.',
            child: Column(
              children: [
                // Search + Date Range
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search income...',
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

                // Header
                const _IncomeHeader(),
                const Divider(height: 1),

                // Rows
                ...[
                  for (final e in pageRows)
                    _IncomeRow(entry: e, onTap: () => _showIncomeDetail(e)),
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
    );
  }

  void _showIncomeDetail(IncomeEntry entry) {
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
                child: IncomeDetailDrawer(
                  entry: entry,
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

  List<IncomeEntry> _mockEntries() {
    // Dates align with the reference image
    final base = DateTime(2024, 5, 15);
    return [
      IncomeEntry(
        accountId: 'INC-001',
        date: DateTime(2024, 5, 1),
        notes: 'Tithe - Weekly offering',
        amount: 1200.00,
        approvalId: 'APR-0995',
        approvalStatus: ApprovalStatus.approved,
        approvedAt: DateTime(2024, 5, 2),
        approvers: [
          ApproverDecision(
            name: 'Pastor John',
            positions: const ['Pastor'],
            decision: ApprovalStatus.approved,
            decisionAt: DateTime(2024, 5, 2),
          ),
          ApproverDecision(
            name: 'Administrator',
            positions: const ['Administrator'],
            decision: ApprovalStatus.approved,
            decisionAt: DateTime(2024, 5, 2),
          ),
        ],
      ),
      IncomeEntry(
        accountId: 'INC-002',
        date: DateTime(2024, 5, 1),
        notes: 'Donation - Building fund',
        amount: 350.50,
        approvalId: 'APR-0996',
        approvalStatus: ApprovalStatus.approved,
        approvedAt: DateTime(2024, 5, 3),
        approvers: [
          ApproverDecision(
            name: 'Deacon Mary',
            positions: const ['Deacon'],
            decision: ApprovalStatus.approved,
            decisionAt: DateTime(2024, 5, 3),
          ),
        ],
      ),
      IncomeEntry(
        accountId: 'INC-001',
        date: DateTime(2024, 5, 8),
        notes: 'Tithe - Weekly offering',
        amount: 1350.00,
        approvalId: 'APR-0997',
        approvalStatus: ApprovalStatus.pending,
        approvedAt: null,
        approvers: [
          ApproverDecision(
            name: 'Pastor John',
            positions: const ['Pastor'],
            decision: ApprovalStatus.pending,
          ),
        ],
      ),
      IncomeEntry(
        accountId: 'INC-003',
        date: DateTime(2024, 5, 10),
        notes: 'Fundraiser - Bake sale',
        amount: 500.00,
        approvalId: 'APR-0998',
        approvalStatus: ApprovalStatus.rejected,
        approvedAt: DateTime(2024, 5, 11),
        approvers: [
          ApproverDecision(
            name: 'Elder Bob',
            positions: const ['Elder'],
            decision: ApprovalStatus.rejected,
            decisionAt: DateTime(2024, 5, 11),
          ),
        ],
      ),
      IncomeEntry(
        accountId: 'INC-001',
        date: base,
        notes: 'Tithe - Weekly offering',
        amount: 1250.00,
        approvalId: 'APR-1001',
        approvalStatus: ApprovalStatus.approved,
        approvedAt: DateTime(2024, 5, 16),
        approvers: [
          ApproverDecision(
            name: 'Pastor John',
            positions: const ['Pastor'],
            decision: ApprovalStatus.approved,
            decisionAt: DateTime(2024, 5, 16),
          ),
        ],
      ),
      // Additional rows for pagination demo
      for (int i = 1; i <= 3; i++)
        IncomeEntry(
          accountId: 'INC-00${(i % 3) + 1}',
          date: base.subtract(Duration(days: i + 10)),
          notes: 'Additional record $i',
          amount: 300 + (i * 25.75),
          approvalId: 'APR-10${i + 1}',
          approvalStatus: i % 2 == 0
              ? ApprovalStatus.pending
              : ApprovalStatus.approved,
          approvedAt: i % 2 == 0 ? null : base.subtract(Duration(days: i + 9)),
          approvers: [
            ApproverDecision(
              name: 'Administrator',
              positions: const ['Administrator'],
              decision: i % 2 == 0
                  ? ApprovalStatus.pending
                  : ApprovalStatus.approved,
              decisionAt: i % 2 == 0
                  ? null
                  : base.subtract(Duration(days: i + 9)),
            ),
          ],
        ),
    ];
  }

  
}

class _IncomeHeader extends StatelessWidget {
  const _IncomeHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Account ID'), flex: 2, style: style),
          _cell(const Text('Date'), flex: 2, style: style),
          _cell(const Text('Approval ID'), flex: 4, style: style),
          _cell(const Text('Notes'), flex: 6, style: style),
          _cell(const Text('Amount'), flex: 2, style: style, alignEnd: true),
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

class _IncomeRow extends StatelessWidget {
  final IncomeEntry entry;
  final VoidCallback? onTap;

  const _IncomeRow({required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Workaround to ensure correct peso symbol rendering across platforms
    final amountText = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱ ',
    ).format(entry.amount);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            _cell(Text(entry.accountId), flex: 2),
            _cell(Text(DateFormat('y-MM-dd').format(entry.date)), flex: 2),
            _cell(
              ApprovalIdCell(
                approvedAt: entry.approvedAt,
                approvalId: entry.approvalId,
              ),
              flex: 4,
            ),
            _cell(Text(entry.notes, overflow: TextOverflow.ellipsis), flex: 6),
            _cell(
              Text(
                amountText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              flex: 2,
              alignEnd: true,
            ),
          ],
        ),
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
