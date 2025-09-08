import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:palakat_admin/core/widgets/surface_card.dart';
import 'package:palakat_admin/core/widgets/pagination_bar.dart';
import 'package:palakat_admin/features/reports/presentation/widgets/report_generate_drawer.dart';


class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _historySearchController = TextEditingController();
  String? _selectedGenerator;
  
  int _historyRowsPerPage = 10;
  int _historyPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _historySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Generate and view comprehensive reports across all modules.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          SurfaceCard(
            title: 'Generate Reports',
            subtitle: 'Create custom reports for different modules.',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _GenerateCard(
                  title: 'Incoming Document Report',
                  description: 'Generate a report for documents received.',
                  onGenerate: () => _openGenerateDrawer(
                    'Incoming Document Report',
                    'Generate a report for documents received.',
                  ),
                ),
                _GenerateCard(
                  title: 'Congregation Report',
                  description: 'Generate a report on the congregation.',
                  onGenerate: () => _openGenerateDrawer(
                    'Congregation Report',
                    'Generate a report on the congregation.',
                  ),
                ),
                _GenerateCard(
                  title: 'Services Report',
                  description: 'Generate a report of all services.',
                  onGenerate: () => _openGenerateDrawer(
                    'Services Report',
                    'Generate a report of all services.',
                  ),
                ),
                _GenerateCard(
                  title: 'Activity Report',
                  description: 'Generate a report of all activities.',
                  onGenerate: () => _openGenerateDrawer(
                    'Activity Report',
                    'Generate a report of all activities.',
                  ),
                ),
                _GenerateCard(
                  title: 'Inventory Report',
                  description: 'Generate a report of all inventory.',
                  onGenerate: () => _openGenerateDrawer(
                    'Inventory Report',
                    'Generate a report of all inventory.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SurfaceCard(
            title: 'Generated Reports History',
            subtitle: 'View and manage previously generated reports.',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _historySearchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by report name...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (_) => setState(() => _historyPage = 0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedGenerator,
                      hint: const Text('All Generators'),
                      items: ['Manual', 'System']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGenerator = value;
                          _historyPage = 0;
                        });
                      },
                    ),
                    
                  ],
                ),
                const SizedBox(height: 16),

                const _ReportHistoryHeader(),
                const Divider(height: 1),

                ..._getFilteredHistoryRows().map((report) => _ReportHistoryRow(
                  report: report,
                  onDownload: () => _downloadReport(context, report.name),
                )),

                const SizedBox(height: 8),
                _buildHistoryPagination(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openGenerateDrawer(String reportTitle, String description) {
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
                child: ReportGenerateDrawer(
                  reportTitle: reportTitle,
                  description: description,
                  onClose: () => Navigator.of(ctx).pop(),
                  onGenerate: (range) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Generating $reportTitle${range == null ? '' : ' for ${DateFormat('y-MM-dd').format(range.start)} - ${DateFormat('y-MM-dd').format(range.end)}'}',
                        ),
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

  List<_GeneratedReport> _getFilteredHistoryRows() {
    final allReports = _mockGeneratedReports();
    final query = _historySearchController.text.toLowerCase();

    final filtered = allReports.where((report) {
      final nameMatches = report.name.toLowerCase().contains(query);
      final generatorMatches = _selectedGenerator == null || report.generator == _selectedGenerator;
      return nameMatches && generatorMatches;
    }).toList();

    final total = filtered.length;
    final start = (_historyPage * _historyRowsPerPage).clamp(0, total);
    final end = (start + _historyRowsPerPage).clamp(0, total);
    return start < end ? filtered.sublist(start, end) : [];
  }

  Widget _buildHistoryPagination() {
    final allReports = _mockGeneratedReports();
    final query = _historySearchController.text.toLowerCase();

    final filtered = allReports.where((report) {
      final nameMatches = report.name.toLowerCase().contains(query);
      final generatorMatches = _selectedGenerator == null || report.generator == _selectedGenerator;
      return nameMatches && generatorMatches;
    }).toList();

    final total = filtered.length;
    final showing = _getFilteredHistoryRows().length;

    return PaginationBar(
      showingCount: showing,
      totalCount: total,
      rowsPerPage: _historyRowsPerPage,
      page: _historyPage,
      pageCount: (total / _historyRowsPerPage).ceil().clamp(1, 9999),
      onRowsPerPageChanged: (v) => setState(() {
        _historyRowsPerPage = v;
        _historyPage = 0;
      }),
      onPrev: () => setState(() {
        if (_historyPage > 0) _historyPage -= 1;
      }),
      onNext: () => setState(() {
        final maxPage = (total / _historyRowsPerPage).ceil() - 1;
        if (_historyPage < maxPage) _historyPage += 1;
      }),
    );
  }

  List<_GeneratedReport> _mockGeneratedReports() {
    return [
      _GeneratedReport(
        name: 'Congregation Report - December 2024',
        generator: 'Manual',
        generatedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Ready',
        fileSize: '2.3 MB',
      ),
      _GeneratedReport(
        name: 'Services Report - November 2024',
        generator: 'System',
        generatedAt: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Ready',
        fileSize: '1.8 MB',
      ),
      _GeneratedReport(
        name: 'Activity Report - October 2024',
        generator: 'Manual',
        generatedAt: DateTime.now().subtract(const Duration(days: 7)),
        status: 'Ready',
        fileSize: '3.1 MB',
      ),
      _GeneratedReport(
        name: 'Inventory Report - September 2024',
        generator: 'System',
        generatedAt: DateTime.now().subtract(const Duration(days: 14)),
        status: 'Ready',
        fileSize: '1.2 MB',
      ),
      _GeneratedReport(
        name: 'Incoming Document Report - August 2024',
        generator: 'Manual',
        generatedAt: DateTime.now().subtract(const Duration(days: 21)),
        status: 'Ready',
        fileSize: '4.7 MB',
      ),
    ];
  }
}

void _downloadReport(BuildContext context, String reportName) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Downloading $reportName...')),
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

class _GeneratedReport {
  final String name;
  final String generator;
  final DateTime generatedAt;
  final String status;
  final String fileSize;

  const _GeneratedReport({
    required this.name,
    required this.generator,
    required this.generatedAt,
    required this.status,
    required this.fileSize,
  });
}

class _ReportHistoryHeader extends StatelessWidget {
  const _ReportHistoryHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          _cell(const Text('Report Name'), flex: 4, style: style),
          _cell(const Text('Generator'), flex: 2, style: style),
          _cell(const Text('Generated'), flex: 2, style: style),
          _cell(const Text('Size'), flex: 1, style: style),
          _cell(const Text('Actions'), flex: 2, style: style),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1, TextStyle? style}) {
    return Expanded(
      flex: flex,
      child: DefaultTextStyle(
        style: style ?? const TextStyle(),
        child: child,
      ),
    );
  }
}

class _ReportHistoryRow extends StatelessWidget {
  final _GeneratedReport report;
  final VoidCallback onDownload;

  const _ReportHistoryRow({
    required this.report,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          _cell(
            Text(
              report.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            flex: 4,
          ),
          _cell(
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.generator,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            flex: 2,
          ),
          _cell(
            Text(
              DateFormat('MMM d, y, h:mm a').format(report.generatedAt),
              style: theme.textTheme.bodyMedium,
            ),
            flex: 2,
          ),
          _cell(
            Text(
              report.fileSize,
              style: theme.textTheme.bodyMedium,
            ),
            flex: 1,
          ),
          _cell(
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                color: theme.colorScheme.primary,
                tooltip: 'Download',
              ),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _cell(Widget child, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }
}
