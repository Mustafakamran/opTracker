import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/pin_pad.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = '';
  String? _firstPin;
  bool _isConfirming = false;
  bool _hasError = false;
  bool _isLoading = false;

  static const _pinLength = 4;

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += digit;
      _hasError = false;
    });

    if (_pin.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 200), _handleComplete);
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _hasError = false;
    });
  }

  Future<void> _handleComplete() async {
    if (!_isConfirming) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
      return;
    }

    if (_pin != _firstPin) {
      setState(() {
        _hasError = true;
        _pin = '';
      });
      return;
    }

    setState(() => _isLoading = true);

    final extra = GoRouterState.of(context).extra as Map<String, String>?;
    final username = extra?['username'] ?? 'user';
    final displayName = extra?['displayName'] ?? 'User';

    try {
      await ref.read(currentUserProvider.notifier).createLocalUser(
            username: username,
            displayName: displayName,
            pin: _pin,
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _pin = '';
          _firstPin = null;
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
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
              ).animate().fadeIn(duration: 300.ms),

              AppSpacing.vGapLg,

              Text(
                _isConfirming ? 'Confirm Your PIN' : 'Create a PIN',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

              AppSpacing.vGapSm,

              Text(
                _isConfirming
                    ? 'Enter the same PIN again to confirm'
                    : 'This PIN will protect your account',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.zinc500,
                    ),
                textAlign: TextAlign.center,
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
                  'PINs don\'t match. Try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ).animate().shakeX(hz: 3, amount: 4, duration: 300.ms),
              ],

              const Spacer(),

              if (_isLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: 280,
                  child: PinPad(
                    onDigit: _onDigit,
                    onDelete: _onDelete,
                  ),
                ),

              AppSpacing.vGapXl,

              TextButton(
                onPressed: () => context.push('/pattern-setup',
                    extra: GoRouterState.of(context).extra),
                child: const Text('Use pattern lock instead'),
              ),

              AppSpacing.vGapBase,
            ],
          ),
        ),
      ),
    );
  }
}
