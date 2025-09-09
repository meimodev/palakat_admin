import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/billing.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/date_range_filter.dart';
import '../../../../core/widgets/side_drawer.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 10;
  int _page = 0;
  DateTimeRange? _dateRange;
  BillingStatus? _statusFilter;

  late final List<BillingItem> _allBillingItems;
  late final List<PaymentHistory> _allPaymentHistory;

  @override
  void initState() {
    super.initState();
    _allBillingItems = _generateMockBillingItems();
    _allPaymentHistory = _generateMockPaymentHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Overdue items for urgent attention
    final overdueItems =
        _allBillingItems
            .where(
              (item) => item.status == BillingStatus.overdue || item.isOverdue,
            )
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    bool inDateRange(DateTime d) {
      if (_dateRange == null) return true;
      final s = DateUtils.dateOnly(_dateRange!.start);
      final e = DateUtils.dateOnly(_dateRange!.end);
      final dd = DateUtils.dateOnly(d);
      final afterStart = dd.isAtSameMomentAs(s) || dd.isAfter(s);
      final beforeEnd = dd.isAtSameMomentAs(e) || dd.isBefore(e);
      return afterStart && beforeEnd;
    }

    final filtered = _allBillingItems.where((item) {
      final q = _searchController.text.trim().toLowerCase();
      final dueDateStr = DateFormat(
        'y-MM-dd',
      ).format(item.dueDate).toLowerCase();
      final paidDateStr = item.paidDate != null
          ? DateFormat('y-MM-dd').format(item.paidDate!).toLowerCase()
          : '';

      final matchesQuery =
          q.isEmpty ||
          item.id.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.type.displayName.toLowerCase().contains(q) ||
          item.status.displayName.toLowerCase().contains(q) ||
          item.formattedAmount.toLowerCase().contains(q) ||
          dueDateStr.contains(q) ||
          paidDateStr.contains(q) ||
          (item.notes?.toLowerCase().contains(q) ?? false);

      final matchesStatus =
          _statusFilter == null || item.status == _statusFilter;
      final matchesDate = inDateRange(item.dueDate);

      return matchesQuery && matchesStatus && matchesDate;
    }).toList();

    final total = filtered.length;
    final start = (_page * _rowsPerPage).clamp(0, total);
    final end = (start + _rowsPerPage).clamp(0, total);
    final pageRows = start < end
        ? filtered.sublist(start, end)
        : <BillingItem>[];

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Billing Management', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Manage church billing, payments, and view payment history.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Urgent Overdue Bills
            if (overdueItems.isNotEmpty) ...[
              SurfaceCard(
                title: 'Overdue Bills',
                subtitle: 'Require urgent attention',
                child: Column(
                  children: [
                    _BillingHeader(),
                    const Divider(height: 1),
                    ...[
                      for (final item in overdueItems)
                        _BillingRow(
                          item: item,
                          onTap: () => _showBillingItemDetail(item),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // (Billing Items card moved to bottom)

            // Payment History
            SurfaceCard(
              title: 'Payment History',
              subtitle: 'View all payment transactions and history.',
              child: Column(
                children: [
                  _PaymentHistoryHeader(),
                  const Divider(height: 1),
                  ...[
                    for (final payment in _allPaymentHistory.take(10))
                      _PaymentHistoryRow(payment: payment),
                  ],
                  if (_allPaymentHistory.length > 10) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _showFullPaymentHistory(),
                      child: Text(
                        'View All ${_allPaymentHistory.length} Payments',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Billing Items Table (moved to bottom)
            SurfaceCard(
              title: 'Billing Items',
              subtitle: 'Manage church billing and payment records.',
              child: Column(
                children: [
                  // Search and Filters
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search billing items...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {
                            _page = 0;
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<BillingStatus?>(
                        value: _statusFilter,
                        hint: const Text('All Status'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Status'),
                          ),
                          ...BillingStatus.values.map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.displayName),
                            ),
                          ),
                        ],
                        onChanged: (status) => setState(() {
                          _statusFilter = status;
                          _page = 0;
                        }),
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

                  // Table Header
                  _BillingHeader(),
                  const Divider(height: 1),

                  // Table Rows
                  ...[
                    for (final item in pageRows)
                      _BillingRow(
                        item: item,
                        onTap: () => _showBillingItemDetail(item),
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

  void _showBillingItemDetail(BillingItem? item) {
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
                child: _BillingDetailDrawer(
                  item: item!,
                  onClose: () => Navigator.of(ctx).pop(),
                  onPayment: () {
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => _PaymentDialog(
                        item: item,
                        onPayment: (paymentMethod, transactionId, notes) {
                          setState(() {
                            final index = _allBillingItems.indexWhere(
                              (i) => i.id == item.id,
                            );
                            if (index != -1) {
                              _allBillingItems[index] = item.copyWith(
                                status: BillingStatus.paid,
                                paidDate: DateTime.now(),
                                paymentMethod: paymentMethod,
                                transactionId: transactionId,
                                notes: notes,
                                updatedAt: DateTime.now(),
                              );
                            }

                            _allPaymentHistory.insert(
                              0,
                              PaymentHistory(
                                id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
                                billingItemId: item.id,
                                amount: item.amount,
                                paymentMethod: paymentMethod,
                                transactionId: transactionId,
                                paymentDate: DateTime.now(),
                                notes: notes,
                                processedBy: 'Admin User',
                              ),
                            );
                          });
                        },
                      ),
                    );
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

  // Payment dialog removed with actions column

  void _showFullPaymentHistory() {
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
                child: SideDrawer(
                  title: 'Payment History',
                  subtitle: 'Complete payment transaction history',
                  onClose: () => Navigator.of(ctx).pop(),
                  width: 600,
                  content: Column(
                    children: [
                      _PaymentHistoryHeader(),
                      const Divider(height: 1),
                      ...[
                        for (final payment in _allPaymentHistory)
                          _PaymentHistoryRow(payment: payment),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  List<BillingItem> _generateMockBillingItems() {
    final now = DateTime.now();
    return [
      BillingItem(
        id: 'BILL-1001',
        description: 'Monthly System Subscription - September 2024',
        amount: 1499.00,
        type: BillingType.subscription,
        status: BillingStatus.paid,
        dueDate: now.subtract(const Duration(days: 15)),
        paidDate: now.subtract(const Duration(days: 10)),
        paymentMethod: PaymentMethod.creditCard,
        transactionId: 'TXN-CC-001',
        notes: 'Paid via credit card ending in 4532',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      BillingItem(
        id: 'BILL-1002',
        description: 'Setup Fee - Initial Configuration',
        amount: 2500.00,
        type: BillingType.oneTime,
        status: BillingStatus.paid,
        dueDate: now.subtract(const Duration(days: 45)),
        paidDate: now.subtract(const Duration(days: 40)),
        paymentMethod: PaymentMethod.bankTransfer,
        transactionId: 'TXN-BT-001',
        createdAt: now.subtract(const Duration(days: 50)),
        updatedAt: now.subtract(const Duration(days: 40)),
      ),
      BillingItem(
        id: 'BILL-1003',
        description: 'Monthly System Subscription - October 2024',
        amount: 1499.00,
        type: BillingType.subscription,
        status: BillingStatus.pending,
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      BillingItem(
        id: 'BILL-1004',
        description: 'Additional Storage - 100GB',
        amount: 299.00,
        type: BillingType.oneTime,
        status: BillingStatus.overdue,
        dueDate: now.subtract(const Duration(days: 5)),
        notes: 'Payment reminder sent',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      BillingItem(
        id: 'BILL-1005',
        description: 'Premium Support Package - Q4 2024',
        amount: 999.00,
        type: BillingType.recurring,
        status: BillingStatus.pending,
        dueDate: now.add(const Duration(days: 15)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      BillingItem(
        id: 'BILL-1006',
        description: 'Training Session - Staff Onboarding',
        amount: 1200.00,
        type: BillingType.oneTime,
        status: BillingStatus.cancelled,
        dueDate: now.subtract(const Duration(days: 30)),
        notes: 'Cancelled due to schedule conflict',
        createdAt: now.subtract(const Duration(days: 40)),
        updatedAt: now.subtract(const Duration(days: 25)),
      ),
    ];
  }

  List<PaymentHistory> _generateMockPaymentHistory() {
    final now = DateTime.now();
    return [
      PaymentHistory(
        id: 'PAY-1001',
        billingItemId: 'BILL-1001',
        amount: 1499.00,
        paymentMethod: PaymentMethod.creditCard,
        transactionId: 'TXN-CC-001',
        paymentDate: now.subtract(const Duration(days: 10)),
        notes: 'Automatic payment via saved card',
        processedBy: 'System',
      ),
      PaymentHistory(
        id: 'PAY-1002',
        billingItemId: 'BILL-1002',
        amount: 2500.00,
        paymentMethod: PaymentMethod.bankTransfer,
        transactionId: 'TXN-BT-001',
        paymentDate: now.subtract(const Duration(days: 40)),
        notes: 'Bank transfer from church account',
        processedBy: 'Admin User',
      ),
      PaymentHistory(
        id: 'PAY-1003',
        billingItemId: 'BILL-0998',
        amount: 1499.00,
        paymentMethod: PaymentMethod.creditCard,
        transactionId: 'TXN-CC-002',
        paymentDate: now.subtract(const Duration(days: 45)),
        notes: 'Monthly subscription payment',
        processedBy: 'System',
      ),
      PaymentHistory(
        id: 'PAY-1004',
        billingItemId: 'BILL-0997',
        amount: 599.00,
        paymentMethod: PaymentMethod.digitalWallet,
        transactionId: 'TXN-DW-001',
        paymentDate: now.subtract(const Duration(days: 60)),
        notes: 'Paid via PayPal',
        processedBy: 'Admin User',
      ),
    ];
  }
}

class _BillingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Bill ID'), flex: 2, style: textStyle),
          _cell(const Text('Description'), flex: 4, style: textStyle),
          _cell(const Text('Amount'), flex: 2, style: textStyle),
          _cell(const Text('Due Date'), flex: 2, style: textStyle),
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

class _BillingRow extends StatelessWidget {
  final BillingItem item;
  final VoidCallback onTap;

  const _BillingRow({required this.item, required this.onTap});

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
                      Text(
                        item.id,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      flex: 2,
                    ),
                    _cell(
                      Text(
                        item.description,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      flex: 4,
                    ),
                    _cell(
                      Text(
                        item.formattedAmount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      flex: 2,
                    ),
                    _cell(
                      Text(
                        _formatDate(item.dueDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: item.isOverdue ? Colors.red : null,
                        ),
                      ),
                      flex: 2,
                    ),
                    _cell(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _StatusChip(status: item.status),
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
    return DateFormat('MMM dd, yyyy').format(d);
  }

  Widget _cell(Widget child, {int flex = 1}) =>
      Expanded(flex: flex, child: child);
}

class _StatusChip extends StatelessWidget {
  final BillingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon) = switch (status) {
      BillingStatus.paid => (Colors.green, Icons.check_circle),
      BillingStatus.pending => (Colors.orange, Icons.pending),
      BillingStatus.overdue => (Colors.red, Icons.warning),
      BillingStatus.cancelled => (Colors.grey, Icons.cancel),
      BillingStatus.refunded => (Colors.blue, Icons.undo),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Payment ID'), flex: 2, style: textStyle),
          _cell(const Text('Account ID'), flex: 2, style: textStyle),
          _cell(const Text('Amount'), flex: 2, style: textStyle),
          _cell(const Text('Method'), flex: 2, style: textStyle),
          _cell(const Text('Date'), flex: 2, style: textStyle),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1, TextStyle? style}) => Expanded(
    flex: flex,
    child: DefaultTextStyle.merge(style: style, child: child),
  );
}

class _PaymentHistoryRow extends StatelessWidget {
  final PaymentHistory payment;

  const _PaymentHistoryRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _cell(
                Text(
                  payment.id,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                flex: 2,
              ),
              _cell(
                Text(payment.billingItemId, style: theme.textTheme.bodyMedium),
                flex: 2,
              ),
              _cell(
                Text(
                  payment.formattedAmount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                flex: 2,
              ),
              _cell(
                Align(
                  alignment: Alignment.centerLeft,
                  child: _PaymentMethodChip(method: payment.paymentMethod),
                ),
                flex: 2,
              ),
              _cell(
                Text(
                  DateFormat('MMM dd, yyyy').format(payment.paymentDate),
                  style: theme.textTheme.bodyMedium,
                ),
                flex: 2,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _cell(Widget child, {int flex = 1}) =>
      Expanded(flex: flex, child: child);
}

class _PaymentMethodChip extends StatelessWidget {
  final PaymentMethod method;

  const _PaymentMethodChip({required this.method});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon) = switch (method) {
      PaymentMethod.creditCard => (Colors.blue, Icons.credit_card),
      PaymentMethod.bankTransfer => (Colors.green, Icons.account_balance),
      PaymentMethod.cash => (Colors.orange, Icons.money),
      PaymentMethod.check => (Colors.purple, Icons.receipt),
      PaymentMethod.digitalWallet => (Colors.teal, Icons.wallet),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            method.displayName,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _BillingDetailDrawer extends StatelessWidget {
  final BillingItem item;
  final VoidCallback onClose;
  final VoidCallback onPayment;

  const _BillingDetailDrawer({
    required this.item,
    required this.onClose,
    required this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    return SideDrawer(
      title: 'Billing Details',
      subtitle: item.id,
      onClose: onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoSection(
            title: 'Basic Information',
            children: [
              _InfoRow(label: 'Description', value: item.description),
              _InfoRow(label: 'Amount', value: item.formattedAmount),
              _InfoRow(
                label: 'Status',
                value: item.status.displayName,
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusChip(status: item.status),
                ),
              ),
              _InfoRow(
                label: 'Due Date',
                value: DateFormat('MMM dd, yyyy').format(item.dueDate),
              ),
              _InfoRow(
                label: 'Paid Date',
                value: item.paidDate != null
                    ? DateFormat('MMM dd, yyyy').format(item.paidDate!)
                    : '—',
              ),
            ],
          ),

          const SizedBox(height: 24),

          _InfoSection(
            title: 'Payment Information',
            children: [
              _InfoRow(
                label: 'Method',
                value: item.paymentMethod?.displayName ?? '—',
              ),
              _InfoRow(
                label: 'Transaction ID',
                value: item.transactionId ?? '—',
              ),
              if (item.notes != null)
                _InfoRow(label: 'Notes', value: item.notes!),
            ],
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onPayment,
              icon: const Icon(Icons.payment),
              label: const Text('Record Payment'),
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
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;
  const _InfoRow({required this.label, required this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child:
                valueWidget ?? Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final BillingItem item;
  final Function(PaymentMethod, String?, String?) onPayment;

  const _PaymentDialog({required this.item, required this.onPayment});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _transactionController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _paymentMethod = PaymentMethod.creditCard;

  @override
  void dispose() {
    _transactionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Record Payment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bill: ${widget.item.id}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Amount: ${widget.item.formattedAmount}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: PaymentMethod.values
                  .map(
                    (method) => DropdownMenuItem(
                      value: method,
                      child: Text(method.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (method) => setState(() => _paymentMethod = method!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _transactionController,
              decoration: const InputDecoration(
                labelText: 'Transaction ID (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onPayment(
              _paymentMethod,
              _transactionController.text.trim().isEmpty
                  ? null
                  : _transactionController.text.trim(),
              _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Record Payment'),
        ),
      ],
    );
  }
}
