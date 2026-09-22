/// Application color palette.
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────────────
  // Deep indigo/violet — conveys intelligence, trust, and premium quality.
  // This palette is inspired by modern AI products (Linear, Notion, etc.)

  static const Color primaryLight = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF818CF8); // Indigo 400 (lighter for dark mode)

  static const Color secondaryLight = Color(0xFF7C3AED); // Violet 600
  static const Color secondaryDark = Color(0xFFA78BFA); // Violet 400

  static const Color tertiaryLight = Color(0xFF0891B2); // Cyan 600
  static const Color tertiaryDark = Color(0xFF22D3EE); // Cyan 400

  // ── Surface Colors ────────────────────────────────────────────
  // Light mode surfaces
  static const Color surfaceLight = Color(0xFFFAFAFA); // Near white
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceContainerLight = Color(0xFFF8FAFC); // Slate 50

  // Dark mode surfaces
  static const Color surfaceDark = Color(0xFF0F172A); // Slate 900
  static const Color backgroundDark = Color(0xFF020617); // Slate 950
  static const Color surfaceVariantDark = Color(0xFF1E293B); // Slate 800
  static const Color surfaceContainerDark = Color(0xFF0F172A); // Slate 900

  // ── Text Colors ───────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400

  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Slate 100
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500

  // ── Semantic Colors ───────────────────────────────────────────
  // These are used for status indicators and feedback.
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // ── Document Status Colors ────────────────────────────────────
  // Custom colors specific to our app's domain.
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  static const Color statusProcessing = Color(0xFF3B82F6); // Blue
  static const Color statusReady = Color(0xFF10B981); // Emerald
  static const Color statusFailed = Color(0xFFEF4444); // Red

  // ── Border & Divider ──────────────────────────────────────────
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderDark = Color(0xFF334155); // Slate 700

  // ── Gradient ──────────────────────────────────────────────────
  // Use sparingly for hero sections or CTAs.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF818CF8), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
