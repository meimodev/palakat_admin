import 'package:flutter/material.dart';
import '../../../../core/widgets/surface_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and subtitle
        Text('Dashboard', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          "An overview of your church's activities.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Grid of 4 stat cards
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            _StatCard(
              title: 'Total Members',
              value: '1,234',
              icon: Icons.groups_outlined,
            ),
            _StatCard(
              title: 'Total Income',
              value: '\$45,231.89',
              icon: Icons.attach_money,
            ),
            _StatCard(
              title: 'Total Expenses',
              value: '\$12,789.45',
              icon: Icons.credit_card,
            ),
            _StatCard(
              title: 'Inventory Status',
              value: '5 Items Low on Stock',
              icon: Icons.inventory_2_outlined,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Recent Activity card
        SurfaceCard(
          title: 'Recent Activity',
          subtitle:
              'Recent transactions and member updates will be shown here.',
          trailing: Icon(
            Icons.show_chart,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            child: Text(
              'No recent activity to display.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title == 'Total Members'
                ? '+20 from last month'
                : title == 'Total Income'
                ? '+12.5% from last month'
                : title == 'Total Expenses'
                ? '+8.1% from last month'
                : 'Check stock levels',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
