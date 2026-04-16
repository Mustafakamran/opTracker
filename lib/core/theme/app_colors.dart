import 'package:flutter/material.dart';

/// Blue analogous color system - single hue with tonal variations.
class AppColors {
  AppColors._();

  // ── Brand / Blue Accent ─────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);       // Blue-600
  static const Color primaryLight = Color(0xFF60A5FA);   // Blue-400
  static const Color primaryDark = Color(0xFF1D4ED8);    // Blue-700
  static const Color primaryMuted = Color(0xFFEFF6FF);   // Blue-50
  static const Color primarySoft = Color(0xFFDBEAFE);    // Blue-100
  static const Color primaryDeep = Color(0xFF1E40AF);    // Blue-800

  // ── Semantic ────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);        // Green-600
  static const Color successLight = Color(0xFFDCFCE7);   // Green-100
  static const Color warning = Color(0xFFD97706);        // Amber-600
  static const Color warningLight = Color(0xFFFEF3C7);   // Amber-100
  static const Color error = Color(0xFFDC2626);          // Red-600
  static const Color errorLight = Color(0xFFFEE2E2);     // Red-100
  static const Color info = Color(0xFF0284C7);           // Sky-600
  static const Color infoLight = Color(0xFFE0F2FE);      // Sky-100

  // ── Slate Neutrals ─────────────────────────────────────────────
  static const Color zinc50 = Color(0xFFF8FAFC);    // Slate-50
  static const Color zinc100 = Color(0xFFF1F5F9);   // Slate-100
  static const Color zinc200 = Color(0xFFE2E8F0);   // Slate-200
  static const Color zinc300 = Color(0xFFCBD5E1);   // Slate-300
  static const Color zinc400 = Color(0xFF94A3B8);   // Slate-400
  static const Color zinc500 = Color(0xFF64748B);   // Slate-500
  static const Color zinc600 = Color(0xFF475569);   // Slate-600
  static const Color zinc700 = Color(0xFF334155);   // Slate-700
  static const Color zinc800 = Color(0xFF1E293B);   // Slate-800
  static const Color zinc900 = Color(0xFF0F172A);   // Slate-900
  static const Color zinc950 = Color(0xFF020617);   // Slate-950

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

  // ── Category Colors (blue-tinted variants) ──────────────────────
  static const Color categoryFood = Color(0xFFEA580C);
  static const Color categoryShopping = Color(0xFFDB2777);
  static const Color categoryBills = Color(0xFF7C3AED);
  static const Color categoryTransfer = Color(0xFF0891B2);
  static const Color categoryEntertainment = Color(0xFFE11D48);
  static const Color categoryTransport = Color(0xFF0D9488);
  static const Color categoryHealth = Color(0xFF16A34A);
  static const Color categoryEducation = Color(0xFF2563EB);
  static const Color categorySubscription = Color(0xFF9333EA);
  static const Color categoryOther = Color(0xFF64748B);
}
