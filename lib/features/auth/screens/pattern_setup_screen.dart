import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';

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
  bool _isDrawing = false;

  void _onDotTap(int index) {
    if (_pattern.contains(index)) return;
    setState(() {
      _pattern.add(index);
      _hasError = false;
      _isDrawing = true;
    });
  }

  void _onComplete() {
    if (_pattern.length < 4) {
      setState(() {
        _hasError = true;
        _pattern = [];
      });
      return;
    }

    if (!_isConfirming) {
      setState(() {
        _firstPattern = List.from(_pattern);
        _pattern = [];
        _isConfirming = true;
        _isDrawing = false;
      });
      return;
    }

    if (!_listEquals(_pattern, _firstPattern!)) {
      setState(() {
        _hasError = true;
        _pattern = [];
        _isDrawing = false;
      });
      return;
    }

    _createAccount();
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _createAccount() async {
    final extra = GoRouterState.of(context).extra as Map<String, String>?;
    final username = extra?['username'] ?? 'user';
    final displayName = extra?['displayName'] ?? 'User';

    try {
      await ref.read(currentUserProvider.notifier).createLocalUser(
            username: username,
            displayName: displayName,
            pattern: _pattern.join('-'),
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _pattern = [];
          _firstPattern = null;
          _isConfirming = false;
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _pattern = [];
      _isDrawing = false;
    });
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
              AppSpacing.vGapXl,

              Text(
                _isConfirming ? 'Confirm Pattern' : 'Draw a Pattern',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              AppSpacing.vGapSm,

              Text(
                _isConfirming
                    ? 'Draw the same pattern again'
                    : 'Connect at least 4 dots',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.zinc500,
                    ),
              ),

              if (_hasError) ...[
                AppSpacing.vGapMd,
                Text(
                  _pattern.length < 4
                      ? 'Connect at least 4 dots'
                      : 'Patterns don\'t match. Try again.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ],

              const Spacer(),

              // Pattern Grid 3x3
              SizedBox(
                width: 240,
                height: 240,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final isSelected = _pattern.contains(index);
                    return GestureDetector(
                      onTap: () => _onDotTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.zinc100,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : _hasError
                                    ? AppColors.error.withOpacity(0.5)
                                    : AppColors.zinc300,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 16 : 0,
                            height: isSelected ? 16 : 0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pattern.length >= 4 ? _onComplete : null,
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
