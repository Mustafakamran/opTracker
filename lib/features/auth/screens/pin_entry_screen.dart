import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
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
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final success = await ref
        .read(currentUserProvider.notifier)
        .signInWithPin(user.username, _pin);

    if (!success) {
      setState(() {
        _hasError = true;
        _pin = '';
        _attempts++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              const Spacer(),

              Icon(
                Icons.lock_rounded,
                size: 48,
                color: AppColors.primary,
              ),

              AppSpacing.vGapLg,

              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              AppSpacing.vGapXs,

              if (user != null)
                Text(
                  user.displayName ?? user.username,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.zinc500,
                      ),
                ),

              AppSpacing.vGapXxl,

              PinDots(
                length: _pinLength,
                filled: _pin.length,
                error: _hasError,
              ),

              if (_hasError) ...[
                AppSpacing.vGapMd,
                Text(
                  _attempts >= 3
                      ? 'Too many attempts. Please wait.'
                      : 'Incorrect PIN. Try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ).animate().shakeX(hz: 3, amount: 4, duration: 300.ms),
              ],

              const Spacer(),

              SizedBox(
                width: 280,
                child: PinPad(
                  onDigit: _attempts >= 5 ? (_) {} : _onDigit,
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
