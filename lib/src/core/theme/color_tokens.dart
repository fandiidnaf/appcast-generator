import 'package:flutter/material.dart';

/// Design tokens derived from DESIGN.md.
/// Precision engineering aesthetic: Deep Obsidian, Slate, and Warm Bronze/Amber.
class AppColors {
  AppColors._();

  // ─── Neutral Surfaces (Dark) ────────────────────────────────────────────────
  static const darkCanvas = Color(0xFF0B0F17); // Base background
  static const darkSurface1 = Color(0xFF141C2B); // Cards & panels
  static const darkSurface2 = Color(0xFF1B2538); // Inputs & insets
  static const darkBorder = Color(0xFF28354D); // Structural border
  static const darkBorderSubtle = Color(0xFF1E2A3E);

  // ─── Neutral Surfaces (Light) ───────────────────────────────────────────────
  static const lightCanvas = Color(0xFFF8FAFC); // Slate 50
  static const lightSurface1 = Color(0xFFFFFFFF); // White cards
  static const lightSurface2 = Color(0xFFF1F5F9); // Slate 100 inputs
  static const lightBorder = Color(0xFFCBD5E1); // Slate 300
  static const lightBorderSubtle = Color(0xFFE2E8F0);

  // ─── Text Colors ────────────────────────────────────────────────────────────
  static const darkTextPrimary = Color(0xFFF8FAFC); // Slate 50 (~16:1)
  static const darkTextSecondary = Color(0xFF94A3B8); // Slate 400 (~7:1)
  static const darkTextMuted = Color(0xFF64748B); // Slate 500 (~4.5:1)

  static const lightTextPrimary = Color(0xFF0F172A); // Slate 900 (~15:1)
  static const lightTextSecondary = Color(0xFF475569); // Slate 600 (~7.2:1)
  static const lightTextMuted = Color(0xFF64748B); // Slate 500 (~4.6:1)

  // ─── Brand Accent: Warm Bronze / Amber ──────────────────────────────────────
  // Dark mode: vibrant amber that pops on dark obsidian
  static const darkAccent = Color(0xFFF59E0B);
  static const darkAccentMuted = Color(0xFF78350F);
  static const darkAccentBg = Color(0x26F59E0B); // 15% opacity

  // Light mode: rich bronze/amber that maintains WCAG AA contrast against white/slate-50
  static const lightAccent = Color(0xFFB45309);
  static const lightAccentMuted = Color(0xFFD97706);
  static const lightAccentBg = Color(0xFFFEF3C7);

  // ─── Semantic Accents ───────────────────────────────────────────────────────
  static const darkSuccess = Color(0xFF10B981);
  static const lightSuccess = Color(0xFF047857);

  static const darkWarning = Color(0xFFF59E0B);
  static const lightWarning = Color(0xFFB45309);

  static const darkDanger = Color(0xFFEF4444);
  static const lightDanger = Color(0xFFB91C1C);

  static const darkInfo = Color(0xFF38BDF8);
  static const lightInfo = Color(0xFF0369A1);

  // ─── XML Syntax Highlighting (Monospace Inspector) ──────────────────────────
  // Dark Theme Code Colors
  static const darkXmlTag = Color(0xFF60A5FA); // Sky blue
  static const darkXmlAttr = Color(0xFFFCD34D); // Soft amber
  static const darkXmlValue = Color(0xFF34D399); // Soft emerald
  static const darkXmlComment = Color(0xFF64748B); // Slate
  static const darkXmlBracket = Color(0xFF94A3B8);
  static const darkXmlPi = Color(0xFFA78BFA); // Purple

  // Light Theme Code Colors
  static const lightXmlTag = Color(0xFF0369A1);
  static const lightXmlAttr = Color(0xFFB45309);
  static const lightXmlValue = Color(0xFF047857);
  static const lightXmlComment = Color(0xFF64748B);
  static const lightXmlBracket = Color(0xFF334155);
  static const lightXmlPi = Color(0xFF7C3AED);
}
