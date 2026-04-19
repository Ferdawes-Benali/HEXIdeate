import 'package:flutter/material.dart';

class AppColors {
  // ── Palette principale choisie pour la présentation ──────────────────────
  // Ces couleurs ont été sélectionnées scientifiquement pour ce sujet :
  // #264653 = Bleu-vert profond (Charcoal Teal) → confiance, calme, médical
  // #2A9D8F = Vert d'eau (Persian Green) → santé, apaisement, nature
  // #E9C46A = Or sableux (Sandy Yellow) → chaleur, soleil, bonne humeur
  // #F4A261 = Orange doux (Sandy Brown) → énergie douce, convivialité
  // #E76F51 = Corail (Burnt Sienna) → urgence visible, sans agression
  static const Color deepTeal = Color(0xFF264653);
  static const Color persianGreen = Color(0xFF2A9D8F);
  static const Color sandyYellow = Color(0xFFE9C46A);
  static const Color sandyBrown = Color(0xFFF4A261);
  static const Color burntSienna = Color(0xFFE76F51);

  // ── Couleurs dérivées pour l'UI ───────────────────────────────────────────
  static const Color background = Color(
    0xFFFDF8F2,
  ); // Fond crème — pas d'éblouissement
  static const Color cardGreen = Color(0xFFE8FDF5);
  static const Color cardBlue = Color(0xFFE8F4FD);
  static const Color cardBorder = Color(0xFFD0E4E0);
  static const Color textPrimary = Color(0xFF1A3A40);
  static const Color textSecondary = Color(0xFF6B8A8E);
  static const Color success = Color(0xFF2A9D8F);
  static const Color warning = Color(0xFFE9C46A);
  static const Color danger = Color(0xFFE76F51);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get elderlyTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.persianGreen,
      primary: AppColors.persianGreen,
      secondary: AppColors.sandyYellow,
      error: AppColors.burntSienna,
      surface: AppColors.background,
    ),
    textTheme: const TextTheme(
      // Tailles XXL pour les seniors
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: AppColors.white,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
      ),
    ),
  );

  static ThemeData get caregiverTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF4F7F6),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.deepTeal,
      primary: AppColors.deepTeal,
      secondary: AppColors.persianGreen,
      surface: const Color(0xFFF4F7F6),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: AppColors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    ),
  );
}
