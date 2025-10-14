import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/repositories.dart';

class ApprovalScreen extends ConsumerStatefulWidget {
  const ApprovalScreen({super.key});

  @override
  ConsumerState<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends ConsumerState<ApprovalScreen> {
  late final TextEditingController _searchController;
  late final Debouncer _searchDebouncer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebouncer(() {
      ref.read(approvalScreenStateProvider.notifier)
          .updateSearchQuery(_searchController.text);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenState = ref.watch(approvalScreenStateProvider);
    final rulesAsync = ref.watch(approvalRulesAsyncProvider);
    final screenNotifier = ref.read(approvalScreenStateProvider.notifier);
    
    return Material(
      color: theme.colorScheme.surface,
      child: rulesAsync.when(
        loading: () => const AppLoadingWidget(
          message: 'Loading approval rules...',
        ),
        error: (error, stackTrace) => CompactErrorWidget(
          error: error is AppError 
            ? error 
            : AppError.unknown('Failed to load approval rules'),
          onRetry: () => ref.refresh(approvalRulesAsyncProvider),
        ),
        data: (rules) => _buildApprovalContent(
          context, 
          theme, 
          screenState, 
          rules, 
          screenNotifier,
        ),
      ),
    );
  }

  Widget _buildApprovalContent(
    BuildContext context,
    ThemeData theme,
    ApprovalScreenStateData screenState,
    List<ApprovalRule> rules,
    ApprovalScreenState screenNotifier,
  ) {
    final repository = ref.read(approvalRepositoryProvider);
    final filteredRules = repository.filterApprovalRules(
      rules,
      screenState.searchQuery,
      screenState.activeOnly,
    );
    final paginatedRules = repository.getPaginatedApprovalRules(
      filteredRules,
      screenState.page,
      screenState.rowsPerPage,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text('Approvals', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Configure approval routing rules.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            SurfaceCard(
              title: 'Approval Rules',
              subtitle: 'Configure approval routing rules and requirements.',
              trailing: FilledButton.icon(
                onPressed: () => _showAddRuleDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Rule'),
              ),
              child: Column(
                children: [
                  // Search and Filter Controls
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search approval rules...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilterChip(
                        label: const Text('Active Only'),
                        selected: screenState.activeOnly == true,
                        onSelected: (selected) {
                          screenNotifier.updateActiveFilter(selected ? true : null);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rules List
                  if (paginatedRules.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No approval rules found'),
                    )
                  else
                    ...paginatedRules.map((rule) => _ApprovalRuleCard(
                      key: ValueKey(rule.id),
                      rule: rule,
                      onEdit: () => _showEditRuleDialog(context, rule),
                      onToggleActive: () => _toggleRuleActive(rule),
                    )),
                ],
              ),
            ),
          ],
        ),
      );
  }

  void _showAddRuleDialog(BuildContext context) {
    // TODO: Implement add rule dialog
    AppSnackbars.showSuccess(
      context,
      title: 'Coming soon',
      message: 'Add rule dialog - Coming soon!',
    );
  }

  void _showEditRuleDialog(BuildContext context, ApprovalRule rule) {
    // TODO: Implement edit rule dialog
    AppSnackbars.showSuccess(
      context,
      title: 'Coming soon',
      message: 'Edit rule: ${rule.name} - Coming soon!',
    );
  }

  void _toggleRuleActive(ApprovalRule rule) {
    // TODO: Implement toggle rule active status
    AppSnackbars.showSuccess(
      context,
      title: 'Coming soon',
      message: 'Toggle ${rule.name} status - Coming soon!',
    );
  }
}

class _ApprovalRuleCard extends StatelessWidget {
  final ApprovalRule rule;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const _ApprovalRuleCard({
    super.key,
    required this.rule,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rule.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(rule.isActive ? 'Active' : 'Inactive'),
                  backgroundColor: rule.isActive 
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: onEdit,
                      child: const Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: onToggleActive,
                      child: Row(
                        children: [
                          Icon(rule.isActive ? Icons.pause : Icons.play_arrow),
                          const SizedBox(width: 8),
                          Text(rule.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ...rule.requiredApprovers.map((approver) => Chip(
                  label: Text(approver),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum approvals: ${rule.minimumApprovals}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
