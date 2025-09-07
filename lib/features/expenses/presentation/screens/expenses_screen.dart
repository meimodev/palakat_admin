import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/expense_entry.dart';
import '../widgets/expense_detail_drawer.dart';
import 'package:palakat_admin/core/models/approval_status.dart';
import 'package:palakat_admin/core/widgets/surface_card.dart';
import 'package:palakat_admin/core/widgets/approval_id_cell.dart';
import 'package:palakat_admin/core/widgets/pagination_bar.dart';
import 'package:palakat_admin/core/models/approver.dart';
import 'package:palakat_admin/core/widgets/date_range_filter.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

 

 

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 5;
  int _page = 0; // zero-based
  DateTimeRange? _dateRange;

  late final List<ExpenseEntry> _allEntries;

  @override
  void initState() {
    super.initState();
    _allEntries = _mockEntries();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial = _dateRange ?? DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      initialDateRange: initial,
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _page = 0;
      });
    }
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
      if (q.isEmpty) return true;
      final dateStr = DateFormat('y-MM-dd').format(e.date).toLowerCase();
      final approvedStr = e.approvedAt != null
          ? DateFormat('y-MM-dd').format(e.approvedAt!).toLowerCase()
          : '';
      final matchesQuery = e.accountId.toLowerCase().contains(q) ||
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
    final pageRows = start < end ? filtered.sublist(start, end) : <ExpenseEntry>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expenses', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Track and manage all expense records.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          SurfaceCard(
            title: 'Expense Log',
            subtitle: 'A record of all logged expenses.',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search expenses...',
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

                const _ExpensesHeader(),
                const Divider(height: 1),

                ...[
                  for (final e in pageRows)
                    _ExpenseRow(
                      entry: e,
                      onTap: () => _showExpenseDetail(e),
                    ),
                ],

                const SizedBox(height: 8),
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

  void _showExpenseDetail(ExpenseEntry entry) {
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
              child: const ModalBarrier(dismissible: true, color: Colors.black54),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: ExpenseDetailDrawer(
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

  List<ExpenseEntry> _mockEntries() {
    final base = DateTime(2024, 5, 15);
    return [
      ExpenseEntry(
        accountId: 'EXP-101',
        date: DateTime(2024, 5, 2),
        notes: 'Supplies - Office paper',
        amount: 120.00,
        approvalId: 'APR-2001',
        approvalStatus: ApprovalStatus.approved,
        approvedAt: DateTime(2024, 5, 3),
        approvers:  [
          ApproverDecision(name: 'Pastor John', positions: const ['Pastor'], decision: ApprovalStatus.approved, decisionAt: DateTime(2024, 5, 3)),
        ],
      ),
      ExpenseEntry(
        accountId: 'EXP-102',
        date: DateTime(2024, 5, 3),
        notes: 'Utility - Electricity bill',
        amount: 3500.75,
        approvalId: 'APR-2002',
        approvalStatus: ApprovalStatus.pending,
        approvedAt: null,
        approvers: const [
          ApproverDecision(name: 'Administrator', positions: const ['Administrator'], decision: ApprovalStatus.pending),
        ],
      ),
      ExpenseEntry(
        accountId: 'EXP-103',
        date: DateTime(2024, 5, 6),
        notes: 'Event - Youth retreat snacks',
        amount: 980.50,
        approvalId: 'APR-2003',
        approvalStatus: ApprovalStatus.rejected,
        approvedAt: DateTime(2024, 5, 7),
        approvers:  [
          ApproverDecision(name: 'Deacon Mary', positions: const ['Deacon'], decision: ApprovalStatus.rejected, decisionAt: DateTime(2024, 5, 7)),
        ],
      ),
      ExpenseEntry(
        accountId: 'EXP-104',
        date: DateTime(2024, 5, 9),
        notes: 'Maintenance - Aircon cleaning',
        amount: 650.00,
        approvalId: 'APR-2004',
        approvalStatus: ApprovalStatus.approved,
        approvedAt: DateTime(2024, 5, 10),
        approvers:  [
          ApproverDecision(name: 'Elder Bob', positions: const ['Elder'], decision: ApprovalStatus.approved, decisionAt: DateTime(2024, 5, 10)),
        ],
      ),
      ExpenseEntry(
        accountId: 'EXP-105',
        date: base,
        notes: 'Subscriptions - Software tools',
        amount: 1250.00,
        approvalId: 'APR-2005',
        approvalStatus: ApprovalStatus.approved,
        approvedAt: DateTime(2024, 5, 16),
        approvers:  [
          ApproverDecision(name: 'Administrator', positions: const ['Administrator'], decision: ApprovalStatus.approved, decisionAt: DateTime(2024, 5, 16)),
        ],
      ),
      for (int i = 1; i <= 3; i++)
        ExpenseEntry(
          accountId: 'EXP-10${i + 5}',
          date: base.subtract(Duration(days: i + 8)),
          notes: 'Additional expense $i',
          amount: 200 + (i * 45.25),
          approvalId: 'APR-20${i + 5}',
          approvalStatus: i % 2 == 0 ? ApprovalStatus.pending : ApprovalStatus.approved,
          approvedAt: i % 2 == 0 ? null : base.subtract(Duration(days: i + 7)),
          approvers: [
            ApproverDecision(
              name: 'Pastor John',
              positions: const ['Pastor'],
              decision: i % 2 == 0 ? ApprovalStatus.pending : ApprovalStatus.approved,
              decisionAt: i % 2 == 0 ? null : base.subtract(Duration(days: i + 7)),
            ),
          ],
        ),
    ];
  }
}

 

class _ExpensesHeader extends StatelessWidget {
  const _ExpensesHeader();

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

  Widget _cell(Widget child, {int flex = 1, TextStyle? style, bool alignEnd = false}) {
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

class _ExpenseRow extends StatelessWidget {
  final ExpenseEntry entry;
  final VoidCallback? onTap;
  const _ExpenseRow({required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountText = NumberFormat.currency(locale: 'en_PH', symbol: '₱ ').format(entry.amount);
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
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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

 
