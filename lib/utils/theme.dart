// lib/utils/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme: Slate + Emerald
/// Profesional, clean, konsisten. Light mode proper.
/// Inspirasi: Linear, Vercel, Raycast.
class AppTheme {
  // ── Primary — slate blue ───────────────────────────────────────────────────
  static const primary = Color(0xFF2563EB); // electric blue
  static const primaryHover = Color(0xFF1D4ED8);
  static const primaryBg = Color(0xFFEFF6FF); // blue-50
  static const primaryBorder = Color(0xFFBFDBFE); // blue-200

  // ── Accent — emerald ───────────────────────────────────────────────────────
  static const accent = Color(0xFF10B981); // emerald-500
  static const accentBg = Color(0xFFECFDF5); // emerald-50
  static const accentBorder = Color(0xFFA7F3D0); // emerald-200

  // ── Surfaces — cool white hierarchy ───────────────────────────────────────
  static const bg = Color(0xFFF8FAFC); // slate-50
  static const surface = Color(0xFFFFFFFF); // white cards
  static const surfaceInset = Color(0xFFF1F5F9); // slate-100 inputs
  static const surfaceHover = Color(0xFFE2E8F0); // slate-200 hover

  // ── Borders ────────────────────────────────────────────────────────────────
  static const border = Color(0xFFE2E8F0); // slate-200
  static const borderStrong = Color(0xFFCBD5E1); // slate-300

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0F172A); // slate-900
  static const textSecondary = Color(0xFF475569); // slate-600
  static const textMuted = Color(0xFF94A3B8); // slate-400
  static const textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const success = Color(0xFF059669); // emerald-600
  static const successBg = Color(0xFFECFDF5);
  static const successBorder = Color(0xFFA7F3D0);

  static const warning = Color(0xFFD97706); // amber-600
  static const warningBg = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);

  static const danger = Color(0xFFDC2626); // red-600
  static const dangerBg = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);

  static const info = Color(0xFF0284C7); // sky-600
  static const infoBg = Color(0xFFF0F9FF);
  static const infoBorder = Color(0xFFBAE6FD);

  // ── Tags ───────────────────────────────────────────────────────────────────
  static const tagBg = Color(0xFFEFF6FF);
  static const tagText = Color(0xFF1D4ED8); // blue-700

  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: accent,
        onSecondary: textOnPrimary,
        surface: surface,
        onSurface: textPrimary,
        error: danger,
        onError: Colors.white,
        outline: border,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
        labelMedium: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceInset,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        labelStyle: GoogleFonts.inter(fontSize: 13, color: textSecondary),
        hintStyle: GoogleFonts.inter(fontSize: 13, color: textMuted),
        isDense: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          textStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textSecondary,
          backgroundColor: surface,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          textStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tagBg,
        labelStyle: GoogleFonts.inter(
            fontSize: 11.5, color: tagText, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: primaryBorder),
        ),
      ),
      dividerTheme:
          const DividerThemeData(color: border, thickness: 1, space: 0),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((_) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? primary
                : const Color(0xFFCBD5E1)),
        trackOutlineColor:
            WidgetStateProperty.resolveWith((_) => Colors.transparent),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        elevation: 8,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        textStyle: GoogleFonts.inter(fontSize: 11.5, color: Colors.white),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border),
        ),
        elevation: 4,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textMuted,
        indicatorColor: primary,
        dividerColor: border,
        labelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
      ),
    );
  }

  // ── Syntax colors (JetBrains-inspired, light bg) ───────────────────────────
  static const syntaxTag = Color(0xFF0550AE); // blue — tag names
  static const syntaxAttr = Color(0xFF953800); // orange-brown — attr keys
  static const syntaxValue = Color(0xFF116329); // green — string values
  static const syntaxComment = Color(0xFF57606A); // gray — comments
  static const syntaxPi = Color(0xFF8250DF); // purple — processing instr.
  static const syntaxBracket = Color(0xFF24292F); // near-black — < > brackets

  static TextStyle get monoStyle => GoogleFonts.jetBrainsMono(
        fontSize: 12.5,
        height: 1.65,
        color: textPrimary,
        letterSpacing: -0.2,
      );
}

class AppSizes {
  static const headerHeight = 52.0;
  static const maxContentWidth = 1200.0;
}
