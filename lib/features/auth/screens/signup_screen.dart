import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _continue() {
    final username = _usernameController.text.trim();
    final displayName = _displayNameController.text.trim();

    if (username.isEmpty || displayName.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (username.length < 3) {
      setState(() => _error = 'Username must be at least 3 characters');
      return;
    }

    context.push('/pin-setup', extra: {
      'username': username,
      'displayName': displayName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.vGapXl,

            // Avatar placeholder with spring animation
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                ),
                child: const Icon(LucideIcons.user, size: 40, color: AppColors.primary),
              ),
            )
                .animate()
                .scale(begin: const Offset(0.6, 0.6), duration: 500.ms, curve: Curves.elasticOut),

            AppSpacing.vGapLg,

            Text(
              'Set Up Your Profile',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            )
                .animate()
                .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 100.ms, curve: Curves.easeOutCubic)
                .fadeIn(delay: 100.ms, duration: 300.ms),

            AppSpacing.vGapSm,

            Text(
              'Your data stays on this device. No cloud account needed.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.zinc500),
            )
                .animate()
                .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms, curve: Curves.easeOutCubic)
                .fadeIn(delay: 200.ms, duration: 300.ms),

            AppSpacing.vGapXxl,

            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'How should we call you?',
                prefixIcon: Icon(LucideIcons.user, size: 18),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            )
                .animate()
                .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 300.ms, curve: Curves.easeOutCubic)
                .fadeIn(delay: 300.ms, duration: 300.ms),

            AppSpacing.vGapBase,

            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Choose a unique username',
                prefixIcon: Icon(LucideIcons.atSign, size: 18),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _continue(),
            )
                .animate()
                .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 400.ms, curve: Curves.easeOutCubic)
                .fadeIn(delay: 400.ms, duration: 300.ms),

            if (_error != null) ...[
              AppSpacing.vGapBase,
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 18),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: Text(_error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              )
                  .animate()
                  .shakeX(hz: 3, amount: 3, duration: 400.ms),
            ],

            AppSpacing.vGapXxl,

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _continue,
                icon: const Icon(LucideIcons.arrowRight, size: 18),
                label: const Text('Continue to Security Setup'),
              ),
            )
                .animate()
                .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 500.ms, curve: Curves.easeOutCubic)
                .fadeIn(delay: 500.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
