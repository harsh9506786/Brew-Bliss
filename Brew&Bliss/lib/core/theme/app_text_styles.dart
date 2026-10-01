import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

// Font family used across the whole app. Plus Jakarta Sans is the closest
// free/Google Fonts match to the bold, rounded, modern sans-serif look used
// by quick-commerce apps like Blinkit (their real font, "Okra", is a
// proprietary in-house font and isn't publicly licensable).
class AppTextStyles {
  // Logo
  static final logo = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.darkBrown,
  );

  // Main heading
  static final heading = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  // Section heading
  static final sectionTitle = GoogleFonts.plusJakartaSans(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Normal text
  static final body = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static final bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Decorative banner text - Playfair Display italic: an elegant editorial
  // serif that pairs nicely with the bold sans-serif used for headings.
  static final decorative = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.15,
    color: Colors.white,
    shadows: const [
      Shadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  // Price
  static final price = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.darkBrown,
  );

  // Button
  static final button = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // Bottom navigation
  static final navLabel = GoogleFonts.plusJakartaSans(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static final navLabelSelected = GoogleFonts.plusJakartaSans(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}
