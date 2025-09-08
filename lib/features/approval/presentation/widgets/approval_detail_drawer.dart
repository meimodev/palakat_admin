import 'package:flutter/material.dart';
import 'package:palakat_admin/core/widgets/side_drawer.dart';

import '../screens/approval_screen.dart';

class ApprovalDetailDrawer extends StatefulWidget {
  final ApprovalRequest request;
  final VoidCallback onClose;
  final Function(ApprovalRequest) onUpdate;

  const ApprovalDetailDrawer({
    super.key,
    required this.request,
    required this.onClose,
    required this.onUpdate,
  });

  @override
  State<ApprovalDetailDrawer> createState() => _ApprovalDetailDrawerState();
}

class _ApprovalDetailDrawerState extends State<ApprovalDetailDrawer> {
  late ApprovalRequest _currentRequest;
  String? _comment;

  @override
  void initState() {
    super.initState();
    _currentRequest = widget.request;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = _currentRequest.status == RequestStatus.pending;

    return SideDrawer(
      title: 'Approval Details',
      subtitle: 'Review and take action on this request',
      onClose: widget.onClose,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Info
          _InfoSection(
            title: 'Request Information',
            children: [
              _InfoRow(label: 'Date', value: _formatDate(_currentRequest.date)),
              _InfoRow(
                label: 'Type',
                value: _currentRequest.type,
                valueWidget: Align(
                  alignment: Alignment.centerLeft,
                  child: _TypeChip(label: _currentRequest.type),
                ),
              ),
              _InfoRow(label: 'Requester', value: _currentRequest.requester),
              _InfoRow(
                label: 'Description',
                value: _currentRequest.description,
                isMultiline: true,
              ),
              if (_currentRequest.note != null)
                _InfoRow(
                  label: 'Note',
                  value: _currentRequest.note!,
                  isMultiline: true,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Authorizers
          _InfoSection(
            title: 'Authorizers',
            children: [
              for (final authorizer in _currentRequest.authorizers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AuthorizerCard(authorizer: authorizer),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Status
          _InfoSection(
            title: 'Current Status',
            children: [_StatusCard(status: _currentRequest.status)],
          ),
        ],
      ),
      footer: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Approval can only be approve or reject on mobile app from each of authorizer',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(AuthorizerDecision decision) {
    // In a real app, you would update the request status here
    // For now, we'll just update the local state
    setState(() {
      _currentRequest = ApprovalRequest(
        date: _currentRequest.date,
        description: _currentRequest.description,
        type: _currentRequest.type,
        requester: _currentRequest.requester,
        authorizers: _currentRequest.authorizers,
        status: decision == AuthorizerDecision.approved
            ? RequestStatus.approved
            : RequestStatus.rejected,
        note: _comment?.isNotEmpty == true ? _comment : _currentRequest.note,
        id: _currentRequest.id,
      );
    });

    // Notify parent of the update
    widget.onUpdate(_currentRequest);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          decision == AuthorizerDecision.approved
              ? 'Request approved successfully'
              : 'Request rejected',
        ),
        backgroundColor: decision == AuthorizerDecision.approved
            ? Colors.green
            : Colors.red,
      ),
    );

    // Close drawer after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
  final bool isMultiline;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueWidget,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                valueWidget ?? Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;

  const _TypeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}

class _AuthorizerCard extends StatelessWidget {
  final Authorizer authorizer;

  const _AuthorizerCard({required this.authorizer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;
    String statusText;
    String? dateText;

    switch (authorizer.decision) {
      case AuthorizerDecision.approved:
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = 'Approved';
        if (authorizer.decisionAt != null) {
          final d = authorizer.decisionAt!;
          dateText =
              'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        }
        break;
      case AuthorizerDecision.rejected:
        icon = Icons.cancel;
        color = Colors.red;
        statusText = 'Rejected';
        if (authorizer.decisionAt != null) {
          final d = authorizer.decisionAt!;
          dateText =
              'on ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        }
        break;
      case AuthorizerDecision.pending:
        icon = Icons.pending;
        color = Colors.orange;
        statusText = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authorizer.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (dateText != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final RequestStatus status;

  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      RequestStatus.pending => (
        Colors.orange.shade50,
        Colors.orange.shade700,
        'Pending',
      ),
      RequestStatus.approved => (
        Colors.green.shade50,
        Colors.green.shade700,
        'Approved',
      ),
      RequestStatus.rejected => (
        Colors.red.shade50,
        Colors.red.shade700,
        'Rejected',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            status == RequestStatus.pending
                ? Icons.pending
                : status == RequestStatus.approved
                ? Icons.check_circle
                : Icons.cancel,
            color: fg,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
