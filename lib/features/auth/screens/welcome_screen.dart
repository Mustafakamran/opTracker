import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.zinc950,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo & Title
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
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

              AppSpacing.vGapXl,

              Text(
                'OpTracker',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              AppSpacing.vGapSm,

              Text(
                'Smart payment tracking\nfrom your notifications',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.zinc400,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

              const Spacer(flex: 2),

              // Feature highlights
              _FeatureRow(
                icon: Icons.notifications_active_rounded,
                text: 'Auto-detect payments from notifications',
                delay: 500,
              ),
              AppSpacing.vGapBase,
              _FeatureRow(
                icon: Icons.pie_chart_rounded,
                text: 'Smart budgets & spending insights',
                delay: 600,
              ),
              AppSpacing.vGapBase,
              _FeatureRow(
                icon: Icons.lock_rounded,
                text: 'Private & secure, data stays on device',
                delay: 700,
              ),

              const Spacer(flex: 2),

              // Sign in with Google
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                  label: const Text('Continue with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.zinc900,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

              AppSpacing.vGapMd,

              // Local account
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.push('/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.zinc700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Use without Google'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 900.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int delay;

  const _FeatureRow({
    required this.icon,
    required this.text,
    required this.delay,
  });

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
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.zinc300,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: -0.05, end: 0, curve: Curves.easeOutCubic);
  }
}
