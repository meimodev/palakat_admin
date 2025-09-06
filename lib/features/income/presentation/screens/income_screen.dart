import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = List.generate(20, (i) => (
      DateTime.now().subtract(Duration(days: i)),
      'Tithes and Offerings',
      (i + 1) * 500.0,
    ));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Income', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Source')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: [
                  for (final r in rows)
                    DataRow(cells: [
                      DataCell(Text(DateFormat('y-MM-dd').format(r.$1))),
                      DataCell(Text(r.$2)),
                      DataCell(Text(NumberFormat.currency(locale: 'en_PH', symbol: '₱ ').format(r.$3))),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
