import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // Profile Card
          OpCard(
            animate: true,
            child: Row(
              children: [
                OpAvatar(
                  name: user?.displayName ?? 'User',
                  imageUrl: user?.avatarUrl,
                  size: 52,
                ),
                AppSpacing.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        user?.email ?? '@${user?.username ?? 'local'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.zinc400,
                            ),
                      ),
                      AppSpacing.vGapXs,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user?.authMethod == AuthMethod.google
                              ? AppColors.infoLight
                              : AppColors.zinc100,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          user?.authMethod == AuthMethod.google ? 'Google' : 'Local',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: user?.authMethod == AuthMethod.google
                                    ? AppColors.info
                                    : AppColors.zinc500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.zinc400),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // Funds Management
          Text(
            'FINANCIAL SETUP',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.zinc400,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          AppSpacing.vGapSm,

          OpCard(
            animate: true,
            animationDelay: 150,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.primary,
                  title: 'Available Funds',
                  subtitle: CurrencyFormatter.format(user?.availableFunds ?? 0),
                  onTap: () => _editFunds(context),
                ),
                const Divider(height: 24),
                _SettingsTile(
                  icon: Icons.savings_rounded,
                  iconColor: AppColors.success,
                  title: 'Monthly Budget',
                  subtitle: CurrencyFormatter.format(user?.monthlyBudget ?? 0),
                  onTap: () => _editBudget(context),
                ),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // App Settings
          Text(
            'APP SETTINGS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.zinc400,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

          AppSpacing.vGapSm,

          OpCard(
            animate: true,
            animationDelay: 250,
            child: Column(
              children: [
                _SettingsTile(
                  icon: isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
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
                  icon: Icons.notifications_rounded,
                  iconColor: AppColors.info,
                  title: 'Notification Listener',
                  subtitle: 'Auto-detect payments',
                  onTap: () {},
                ),
                const Divider(height: 24),
                _SettingsTile(
                  icon: Icons.currency_exchange_rounded,
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
          Text(
            'DATA',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.zinc400,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
          ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

          AppSpacing.vGapSm,

          OpCard(
            animate: true,
            animationDelay: 350,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.cloud_upload_rounded,
                  iconColor: AppColors.primary,
                  title: 'Backup Data',
                  subtitle: 'Export to Google Drive',
                  onTap: () {},
                ),
                const Divider(height: 24),
                _SettingsTile(
                  icon: Icons.download_rounded,
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
            animationDelay: 400,
            onTap: () => _confirmSignOut(context),
            child: Row(
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                AppSpacing.hGapMd,
                Text(
                  'Sign Out',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),

          AppSpacing.vGapBase,

          // About
          Center(
            child: Column(
              children: [
                Text(
                  'OpTracker v1.0.0',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.zinc400,
                      ),
                ),
                Text(
                  'Your smart payment companion',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.zinc300,
                      ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

          AppSpacing.vGapXxl,
        ],
      ),
    );
  }

  void _editFunds(BuildContext context) {
    final user = ref.read(currentUserProvider);
    _fundsController.text = (user?.availableFunds ?? 0).toStringAsFixed(2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.base,
          AppSpacing.base,
          MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set Available Funds',
                style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.vGapBase,
            TextField(
              controller: _fundsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Available Funds',
              ),
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
        padding: EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.base,
          AppSpacing.base,
          MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set Monthly Budget',
                style: Theme.of(context).textTheme.titleMedium),
            AppSpacing.vGapBase,
            TextField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Monthly Budget',
              ),
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
        content: const Text('Your data will remain on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.zinc400,
                        ),
                  ),
              ],
            ),
          ),
          trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.zinc400),
        ],
      ),
    );
  }
}
