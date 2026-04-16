import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
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
import '../../features/settings/screens/ai_settings_screen.dart';
import '../../widgets/common/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuth = user != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/welcome' || loc == '/signup' ||
          loc == '/pin-setup' || loc == '/pin-entry' ||
          loc == '/pattern-setup' || loc == '/pattern-entry' ||
          loc == '/login';

      if (!isAuth && !isAuthRoute) return '/welcome';
      if (isAuth && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: _morphTransition,
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionsBuilder: _sharedAxisVertical,
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(), // Reuse signup for now
          transitionsBuilder: _sharedAxisVertical,
        ),
      ),
      GoRoute(
        path: '/pin-setup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PinSetupScreen(),
          transitionsBuilder: _sharedAxisVertical,
        ),
      ),
      GoRoute(
        path: '/pin-entry',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PinEntryScreen(),
          transitionsBuilder: _morphTransition,
        ),
      ),
      GoRoute(
        path: '/pattern-setup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PatternSetupScreen(),
          transitionsBuilder: _sharedAxisVertical,
        ),
      ),

      // ── Main Shell ────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: _sharedAxisHorizontal,
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TransactionsScreen(),
              transitionsBuilder: _sharedAxisHorizontal,
            ),
          ),
          GoRoute(
            path: '/budgets',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BudgetsScreen(),
              transitionsBuilder: _sharedAxisHorizontal,
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: _sharedAxisHorizontal,
            ),
          ),
        ],
      ),

      // ── Detail Routes ─────────────────────────────────────────
      GoRoute(
        path: '/transactions/:id',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: TransactionDetailScreen(transactionId: state.pathParameters['id']!),
          transitionsBuilder: _containerTransform,
        ),
      ),
      GoRoute(
        path: '/add-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddTransactionScreen(),
          transitionsBuilder: _sharedAxisVertical,
        ),
      ),
      GoRoute(
        path: '/create-budget',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateBudgetScreen(),
          transitionsBuilder: _sharedAxisVertical,
        ),
      ),
      GoRoute(
        path: '/budget-suggestions',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BudgetSuggestionsScreen(),
          transitionsBuilder: _containerTransform,
        ),
      ),
      GoRoute(
        path: '/ai-settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AiSettingsScreen(),
          transitionsBuilder: _sharedAxisVertical,
        ),
      ),
    ],
  );
});

// ── Morph Transition (scale + fade, smooth and premium) ─────────

Widget _morphTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
  return FadeTransition(
    opacity: curvedAnimation,
    child: ScaleTransition(
      scale: Tween(begin: 0.92, end: 1.0).animate(curvedAnimation),
      child: child,
    ),
  );
}

// ── Shared Axis Horizontal (tab switches) ───────────────────────

Widget _sharedAxisHorizontal(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curvedAnim = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
  final secondaryCurved = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic);

  return FadeTransition(
    opacity: Tween(begin: 0.0, end: 1.0).animate(curvedAnim),
    child: SlideTransition(
      position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(curvedAnim),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.7).animate(secondaryCurved),
        child: SlideTransition(
          position: Tween(begin: Offset.zero, end: const Offset(-0.08, 0)).animate(secondaryCurved),
          child: child,
        ),
      ),
    ),
  );
}

// ── Shared Axis Vertical (modal push) ───────────────────────────

Widget _sharedAxisVertical(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curvedAnim = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
  return FadeTransition(
    opacity: curvedAnim,
    child: SlideTransition(
      position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(curvedAnim),
      child: child,
    ),
  );
}

// ── Container Transform (list → detail, scale morph) ────────────

Widget _containerTransform(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curvedAnim = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
  return FadeTransition(
    opacity: curvedAnim,
    child: ScaleTransition(
      scale: Tween(begin: 0.94, end: 1.0).animate(curvedAnim),
      alignment: Alignment.center,
      child: child,
    ),
  );
}
