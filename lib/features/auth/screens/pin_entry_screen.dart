import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/pin_pad.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  String _pin = '';
  bool _hasError = false;
  int _attempts = 0;

  static const _pinLength = 4;

  String? get _username {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    return extra?['username'] as String?;
  }

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength || _attempts >= 5) return;
    setState(() {
      _pin += digit;
      _hasError = false;
    });

    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 200), _verifyPin);
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _hasError = false;
    });
  }

  Future<void> _verifyPin() async {
    final username = _username;
    if (username == null) return;

    final success = await ref
        .read(currentUserProvider.notifier)
        .signInWithPin(username, _pin);

    if (!success && mounted) {
      setState(() {
        _hasError = true;
        _pin = '';
        _attempts++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              const Spacer(),

              Icon(LucideIcons.lock, size: 44, color: AppColors.primary)
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),

              AppSpacing.vGapLg,

              Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium)
                  .animate()
                  .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 100.ms, curve: Curves.easeOutCubic)
                  .fadeIn(delay: 100.ms),

              if (_username != null) ...[
                AppSpacing.vGapXs,
                Text(
                  _username!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.zinc500),
                ),
              ],

              AppSpacing.vGapXxl,

              PinDots(length: _pinLength, filled: _pin.length, error: _hasError),

              if (_hasError) ...[
                AppSpacing.vGapMd,
                Text(
                  _attempts >= 5 ? 'Too many attempts.' : 'Incorrect PIN. Try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                ).animate().shakeX(hz: 4, amount: 4, duration: 300.ms),
              ],

              const Spacer(),

              SizedBox(
                width: 280,
                child: PinPad(
                  onDigit: _onDigit,
                  onDelete: _onDelete,
                ),
              ),

              AppSpacing.vGapXl,
            ],
          ),
        ),
      ),
    );
  }
}
