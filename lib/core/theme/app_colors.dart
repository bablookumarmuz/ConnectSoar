import 'package:flutter/material.dart';

/// Premium SaaS Color Palette for ConnectSoar (Linear / Vercel inspired)
abstract class AppColors {
  // --- Primary Indigo Brand Colors ---
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryHover = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryContainer = Color(0xFFEEF2FF); // Indigo 50
  static const Color primaryContainerDark = Color(0xFF1E1B4B); // Indigo 950

  // --- Dark Mode Surface & Background Tokens ---
  static const Color darkBackground = Color(0xFF090A0F); // Deep Obsidian
  static const Color darkSurface = Color(0xFF11131A); // Card Surface
  static const Color darkSurfaceElevated = Color(
    0xFF181B26,
  ); // Hover/Elevated Card
  static const Color darkBorder = Color(0xFF242838); // Crisp Subtle Border
  static const Color darkBorderFocus = Color(0xFF6366F1);

  // --- Light Mode Surface & Background Tokens ---
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightBorderFocus = Color(0xFF4F46E5);

  // --- Neutral Text Colors (Dark Mode) ---
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate 500

  // --- Neutral Text Colors (Light Mode) ---
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted = Color(0xFF94A3B8); // Slate 400

  // --- Status & Semantic Colors ---
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successContainer = Color(0xFFECFDF5);
  static const Color successContainerDark = Color(0xFF064E3B);

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningContainer = Color(0xFFFFFBEB);
  static const Color warningContainerDark = Color(0xFF78350F);

  static const Color danger = Color(0xFFEF4444); // Rose 500
  static const Color dangerContainer = Color(0xFFFEF2F2);
  static const Color dangerContainerDark = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF06B6D4); // Cyan 500
  static const Color infoContainer = Color(0xFFECFEFF);
  static const Color infoContainerDark = Color(0xFF164E63);

  // --- Role Badge Colors ---
  static const Color roleAdmin = Color(0xFFA855F7); // Purple
  static const Color roleManager = Color(0xFF3B82F6); // Blue
  static const Color roleEmployee = Color(0xFF10B981); // Emerald

  // --- Meeting Status Indicators ---
  static const Color liveIndicator = Color(0xFFEF4444); // Pulse red for Live
  static const Color scheduledIndicator = Color(0xFF3B82F6); // Blue
  static const Color endedIndicator = Color(0xFF64748B); // Slate
}
