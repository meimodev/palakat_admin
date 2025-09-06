import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final now = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = _range == null
        ? 'All time'
        : '${DateFormat('MMM d, y').format(_range!.start)} - ${DateFormat('MMM d, y').format(_range!.end)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reports', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDateRange: _range,
                );
                if (picked != null) setState(() => _range = picked);
              },
              icon: const Icon(Icons.date_range),
              label: Text(dateText),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Export CSV'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Income'),
                  Tab(text: 'Expenses'),
                  Tab(text: 'Inventory'),
                ],
              ),
              SizedBox(
                height: 420,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _ReportTable(kind: 'Income'),
                    _ReportTable(kind: 'Expenses'),
                    _ReportTable(kind: 'Inventory'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Generate report cards section
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _GenerateCard(
              title: 'Incoming Document Report',
              description: 'Generate a report for documents received.',
              onGenerate: () => _showGenerated(context, 'Incoming Document Report'),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _GenerateCard(
              title: 'Congregation Report',
              description: 'Generate a report on the congregation.',
              onGenerate: () => _showGenerated(context, 'Congregation Report'),
            ),
            _GenerateCard(
              title: 'Services Report',
              description: 'Generate a report of all services.',
              onGenerate: () => _showGenerated(context, 'Services Report'),
            ),
            _GenerateCard(
              title: 'Activity Report',
              description: 'Generate a report of all activities.',
              onGenerate: () => _showGenerated(context, 'Activity Report'),
            ),
            _GenerateCard(
              title: 'Inventory Report',
              description: 'Generate a report of all inventory.',
              onGenerate: () => _showGenerated(context, 'Inventory Report'),
            ),
          ],
        ),
      ],
    );
  }
}

void _showGenerated(BuildContext context, String which) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$which generated (dummy).')),
  );
}

class _GenerateCard extends StatelessWidget {
  const _GenerateCard({
    required this.title,
    required this.description,
    required this.onGenerate,
  });
  final String title;
  final String description;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onGenerate,
                child: const Text('Generate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTable extends StatelessWidget {
  const _ReportTable({required this.kind});
  final String kind;

  @override
  Widget build(BuildContext context) {
    final rows = List.generate(15, (i) {
      final date = DateTime.now().subtract(Duration(days: i * 2));
      return _ReportRow(
        date: DateFormat('y-MM-dd').format(date),
        description: '$kind item ${i + 1}',
        amount: (i * 1234.56) + 1000,
        status: i % 3 == 0 ? 'Pending' : 'Completed',
      );
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
          ],
          rows: [
            for (final r in rows)
              DataRow(
                cells: [
                  DataCell(Text(r.date)),
                  DataCell(Text(r.description)),
                  DataCell(Text(NumberFormat.currency(locale: 'en_PH', symbol: '₱ ').format(r.amount))),
                  DataCell(_StatusChip(status: r.status)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportRow {
  final String date;
  final String description;
  final double amount;
  final String status;
  const _ReportRow({
    required this.date,
    required this.description,
    required this.amount,
    required this.status,
  });
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status.toLowerCase() == 'completed';
    final color = isCompleted ? Colors.green : Colors.orange;
    return Chip(
      label: Text(status),
      side: BorderSide(color: color.withOpacity(0.4)),
      backgroundColor: color.withOpacity(0.08),
      labelStyle: TextStyle(color: color.shade700, fontWeight: FontWeight.w600),
    );
  }
}
