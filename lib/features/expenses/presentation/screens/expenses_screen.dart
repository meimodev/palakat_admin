import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = List.generate(18, (i) => (
      DateTime.now().subtract(Duration(days: i * 2)),
      'Expense Item ${i + 1}',
      (i + 1) * 350.0,
    ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expenses', style: theme.textTheme.headlineMedium),
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
                DataColumn(label: Text('Description')),
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
    );
  }
}
