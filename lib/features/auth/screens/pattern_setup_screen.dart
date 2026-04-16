import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/pattern_grid.dart';

class PatternSetupScreen extends ConsumerStatefulWidget {
  const PatternSetupScreen({super.key});

  @override
  ConsumerState<PatternSetupScreen> createState() => _PatternSetupScreenState();
}

class _PatternSetupScreenState extends ConsumerState<PatternSetupScreen> {
  List<int> _pattern = [];
  List<int>? _firstPattern;
  bool _isConfirming = false;
  bool _hasError = false;
  String? _errorMessage;

  void _onPatternComplete(List<int> pattern) {
    if (pattern.length < 4) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Connect at least 4 dots';
        _pattern = [];
      });
      return;
    }

    if (!_isConfirming) {
      setState(() {
        _firstPattern = List.from(pattern);
        _pattern = [];
        _isConfirming = true;
        _hasError = false;
      });
      return;
    }

    // Confirming
    bool matches = pattern.length == _firstPattern!.length;
    if (matches) {
      for (int i = 0; i < pattern.length; i++) {
        if (pattern[i] != _firstPattern![i]) {
          matches = false;
          break;
        }
      }
    }

    if (!matches) {
      setState(() {
        _hasError = true;
        _errorMessage = "Patterns don't match. Try again.";
        _pattern = [];
      });
      return;
    }

    _createAccount(pattern);
  }

  void _onPatternUpdate(List<int> pattern) {
    setState(() {
      _pattern = pattern;
      _hasError = false;
    });
  }

  Future<void> _createAccount(List<int> pattern) async {
    final extra = GoRouterState.of(context).extra as Map<String, String>?;
    final username = extra?['username'] ?? 'user';
    final displayName = extra?['displayName'] ?? 'User';

    try {
      await ref.read(currentUserProvider.notifier).createLocalUser(
            username: username,
            displayName: displayName,
            pattern: pattern.join('-'),
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Account creation failed. Username may already exist.';
          _pattern = [];
          _firstPattern = null;
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
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            children: [
              AppSpacing.vGapXl,

              Text(
                _isConfirming ? 'Confirm Pattern' : 'Draw a Pattern',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              AppSpacing.vGapSm,

              Text(
                _isConfirming
                    ? 'Draw the same pattern again'
                    : 'Drag your finger across dots to connect them',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.zinc500),
                textAlign: TextAlign.center,
              ),

              if (_hasError && _errorMessage != null) ...[
                AppSpacing.vGapMd,
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],

              const Spacer(),

              // Pattern grid with drag support
              PatternGrid(
                pattern: _pattern,
                onPatternUpdate: _onPatternUpdate,
                onPatternComplete: _onPatternComplete,
                hasError: _hasError,
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        _pattern = [];
                        _hasError = false;
                      }),
                      child: const Text('Reset'),
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pattern.length >= 4 ? () => _onPatternComplete(_pattern) : null,
                      child: Text(_isConfirming ? 'Confirm' : 'Continue'),
                    ),
                  ),
                ],
              ),

              AppSpacing.vGapXl,
            ],
          ),
        ),
      ),
    );
  }
}
