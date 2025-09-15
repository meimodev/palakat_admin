import 'package:flutter/material.dart';

class ApproverCard extends StatelessWidget {
  final String name;
  final List<String>? positions;
  final String? statusText;
  final Color? statusColor;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final String? trailingText;

  const ApproverCard({
    super.key,
    required this.name,
    this.positions,
    this.statusText,
    this.statusColor,
    this.leadingIcon,
    this.leadingColor,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: leadingColor, size: 20),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (statusText != null && statusColor != null) ...[
            const SizedBox(height: 4),
            Text(
              statusText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (positions != null && positions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final position in positions!)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(position, style: theme.textTheme.labelSmall),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
