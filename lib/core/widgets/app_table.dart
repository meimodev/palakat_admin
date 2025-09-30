import 'package:flutter/material.dart';
import 'package:palakat_admin/core/widgets/pagination_bar.dart';
import 'package:shimmer/shimmer.dart';

/// Generic, reusable data table for consistent tables across the app.
///
/// Features:
/// - Customizable columns with flexible layout (via `flex`).
/// - Optional `filters` slot (e.g., search field, `DateRangeFilter`, chips, etc.).
/// - Optional pagination via [AppTablePaginationConfig] using the existing `PaginationBar`.
/// - Loading, error, and empty states.
/// - Row tap callback.
/// - Optional sorting hooks (delegated to the parent for state changes).
class AppTable<T> extends StatelessWidget {
  const AppTable({
    super.key,
    required this.columns,
    required this.data,
    this.loading = true,
    this.filters,
    this.filtersConfig,
    this.errorText,
    this.onRetry,
    this.emptyBuilder,
    this.onRowTap,
    this.pagination,
    this.sortConfig,
    this.rowDecoration,
    this.headerDecoration,
    this.showDividers = true,
  });

  /// Column definitions.
  final List<AppTableColumn<T>> columns;

  /// Optional filters area rendered above the table header.
  final Widget? filters;

  /// Optional built-in filter bar configuration. When provided, AppTable will
  /// render a standard filter bar UI and wire callbacks to the parent.
  final AppTableFiltersConfig? filtersConfig;

  final bool loading;

  final List<T> data ;

  /// Error text to display when a failure occurs.
  final String? errorText;

  /// Optional retry callback for error state.
  final VoidCallback? onRetry;

  /// Builder for empty state when [items] is empty and not loading/error.
  final WidgetBuilder? emptyBuilder;

  /// Called when a row is tapped.
  final ValueChanged<T>? onRowTap;

  /// Pagination configuration. When provided, `PaginationBar` is shown.
  final AppTablePaginationConfig? pagination;

  /// Sorting configuration (purely for UI + callbacks; state lives in parent).
  final AppTableSortConfig? sortConfig;

  /// Optional decoration for rows hover/press surface. Defaults to subtle hover color.
  final BoxDecoration? rowDecoration;

  /// Optional decoration for header. Defaults to surfaceContainerLowest with bottom border.
  final BoxDecoration? headerDecoration;

  /// Whether to show a divider between rows.
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (filtersConfig != null) ...[
          _BuiltInFiltersBar(config: filtersConfig!),
          const SizedBox(height: 12),
        ] else if (filters != null) ...[
          // Backward compatibility: allow custom filters slot
          filters!,
          const SizedBox(height: 12),
        ],
        _Header<T>(
          columns: columns,
          sortConfig: sortConfig,
          decoration: headerDecoration ?? _defaultHeaderDecoration(theme),
        ),
        if (loading) ...[
          _ShimmerLoadingPlaceholder(columns: columns),
        ] else if (errorText != null) ...[
          _ErrorPlaceholder(
            message: errorText!,
            onRetry: onRetry,
          ),
        ] else if (data.isEmpty) ...[
          if (emptyBuilder != null)
            emptyBuilder!(context)
          else
            _EmptyPlaceholder(),
        ] else ...[
          ...List.generate(data.length, (index) {
            final item = data[index];
            final row = _Row<T>(
              item: item,
              columns: columns,
              onTap: onRowTap,
              decoration: rowDecoration,
            );
            if (!showDividers) return row;
            return Column(
              children: [
                row,
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
              ],
            );
          }),
        ],
        if (pagination != null) ...[
          const SizedBox(height: 12),
          PaginationBar(
            showingCount: pagination!.showingCount,
            totalCount: pagination!.totalCount,
            rowsPerPage: pagination!.rowsPerPage,
            page: pagination!.page,
            pageCount: pagination!.pageCount,
            onRowsPerPageChanged: pagination!.onRowsPerPageChanged,
            onPrev: pagination!.onPrev,
            onNext: pagination!.onNext,
            rowSizes: pagination!.rowSizes,
          ),
        ],
      ],
    );
  }

  BoxDecoration _defaultHeaderDecoration(ThemeData theme) => BoxDecoration(
    color: theme.colorScheme.surfaceContainerLowest,
    border: Border(
      bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
    ),
  );
}

class AppTableColumn<T> {
  AppTableColumn({
    required this.title,
    required this.cellBuilder,
    this.flex = 1,
    this.headerAlignment = Alignment.centerLeft,
    this.cellAlignment = Alignment.centerLeft,
    this.tooltip,
    this.onSort,
  });

  /// Column title.
  final String title;

  /// Build cell for the given row item.
  final Widget Function(BuildContext context, T row) cellBuilder;

  /// Flex for layout width distribution.
  final int flex;

  /// Alignment for header label.
  final Alignment headerAlignment;

  /// Alignment for cell content.
  final Alignment cellAlignment;

  /// Optional tooltip for the column header.
  final String? tooltip;

  /// Optional sort handler for this column.
  /// Parent should update [AppTable.sortConfig] when invoked.
  final VoidCallback? onSort;
}

class AppTableSortConfig {
  const AppTableSortConfig({
    required this.activeColumnIndex,
    required this.ascending,
  });

  /// Zero-based active sort column index.
  final int activeColumnIndex;

  /// Whether the sort is ascending.
  final bool ascending;
}

class AppTablePaginationConfig {
  const AppTablePaginationConfig({
    required this.showingCount,
    required this.totalCount,
    required this.rowsPerPage,
    required this.page,
    required this.pageCount,
    required this.onRowsPerPageChanged,
    required this.onPrev,
    required this.onNext,
    required this.rowSizes ,
  });

  final int showingCount;
  final int totalCount;
  final int rowsPerPage;
  final int page; // zero-based
  final int pageCount; // total pages
  final List<int> rowSizes;
  final ValueChanged<int> onRowsPerPageChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
}

class _Header<T> extends StatelessWidget {
  const _Header({
    required this.columns,
    required this.sortConfig,
    required this.decoration,
  });

  final List<AppTableColumn<T>> columns;
  final AppTableSortConfig? sortConfig;
  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: decoration,
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++) ...[
            Expanded(
              flex: columns[i].flex,
              child: Align(
                alignment: columns[i].headerAlignment,
                child: _HeaderLabel(
                  title: columns[i].title,
                  tooltip: columns[i].tooltip,
                  isActive: sortConfig?.activeColumnIndex == i,
                  ascending: sortConfig?.ascending ?? true,
                  onPressed: columns[i].onSort,
                  textStyle: textStyle,
                ),
              ),
            ),
          ],
          const SizedBox(width: 20), // space for trailing icons like chevron
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel({
    required this.title,
    required this.isActive,
    required this.ascending,
    required this.onPressed,
    required this.textStyle,
    this.tooltip,
  });

  final String title;
  final bool isActive;
  final bool ascending;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: textStyle),
        if (isActive) ...[
          const SizedBox(width: 4),
          Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
        ],
      ],
    );

    final child = onPressed == null
        ? label
        : InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: label,
            ),
          );

    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}

class _Row<T> extends StatelessWidget {
  const _Row({
    required this.item,
    required this.columns,
    required this.onTap,
    this.decoration,
  });

  final T item;
  final List<AppTableColumn<T>> columns;
  final ValueChanged<T>? onTap;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hoverColor = theme.colorScheme.surfaceContainerHighest;

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final col in columns) ...[
            Expanded(
              flex: col.flex,
              child: Align(
                alignment: col.cellAlignment,
                child: col.cellBuilder(context, item),
              ),
            ),
          ],
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap!(item),
          hoverColor: decoration == null ? hoverColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: Container(decoration: decoration, child: content),
        ),
      ),
    );
  }
}

class _ShimmerLoadingPlaceholder extends StatelessWidget {
  const _ShimmerLoadingPlaceholder({required this.columns});

  final List<Object> columns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surface;

    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              children: [
                // Simulate column widths
                for (int i = 0; i < columns.length; i++) ...[
                  Expanded(
                    flex: (columns[i] as AppTableColumn).flex,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  if (i < columns.length - 1) const SizedBox(width: 12),
                ],
                const SizedBox(width: 20), // Space for chevron
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        'No records found',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Configuration for the built-in AppTable filter bar.
class AppTableFiltersConfig {
  const AppTableFiltersConfig({
    this.searchHint,
    this.searchController,
    this.onSearchChanged,
    this.positionOptions,
    this.positionValue,
    this.onPositionChanged,
    this.actionLabel,
    this.actionIcon,
    this.onActionPressed,
  });

  /// Optional hint for the search field. When null, search field is hidden.
  final String? searchHint;

  /// Optional controller to manage the search field text from parent.
  final TextEditingController? searchController;

  /// Callback when the search text changes.
  final ValueChanged<String>? onSearchChanged;

  /// Optional list of position options. When null or empty, dropdown is hidden.
  final List<String>? positionOptions;

  /// Currently selected position value. Null indicates "All".
  final String? positionValue;

  /// Callback when position filter changes. Null value indicates "All".
  final ValueChanged<String?>? onPositionChanged;

  /// Optional trailing action button label (e.g., "New Member").
  final String? actionLabel;

  /// Optional trailing action icon.
  final IconData? actionIcon;

  /// Callback for trailing action button.
  final VoidCallback? onActionPressed;
}

class _BuiltInFiltersBar extends StatelessWidget {
  const _BuiltInFiltersBar({required this.config});

  final AppTableFiltersConfig config;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    // Search field
    if (config.searchHint != null) {
      children.add(
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: config.searchHint,
              border: const OutlineInputBorder(),
            ),
            controller: config.searchController,
            onChanged: config.onSearchChanged,
          ),
        ),
      );
    }

    // Spacing between widgets
    void addSpacer() {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 8));
      }
    }

    // Position dropdown
    if (config.positionOptions != null && config.positionOptions!.isNotEmpty) {
      addSpacer();
      children.add(
        IntrinsicWidth(
          child: DropdownButtonFormField<String?>(
            value: config.positionValue,
            decoration: const InputDecoration(
              labelText: 'Filter by Position',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Positions', overflow: TextOverflow.ellipsis),
              ),
              ...config.positionOptions!.map(
                (p) => DropdownMenuItem<String?>(
                  value: p,
                  child: Text(p, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: config.onPositionChanged,
          ),
        ),
      );
    }

    // Action button
    if (config.onActionPressed != null && config.actionLabel != null) {
      addSpacer();
      children.add(
        FilledButton.icon(
          onPressed: config.onActionPressed,
          icon: Icon(config.actionIcon ?? Icons.add, size: 18),
          label: Text(config.actionLabel!),
        ),
      );
    }

    return Row(children: children);
  }
}
