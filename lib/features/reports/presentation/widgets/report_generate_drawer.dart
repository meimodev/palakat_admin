import 'package:flutter/material.dart';
import 'package:palakat_admin/core/widgets/side_drawer.dart';
import 'package:palakat_admin/core/widgets/date_range_filter.dart';
import 'package:intl/intl.dart';

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
          _InfoSection(
            title: 'Report Details',
            children: [
              _InfoRow(label: 'Report', value: widget.reportTitle),
              _InfoRow(label: 'Description', value: widget.description),
              _InfoRow(
                label: 'Selected Range',
                value: _dateRange == null
                    ? '—'
                    : '${DateFormat('EEE, dd MMMM y').format(_dateRange!.start)}\n${DateFormat('EEE, dd MMMM y').format(_dateRange!.end)}',
              ),
            ],
          ),

          const SizedBox(height: 24),

          _InfoSection(
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

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
