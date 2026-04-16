import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/pin_setup_screen.dart';
import '../../features/auth/screens/pin_entry_screen.dart';
import '../../features/auth/screens/pattern_setup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/transactions/screens/transaction_detail_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../features/budget/screens/budgets_screen.dart';
import '../../features/budget/screens/create_budget_screen.dart';
import '../../features/budget/screens/budget_suggestions_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../widgets/common/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuth = user != null;
      final isAuthRoute = state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/pin-setup' ||
          state.matchedLocation == '/pin-entry' ||
          state.matchedLocation == '/pattern-setup';

      if (!isAuth && !isAuthRoute) return '/welcome';
      if (isAuth && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      // ── Auth Routes ───────────────────────────────────────────
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: '/pin-setup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PinSetupScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: '/pin-entry',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PinEntryScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: '/pattern-setup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PatternSetupScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),

      // ── Main Shell (Bottom Nav) ───────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TransactionsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/budgets',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BudgetsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),

      // ── Detail Routes ─────────────────────────────────────────
      GoRoute(
        path: '/transactions/:id',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: TransactionDetailScreen(
            transactionId: state.pathParameters['id']!,
          ),
          transitionsBuilder: _slideLeftTransition,
        ),
      ),
      GoRoute(
        path: '/add-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddTransactionScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: '/create-budget',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateBudgetScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: '/budget-suggestions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BudgetSuggestionsScreen(),
          transitionsBuilder: _slideLeftTransition,
        ),
      ),
    ],
  );
});

// ── Transition Builders ───────────────────────────────────────────

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween(
    begin: const Offset(0, 0.15),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));
  return SlideTransition(
    position: animation.drive(tween),
    child: FadeTransition(opacity: animation, child: child),
  );
}

Widget _slideLeftTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween(
    begin: const Offset(0.15, 0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));
  return SlideTransition(
    position: animation.drive(tween),
    child: FadeTransition(opacity: animation, child: child),
  );
}
