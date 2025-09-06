import 'package:flutter/material.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = List.generate(12, (i) => (
      'File_${i + 1}.pdf',
      '${(i + 1) * 120} KB',
      '2025-09-${(i % 28) + 1}'.padLeft(2, '0'),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Document', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('New Folder'),
            ),
          ],
        ),
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
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Size')),
                DataColumn(label: Text('Modified')),
              ],
              rows: [
                for (final r in rows)
                  DataRow(cells: [
                    DataCell(Row(children: [
                      const Icon(Icons.picture_as_pdf, size: 18),
                      const SizedBox(width: 8),
                      Text(r.$1),
                    ])),
                    DataCell(Text(r.$2)),
                    DataCell(Text(r.$3)),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
