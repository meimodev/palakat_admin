import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:palakat_admin/core/services/auth_service_provider.dart';
import 'package:palakat_admin/core/services/auth_service.dart';

import 'core/theme/theme.dart';
import 'core/layout/app_scaffold.dart';
import 'core/navigation/page_transitions.dart';
import 'features/members/presentation/screens/members_screen.dart';
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
import 'features/activities/presentation/screens/activities_screen.dart';
import 'features/auth/presentation/screens/signin_screen.dart';
import 'features/auth/application/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables
  await dotenv.load(fileName: '.env');
  // Initialize Hive and open the auth box for cached session restore
  await AuthService.initHive();
  runApp(const ProviderScope(child: PalakatAdminApp()));
}

class PalakatAdminApp extends ConsumerWidget {
  const PalakatAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Palakat Admin',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (prev, next) {
    refresh.value++;
  });
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refresh,
    redirect: (context, state) {
      // Rely solely on AuthService's cached auth state
      final authService = ref.read(authServiceProvider);
      final isAuthed = authService.isAuthenticated;
      final goingToSignIn = state.matchedLocation == '/signin';
      String? route;
      if (!isAuthed && !goingToSignIn) route = '/signin';
      if (isAuthed && goingToSignIn) route = '/dashboard';
      return route;
    },
    routes: [
      GoRoute(
        path: '/signin',
        name: 'signin',
        pageBuilder: (context, state) => SmoothPageTransition<void>(
          key: state.pageKey,
          name: 'signin',
          child: const SignInScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'dashboard',
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/members',
            name: 'members',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'members',
              child: const MembersScreen(),
            ),
          ),
          GoRoute(
            path: '/approval',
            name: 'approval',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'approval',
              child: const ApprovalScreen(),
            ),
          ),
          GoRoute(
            path: '/activities',
            name: 'activities',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'activities',
              child: const ActivitiesScreen(),
            ),
          ),
          GoRoute(
            path: '/billing',
            name: 'billing',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'billing',
              child: const BillingScreen(),
            ),
          ),
          GoRoute(
            path: '/church',
            name: 'church',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'church',
              child: const ChurchScreen(),
            ),
          ),
          GoRoute(
            path: '/document',
            name: 'document',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'document',
              child: const DocumentScreen(),
            ),
          ),
          GoRoute(
            path: '/income',
            name: 'income',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'income',
              child: const IncomeScreen(),
            ),
          ),
          GoRoute(
            path: '/expenses',
            name: 'expenses',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'expenses',
              child: const ExpensesScreen(),
            ),
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'inventory',
              child: const InventoryScreen(),
            ),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'reports',
              child: const ReportsScreen(),
            ),
          ),
          GoRoute(
            path: '/account',
            name: 'account',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'account',
              child: const AccountScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
