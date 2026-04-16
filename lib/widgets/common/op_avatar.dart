import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// User avatar with initials fallback.
class OpAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const OpAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryMuted,
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initialsWidget(initials),
            )
          : _initialsWidget(initials),
    );
  }

  Widget _initialsWidget(String initials) {
    return Center(
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
