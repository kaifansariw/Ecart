import 'package:flutter/material.dart';

/// Curated luxury color palette.
/// Every color is intentionally chosen — no generic Material defaults.
class AppColors {
  AppColors._();

  // ── Primary Palette ──
  static const Color primary = Color(0xFF1A1A2E);
  static const Color primaryLight = Color(0xFF16213E);
  static const Color primaryDark = Color(0xFF0F0F1A);

  // ── Accent ──
  static const Color accent = Color(0xFFE8B931);
  static const Color accentLight = Color(0xFFF0D060);
  static const Color accentDark = Color(0xFFC49B1A);

  // ── Surface ──
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color card = Color(0xFFFFFFFF);

  // ── Dark Mode ──
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariantDark = Color(0xFF262626);
  static const Color cardDark = Color(0xFF1E1E1E);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF1A1A2E);

  // ── Text Dark ──
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFADB5BD);
  static const Color textTertiaryDark = Color(0xFF6C757D);

  // ── Semantic ──
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // ── Borders & Dividers ──
  static const Color border = Color(0xFFE9ECEF);
  static const Color borderDark = Color(0xFF333333);
  static const Color divider = Color(0xFFF1F3F5);
  static const Color dividerDark = Color(0xFF2A2A2A);

  // ── Misc ──
  static const Color shimmerBase = Color(0xFFE9ECEF);
  static const Color shimmerHighlight = Color(0xFFF8F9FA);
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);
  static const Color overlay = Color(0x80000000);
  static const Color rating = Color(0xFFFFB800);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8B931), Color(0xFFF0D060)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
  );
}
