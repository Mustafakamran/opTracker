import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/budgets')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => _navigate(context, i),
          elevation: 0,
          height: 64,
          backgroundColor: isDark ? AppColors.zinc900 : Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primary.withOpacity(0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 400),
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard, size: 20),
              selectedIcon: Icon(LucideIcons.layoutDashboard, size: 20),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.arrowLeftRight, size: 20),
              selectedIcon: Icon(LucideIcons.arrowLeftRight, size: 20),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.pieChart, size: 20),
              selectedIcon: Icon(LucideIcons.pieChart, size: 20),
              label: 'Budgets',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.settings, size: 20),
              selectedIcon: Icon(LucideIcons.settings, size: 20),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/dashboard');
      case 1: context.go('/transactions');
      case 2: context.go('/budgets');
      case 3: context.go('/settings');
    }
  }
}
