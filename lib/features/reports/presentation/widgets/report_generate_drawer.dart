import 'package:flutter/material.dart';
import 'package:palakat_admin/core/widgets/side_drawer.dart';
import 'package:palakat_admin/core/widgets/date_range_filter.dart';
import 'package:intl/intl.dart';
import 'package:palakat_admin/core/widgets/info_section.dart';

class ReportGenerateDrawer extends StatefulWidget {
  final String reportTitle;
  final String description;
  final VoidCallback onClose;
  final void Function(DateTimeRange? range)? onGenerate;

  const ReportGenerateDrawer({
    super.key,
    required this.reportTitle,
    required this.description,
    required this.onClose,
    this.onGenerate,
  });

  @override
  State<ReportGenerateDrawer> createState() => _ReportGenerateDrawerState();
}

class _ReportGenerateDrawerState extends State<ReportGenerateDrawer> {
  DateTimeRange? _dateRange;

  DateTimeRange _todayRange() {
    final d = DateUtils.dateOnly(DateTime.now());
    return DateTimeRange(start: d, end: d);
  }

  @override
  void initState() {
    super.initState();
    // Default to today to avoid accidentally querying all data
    _dateRange = _todayRange();
  }

  @override
  Widget build(BuildContext context) {
    return SideDrawer(
      title: 'Generate Report',
      subtitle: 'Configure and generate ${widget.reportTitle.toLowerCase()}',
      onClose: widget.onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoSection(
            title: 'Report Details',
            children: [
              InfoRow(
                label: 'Report',
                value: widget.reportTitle,
                labelWidth: 120,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: 'Description',
                value: widget.description,
                labelWidth: 120,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              InfoRow(
                label: 'Selected Range',
                value: _dateRange == null
                    ? '—'
                    : '${DateFormat('EEE, dd MMMM y').format(_dateRange!.start)}\n${DateFormat('EEE, dd MMMM y').format(_dateRange!.end)}',
                isMultiline: true,
                labelWidth: 120,
                spacing: 16,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ],
          ),

          const SizedBox(height: 24),

          InfoSection(
            title: 'Filters',
            children: [
              Row(
                children: [
                  DateRangeFilter(
                    value: _dateRange,
                    onChanged: (r) => setState(() => _dateRange = r),
                    onClear: () => setState(() => _dateRange = _todayRange()),
                    label: 'Date range',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.25,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Generating report might take a while, depending on the data requested.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: () {
              if (widget.onGenerate != null) {
                widget.onGenerate!.call(_dateRange);
              }
            },
            icon: const Icon(Icons.assessment),
            label: const Text('Generate report'),
          ),
        ],
      ),
    );
  }
}

 
