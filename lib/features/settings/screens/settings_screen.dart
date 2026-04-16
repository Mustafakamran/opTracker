import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/common/op_avatar.dart';
import '../../../widgets/common/op_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _fundsController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _fundsController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // Profile Card
          OpCard(
            animate: true,
            child: Row(
              children: [
                OpAvatar(name: user?.displayName ?? 'User', imageUrl: user?.avatarUrl, size: 52),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'User', style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        user?.email ?? '@${user?.username ?? 'local'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.zinc400),
                      ),
                      AppSpacing.vGapXs,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: user?.authMethod == AuthMethod.google ? AppColors.primarySoft : AppColors.zinc100,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          user?.authMethod == AuthMethod.google ? 'Google' : 'Local',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: user?.authMethod == AuthMethod.google ? AppColors.primary : AppColors.zinc500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: AppColors.zinc400, size: 18),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // Account Switcher
          _SectionHeader(title: 'ACCOUNTS', delay: 80),
          AppSpacing.vGapSm,
          OpCard(
            animate: true,
            animationDelay: 100,
            child: Column(
              children: [
                _SettingsTile(
                  icon: LucideIcons.users,
                  iconColor: AppColors.primary,
                  title: 'Switch Account',
                  subtitle: 'Login to a different account',
                  onTap: () => _showAccountSwitcher(context),
                ),
                const Divider(height: 24),
                _SettingsTile(
                  icon: LucideIcons.userPlus,
                  iconColor: AppColors.info,
                  title: 'Add Account',
                  subtitle: 'Create or sign in with another account',
                  onTap: () {
                    ref.read(currentUserProvider.notifier).signOut();
                  },
                ),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // Financial Setup
          _SectionHeader(title: 'FINANCIAL SETUP', delay: 150),
          AppSpacing.vGapSm,
          OpCard(
            animate: true,
            animationDelay: 180,
            child: Column(
              children: [
                _SettingsTile(
                  icon: LucideIcons.wallet,
                  iconColor: AppColors.primary,
                  title: 'Available Funds',
                  subtitle: CurrencyFormatter.format(user?.availableFunds ?? 0),
                  onTap: () => _editFunds(context),
                ),
                const Divider(height: 24),
                _SettingsTile(
                  icon: LucideIcons.wallet,
                  iconColor: AppColors.success,
                  title: 'Monthly Budget',
                  subtitle: CurrencyFormatter.format(user?.monthlyBudget ?? 0),
                  onTap: () => _editBudget(context),
                ),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // AI
          _SectionHeader(title: 'AI ASSISTANT', delay: 200),
          AppSpacing.vGapSm,
          OpCard(
            animate: true,
            animationDelay: 210,
            onTap: () => context.push('/ai-settings'),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(LucideIcons.brain, size: 18, color: Colors.white),
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget AI (Gemma)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text('On-device AI for smart suggestions', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.zinc400)),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.zinc400),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // App Settings
          _SectionHeader(title: 'APP SETTINGS', delay: 220),
          AppSpacing.vGapSm,
          OpCard(
            animate: true,
            animationDelay: 250,
            child: Column(
              children: [
                _SettingsTile(
                  icon: isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                  iconColor: AppColors.warning,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (v) => ref.read(themeModeProvider.notifier).state = v,
                    activeColor: AppColors.primary,
                  ),
                ),
                const Divider(height: 24),
                _SettingsTile(
                  icon: LucideIcons.bell,
                  iconColor: AppColors.info,
                  title: 'Notification Listener',
                  subtitle: 'Auto-detect payments',
                  onTap: () => _requestNotificationAccess(),
                ),
                const Divider(height: 24),
                _SettingsTile(
                  icon: LucideIcons.wallet,
                  iconColor: AppColors.success,
                  title: 'Currency',
                  subtitle: user?.currency ?? 'USD',
                  onTap: () {},
                ),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // Data
          _SectionHeader(title: 'DATA', delay: 300),
          AppSpacing.vGapSm,
          OpCard(
            animate: true,
            animationDelay: 330,
            child: Column(
              children: [
                _SettingsTile(
                  icon: LucideIcons.arrowUp,
                  iconColor: AppColors.primary,
                  title: 'Backup Data',
                  subtitle: 'Export to Google Drive',
                  onTap: () {},
                ),
                const Divider(height: 24),
                _SettingsTile(
                  icon: LucideIcons.download,
                  iconColor: AppColors.zinc600,
                  title: 'Export CSV',
                  subtitle: 'Download transactions',
                  onTap: () {},
                ),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // Sign Out
          OpCard(
            animate: true,
            animationDelay: 380,
            onTap: () => _confirmSignOut(context),
            child: Row(
              children: [
                const Icon(LucideIcons.arrowLeft, color: AppColors.error, size: 18),
                AppSpacing.hGapMd,
                Text('Sign Out',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.error, fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          Center(
            child: Text('OpTracker v1.0.0',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.zinc400)),
          ).animate().fadeIn(delay: 450.ms, duration: 300.ms),

          AppSpacing.vGapXxl,
        ],
      ),
    );
  }

  void _showAccountSwitcher(BuildContext context) async {
    final authService = ref.read(authServiceProvider);
    final users = await authService.getAllUsers();
    final currentUser = ref.read(currentUserProvider);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Switch Account', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.vGapBase,
            ...users.map((user) {
              final isCurrent = user.id == currentUser?.id;
              return ListTile(
                leading: OpAvatar(name: user.displayName ?? user.username, size: 40),
                title: Text(user.displayName ?? user.username),
                subtitle: Text(user.authMethod == AuthMethod.google ? user.email ?? '' : '@${user.username}'),
                trailing: isCurrent ? const Icon(LucideIcons.check, color: AppColors.primary, size: 18) : null,
                onTap: isCurrent
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        // Sign out current, redirect to pin entry for selected user
                        ref.read(currentUserProvider.notifier).signOut();
                      },
              );
            }),
            AppSpacing.vGapBase,
          ],
        ),
      ),
    );
  }

  void _requestNotificationAccess() async {
    final listener = ref.read(notificationListenerProvider);
    final hasPermission = await listener.hasPermission();
    if (!hasPermission) {
      await listener.requestPermission();
    }
  }

  void _editFunds(BuildContext context) {
    final user = ref.read(currentUserProvider);
    _fundsController.text = (user?.availableFunds ?? 0).toStringAsFixed(2);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.base, AppSpacing.base,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set Available Funds', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.vGapBase,
            TextField(
              controller: _fundsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(prefixText: '\$ ', labelText: 'Available Funds'),
              autofocus: true,
            ),
            AppSpacing.vGapBase,
            ElevatedButton(
              onPressed: () {
                final funds = double.tryParse(_fundsController.text);
                if (funds != null && user != null) {
                  final updated = user.copyWith(availableFunds: funds);
                  ref.read(userRepoProvider).update(updated);
                  ref.read(currentUserProvider.notifier).updateUser(updated);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editBudget(BuildContext context) {
    final user = ref.read(currentUserProvider);
    _budgetController.text = (user?.monthlyBudget ?? 0).toStringAsFixed(2);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.base, AppSpacing.base, AppSpacing.base,
            MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set Monthly Budget', style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.vGapBase,
            TextField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(prefixText: '\$ ', labelText: 'Monthly Budget'),
              autofocus: true,
            ),
            AppSpacing.vGapBase,
            ElevatedButton(
              onPressed: () {
                final budget = double.tryParse(_budgetController.text);
                if (budget != null && user != null) {
                  final updated = user.copyWith(monthlyBudget: budget);
                  ref.read(userRepoProvider).update(updated);
                  ref.read(currentUserProvider.notifier).updateUser(updated);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Your data will remain on this device. You can sign back in anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(currentUserProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int delay;
  const _SectionHeader({required this.title, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.zinc400, fontWeight: FontWeight.w600, letterSpacing: 1),
    )
        .animate()
        .slideX(begin: -0.05, end: 0, delay: Duration(milliseconds: delay), duration: 300.ms, curve: Curves.easeOutCubic)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 250.ms);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon, required this.iconColor, required this.title,
    this.subtitle, this.trailing, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.zinc400)),
              ],
            ),
          ),
          trailing ?? const Icon(LucideIcons.chevronRight, color: AppColors.zinc400, size: 16),
        ],
      ),
    );
  }
}
