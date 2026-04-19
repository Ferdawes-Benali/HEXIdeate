import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BigMedCard extends StatelessWidget {
  final String icon; // emoji icon
  final Color iconBg;
  final Color cardBg;
  final Color borderColor;
  final Color labelColor;
  final String label;
  final String title;
  final String subtitle;
  final List<Pill> pills;
  final VoidCallback? onTap;

  const BigMedCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.cardBg,
    required this.borderColor,
    required this.labelColor,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.pills,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 2.5),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône dans un cercle
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 12),
            // Label catégorie
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: labelColor,
                letterSpacing: 0.08,
              ),
            ),
            const SizedBox(height: 4),
            // Titre XXL (senior-friendly)
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            // Pills d'état
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: pills.map((p) => _buildPill(p)).toList(),
            ),
            const SizedBox(height: 8),
            // Sous-titre
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(Pill p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: p.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        p.text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: p.fg,
        ),
      ),
    );
  }
}

class Pill {
  final String text;
  final Color bg;
  final Color fg;
  const Pill(this.text, this.bg, this.fg);
}

// Factory helpers pour créer des pills facilement
Pill pillDone(String text) =>
    Pill(text, AppColors.sandyYellow, AppColors.deepTeal);
Pill pillTime(String text) =>
    Pill(text, AppColors.persianGreen, AppColors.white);
Pill pillSoon(String text) =>
    Pill(text, AppColors.sandyBrown, AppColors.white);
Pill pillBlue(String text) =>
    Pill(text, AppColors.deepTeal, AppColors.sandyYellow);
