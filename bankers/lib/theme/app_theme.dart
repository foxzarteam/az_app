import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global theme — single source for all colors and common styles across the app.
/// Use only AppTheme for colors; do not use Color(AppConstants.*) or hardcoded hex in UI.
class AppTheme {
  AppTheme._();

  // ─── Primary (brand, headers, links) ─────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2320E7);
  static const Color primaryBlueDark = Color(0xFF1A1BC7);
  static const Color darkBlue = primaryBlue;
  static const Color primaryHover = Color(0xFF3D3AFF);

  // ─── Accent (CTA, highlights, badges) ─────────────────────────────────────
  static const Color accentOrange = Color(0xFFF24C00);
  static const Color accentOrangeHover = Color(0xFFF26B20);
  static const Color yellow = Color(0xFFFFD700);

  // ─── Backgrounds ─────────────────────────────────────────────────────────
  static const Color mainBackground = Color(0xFFF0F5FA);
  static const Color secondaryBackground = Color(0xFFF0F5FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // ─── Text ────────────────────────────────────────────────────────────────
  static const Color primaryText = Color(0xFF3C3C3C);
  static const Color secondaryText = Color(0xFF666666);
  static const Color lightText = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);

  // ─── Borders & dividers ──────────────────────────────────────────────────
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFF0F5FA);

  // ─── Semantic (status, feedback) ─────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ─── Lead status (list chips / cards) ─────────────────────────────────────
  static const Color statusSuccessBg = Color(0xFFE1F8EE);
  static const Color statusPendingBg = Color(0xFFE0ECFF);
  static const Color statusRejectedBg = Color(0xFFFEE2E2);
  static const Color statusActionRequiredBg = Color(0xFFFFF7E6);
  static const Color statusOtherBg = Color(0xFFE5E7EB);
  static const Color statusPendingFg = Color(0xFF2563EB);

  // ─── Social / share icons ─────────────────────────────────────────────────
  static const Color socialWhatsApp = Color(0xFF25D366);
  static const Color socialInstagram = Color(0xFFE4405F);
  static const Color socialMail = Color(0xFF2563EB);

  // ─── Overlays ─────────────────────────────────────────────────────────────
  static Color overlayDark(double opacity) => Colors.black.withOpacity(opacity);

  // ─── Gradients ───────────────────────────────────────────────────────────
  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryBlueDark, primaryBlue],
      );

  /// Gradient orange: #F24C00
  static LinearGradient get orangeGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF24C00), Color(0xFFF26B20)],
      );

  // ─── Typography ──────────────────────────────────────────────────────────
  static TextStyle inter({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
