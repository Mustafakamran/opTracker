import 'package:flutter/material.dart';

/// Shadcn-inspired color system using zinc/slate neutrals with a modern accent.
class AppColors {
  AppColors._();

  // ── Brand / Accent ──────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1);       // Indigo-500
  static const Color primaryLight = Color(0xFF818CF8);   // Indigo-400
  static const Color primaryDark = Color(0xFF4F46E5);    // Indigo-600
  static const Color primaryMuted = Color(0xFFEEF2FF);   // Indigo-50

  // ── Semantic ────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);        // Green-500
  static const Color successLight = Color(0xFFDCFCE7);   // Green-100
  static const Color warning = Color(0xFFF59E0B);        // Amber-500
  static const Color warningLight = Color(0xFFFEF3C7);   // Amber-100
  static const Color error = Color(0xFFEF4444);          // Red-500
  static const Color errorLight = Color(0xFFFEE2E2);     // Red-100
  static const Color info = Color(0xFF3B82F6);           // Blue-500
  static const Color infoLight = Color(0xFFDBEAFE);      // Blue-100

  // ── Zinc Neutrals (Light Mode) ─────────────────────────────────
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // ── Light Theme ─────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = zinc200;
  static const Color textPrimaryLight = zinc900;
  static const Color textSecondaryLight = zinc500;
  static const Color textMutedLight = zinc400;

  // ── Dark Theme ──────────────────────────────────────────────────
  static const Color backgroundDark = zinc950;
  static const Color surfaceDark = zinc900;
  static const Color cardDark = zinc800;
  static const Color borderDark = zinc700;
  static const Color textPrimaryDark = zinc50;
  static const Color textSecondaryDark = zinc400;
  static const Color textMutedDark = zinc500;

  // ── Category Colors ─────────────────────────────────────────────
  static const Color categoryFood = Color(0xFFF97316);
  static const Color categoryShopping = Color(0xFFEC4899);
  static const Color categoryBills = Color(0xFF8B5CF6);
  static const Color categoryTransfer = Color(0xFF06B6D4);
  static const Color categoryEntertainment = Color(0xFFF43F5E);
  static const Color categoryTransport = Color(0xFF14B8A6);
  static const Color categoryHealth = Color(0xFF22C55E);
  static const Color categoryEducation = Color(0xFF3B82F6);
  static const Color categorySubscription = Color(0xFFA855F7);
  static const Color categoryOther = Color(0xFF6B7280);
}
