import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/pin_pad.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLocalMode = false;
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(currentUserProvider.notifier).signInWithGoogle();
    } catch (e) {
      setState(() => _error = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLocalSetup() async {
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

    // Navigate to PIN setup
    if (mounted) {
      context.push('/pin-setup', extra: {
        'username': username,
        'displayName': displayName,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_isLocalMode ? 'Create Account' : 'Sign In'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.vGapXl,

            if (!_isLocalMode) ...[
              // Google Sign In Section
              Text(
                'Welcome to OpTracker',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(duration: 300.ms),

              AppSpacing.vGapSm,

              Text(
                'Sign in to sync your data across devices, or create a local account.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.zinc500,
                    ),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

              AppSpacing.vGapXxl,

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.g_mobiledata_rounded, size: 24),
                  label: Text(_isLoading ? 'Signing in...' : 'Continue with Google'),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

              AppSpacing.vGapLg,

              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.zinc200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.zinc400,
                          ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.zinc200)),
                ],
              ),

              AppSpacing.vGapLg,

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _isLocalMode = true),
                  icon: const Icon(Icons.person_rounded, size: 20),
                  label: const Text('Create Local Account'),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
            ] else ...[
              // Local Account Setup
              Text(
                'Set Up Your Profile',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(duration: 300.ms),

              AppSpacing.vGapSm,

              Text(
                'Your data stays on this device. No account needed.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.zinc500,
                    ),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

              AppSpacing.vGapXxl,

              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'How should we call you?',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

              AppSpacing.vGapBase,

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Choose a unique username',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                textInputAction: TextInputAction.done,
              ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

              AppSpacing.vGapXxl,

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleLocalSetup,
                  child: const Text('Continue to PIN Setup'),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

              AppSpacing.vGapMd,

              TextButton(
                onPressed: () => setState(() => _isLocalMode = false),
                child: const Text('Back to sign-in options'),
              ),
            ],

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
                    const Icon(Icons.error_rounded, color: AppColors.error, size: 20),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
