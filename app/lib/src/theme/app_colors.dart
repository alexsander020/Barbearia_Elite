import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════
//  BARBERFLOW ELITE — DESIGN TOKENS
//  Todas as cores, tipografia e espaçamentos do sistema
//  Baseados no mock "Dark Gold" do protótipo HTML
// ══════════════════════════════════════════════════════════

abstract class AppColors {
  // ── Brand Gold ──
  static const Color primary        = Color(0xFFF2CA50);
  static const Color primaryDim     = Color(0xFFE9C349);
  static const Color primaryFixed   = Color(0xFFFFE088);
  static const Color primaryContainer = Color(0xFFD4AF37);
  static const Color onPrimary      = Color(0xFF3C2F00);
  static const Color onPrimaryContainer = Color(0xFF554300);

  // ── Surfaces ──
  static const Color background          = Color(0xFF131313);
  static const Color surface             = Color(0xFF131313);
  static const Color surfaceContainerLowest  = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow     = Color(0xFF1C1B1B);
  static const Color surfaceContainer        = Color(0xFF201F1F);
  static const Color surfaceContainerHigh    = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color surfaceVariant          = Color(0xFF353534);
  static const Color surfaceBright           = Color(0xFF393939);

  // ── Text / On-Surface ──
  static const Color onSurface        = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFD0C5AF);
  static const Color outline          = Color(0xFF99907C);
  static const Color outlineVariant   = Color(0xFF4D4635);

  // ── Error ──
  static const Color error          = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError        = Color(0xFF690005);

  // ── Secondary (Red accent) ──
  static const Color secondary          = Color(0xFFFFB3AD);
  static const Color secondaryContainer = Color(0xFF7A322F);
  static const Color onSecondary        = Color(0xFF5A1A19);
}

// ══════════════════════════════════════════════════════════
//  SPACING
// ══════════════════════════════════════════════════════════

abstract class AppSpacing {
  static const double xs             = 4.0;
  static const double base           = 8.0;
  static const double sm             = 12.0;
  static const double md             = 24.0;
  static const double lg             = 40.0;
  static const double xl             = 64.0;
  static const double gutter         = 24.0;
  static const double marginMobile   = 16.0;
  static const double marginDesktop  = 48.0;
}

// ══════════════════════════════════════════════════════════
//  BORDER RADIUS
// ══════════════════════════════════════════════════════════

abstract class AppRadius {
  static const double small  = 4.0;
  static const double medium = 8.0;
  static const double large  = 12.0;
  static const double full   = 9999.0;

  static BorderRadius card     = BorderRadius.circular(large);
  static BorderRadius button   = BorderRadius.circular(large);
  static BorderRadius chip     = BorderRadius.circular(full);
  static BorderRadius input    = BorderRadius.circular(medium);
}

// ══════════════════════════════════════════════════════════
//  TEXT STYLES
//  Playfair Display → Headings
//  Inter           → Body / Labels
// ══════════════════════════════════════════════════════════

abstract class AppTextStyles {
  static const String _playfair = 'Playfair Display';
  static const String _inter    = 'Inter';

  static const TextStyle headlineXl = TextStyle(
    fontFamily: _playfair,
    fontSize: 48,
    height: 56 / 48,
    letterSpacing: -0.02 * 48,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: _playfair,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: _playfair,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: _inter,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.05 * 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );
}
