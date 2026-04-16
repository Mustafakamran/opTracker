import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class PinPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;

  const PinPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onBiometric,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', 'del',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final label = buttons[index];

        if (label.isEmpty) {
          return onBiometric != null
              ? _PinButton(
                  onTap: onBiometric!,
                  child: const Icon(Icons.fingerprint_rounded, size: 28),
                )
              : const SizedBox();
        }

        if (label == 'del') {
          return _PinButton(
            onTap: onDelete,
            child: const Icon(Icons.backspace_rounded, size: 22),
          );
        }

        return _PinButton(
          onTap: () {
            HapticFeedback.lightImpact();
            onDigit(label);
          },
          child: Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}

class _PinButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _PinButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.zinc800 : AppColors.zinc50,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Center(child: child),
      ),
    );
  }
}

class PinDots extends StatelessWidget {
  final int length;
  final int filled;
  final bool error;

  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: isFilled ? 16 : 12,
          height: isFilled ? 16 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: error
                ? AppColors.error
                : isFilled
                    ? AppColors.primary
                    : AppColors.zinc200,
            border: !isFilled && !error
                ? Border.all(color: AppColors.zinc300)
                : null,
          ),
        );
      }),
    );
  }
}
