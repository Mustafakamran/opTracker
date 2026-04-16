import 'package:flutter/material.dart';

/// Consistent spacing system inspired by Tailwind/shadcn.
class AppSpacing {
  AppSpacing._();

  // ── Spacing Scale ───────────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // ── Border Radius ───────────────────────────────────────────────
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusFull = 9999.0;

  // ── Page Padding ────────────────────────────────────────────────
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: base,
    vertical: md,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(base);

  static const EdgeInsets sectionPadding = EdgeInsets.only(bottom: xl);

  // ── Gaps (for Column/Row spacing) ──────────────────────────────
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapBase = SizedBox(height: base, width: base);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl, width: xxl);

  // ── Vertical-only Gaps ─────────────────────────────────────────
  static const SizedBox vGapXs = SizedBox(height: xs);
  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapBase = SizedBox(height: base);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);
  static const SizedBox vGapXxl = SizedBox(height: xxl);

  // ── Horizontal-only Gaps ───────────────────────────────────────
  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
  static const SizedBox hGapBase = SizedBox(width: base);
  static const SizedBox hGapLg = SizedBox(width: lg);
  static const SizedBox hGapXl = SizedBox(width: xl);
}
