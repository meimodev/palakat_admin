import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/theme.dart';
import 'core/layout/app_scaffold.dart';
import 'features/users/presentation/screens/users_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/approval/presentation/screens/approval_screen.dart';
import 'features/billing/presentation/screens/billing_screen.dart';
import 'features/church/presentation/screens/church_screen.dart';
import 'features/document/presentation/screens/document_screen.dart';
import 'features/income/presentation/screens/income_screen.dart';
import 'features/expenses/presentation/screens/expenses_screen.dart';
import 'features/inventory/presentation/screens/inventory_screen.dart';
import 'features/account/presentation/screens/account_screen.dart';

void main() {
  runApp(const ProviderScope(child: PalakatAdminApp()));
}

class PalakatAdminApp extends ConsumerWidget {
  const PalakatAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _router;
    return MaterialApp.router
      (
      title: 'Palakat Admin',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/members',
          name: 'members',
          builder: (context, state) => const UsersScreen(),
        ),
        GoRoute(
          path: '/approval',
          name: 'approval',
          builder: (context, state) => const ApprovalScreen(),
        ),
        GoRoute(
          path: '/billing',
          name: 'billing',
          builder: (context, state) => const BillingScreen(),
        ),
        GoRoute(
          path: '/church',
          name: 'church',
          builder: (context, state) => const ChurchScreen(),
        ),
        GoRoute(
          path: '/document',
          name: 'document',
          builder: (context, state) => const DocumentScreen(),
        ),
        GoRoute(
          path: '/income',
          name: 'income',
          builder: (context, state) => const IncomeScreen(),
        ),
        GoRoute(
          path: '/expenses',
          name: 'expenses',
          builder: (context, state) => const ExpensesScreen(),
        ),
        GoRoute(
          path: '/inventory',
          name: 'inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/reports',
          name: 'reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/account',
          name: 'account',
          builder: (context, state) => const AccountScreen(),
        ),
      ],
    ),
  ],
);
