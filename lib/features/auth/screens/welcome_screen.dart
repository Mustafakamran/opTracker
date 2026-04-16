import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/user_model.dart';

/// Provider to check if existing users are in the database.
final existingUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getAllUsers();
});

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final existingUsersAsync = ref.watch(existingUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.zinc950,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.wallet, color: Colors.white, size: 36),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  ),

              AppSpacing.vGapXl,

              Text(
                'OpTracker',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 200.ms, curve: Curves.easeOutCubic)
                  .fadeIn(delay: 200.ms, duration: 400.ms),

              AppSpacing.vGapSm,

              Text(
                'Smart payment tracking\nfrom your notifications',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: AppColors.zinc400, height: 1.5),
              )
                  .animate()
                  .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 350.ms, curve: Curves.easeOutCubic)
                  .fadeIn(delay: 350.ms, duration: 400.ms),

              const Spacer(flex: 2),

              // Feature highlights with slide-in
              _FeatureRow(icon: LucideIcons.bell, text: 'Auto-detect payments from notifications', delay: 450),
              AppSpacing.vGapBase,
              _FeatureRow(icon: LucideIcons.pieChart, text: 'Smart budgets & spending insights', delay: 550),
              AppSpacing.vGapBase,
              _FeatureRow(icon: LucideIcons.lock, text: 'Private & secure, data stays on device', delay: 650),

              const Spacer(flex: 2),

              // Check for existing users - show login or signup
              existingUsersAsync.when(
                loading: () => const SizedBox(height: 130),
                error: (_, __) => _buildSignupButtons(context, ref),
                data: (users) {
                  if (users.isNotEmpty) {
                    return _buildReturningUserButtons(context, ref, users);
                  }
                  return _buildSignupButtons(context, ref);
                },
              ),

              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Google Sign In - triggers directly
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () async {
              try {
                await ref.read(currentUserProvider.notifier).signInWithGoogle();
              } catch (_) {}
            },
            icon: const Icon(LucideIcons.user, size: 20),
            label: const Text('Continue with Google'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.zinc900,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        )
            .animate()
            .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 750.ms, curve: Curves.easeOutCubic)
            .fadeIn(delay: 750.ms, duration: 300.ms),

        AppSpacing.vGapMd,

        // Local account - goes DIRECTLY to signup form
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/signup'),
            icon: const Icon(LucideIcons.userPlus, size: 18),
            label: const Text('Create Local Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: AppColors.zinc700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        )
            .animate()
            .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 850.ms, curve: Curves.easeOutCubic)
            .fadeIn(delay: 850.ms, duration: 300.ms),
      ],
    );
  }

  Widget _buildReturningUserButtons(BuildContext context, WidgetRef ref, List<UserModel> users) {
    return Column(
      children: [
        // Show existing accounts
        ...users.take(3).map((user) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  if (user.pinHash != null) {
                    context.push('/pin-entry', extra: {'userId': user.id, 'username': user.username});
                  } else if (user.patternHash != null) {
                    context.push('/pin-entry', extra: {'userId': user.id, 'username': user.username});
                  } else {
                    // Google user - sign in directly
                    ref.read(currentUserProvider.notifier).signInWithGoogle();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.zinc700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.3),
                      child: Text(
                        (user.displayName ?? user.username).substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: Text(
                        user.displayName ?? user.username,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(
                      user.pinHash != null ? LucideIcons.lock : LucideIcons.fingerprint,
                      size: 18,
                      color: AppColors.zinc500,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        AppSpacing.vGapSm,

        // Add new account
        TextButton.icon(
          onPressed: () => context.push('/signup'),
          icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.zinc400),
          label: Text(
            'Add another account',
            style: GoogleFonts.inter(color: AppColors.zinc400, fontSize: 14),
          ),
        ),
      ],
    )
        .animate()
        .slideY(begin: 0.15, end: 0, duration: 400.ms, delay: 700.ms, curve: Curves.easeOutCubic)
        .fadeIn(delay: 700.ms, duration: 300.ms);
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int delay;

  const _FeatureRow({required this.icon, required this.text, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 18),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: AppColors.zinc300)),
        ),
      ],
    )
        .animate()
        .slideX(begin: -0.15, end: 0, delay: Duration(milliseconds: delay), duration: 500.ms, curve: Curves.easeOutCubic)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms);
  }
}
