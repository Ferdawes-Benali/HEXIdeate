import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TimelineStatus { done, pending, urgent }

class TimelineItem extends StatelessWidget {
  final String time;
  final String title;
  final String detail;
  final TimelineStatus status;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.time,
    required this.title,
    required this.detail,
    required this.status,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne timeline (dot + ligne)
          SizedBox(
            width: 42,
            child: Column(
              children: [
                _buildDot(),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.cardBorder,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Carte contenu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.persianGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTag(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    final (emoji, bg, border) = switch (status) {
      TimelineStatus.done => ('✅', AppColors.cardGreen, AppColors.persianGreen),
      TimelineStatus.pending => (
        '⏳',
        const Color(0xFFFFF8E7),
        AppColors.sandyYellow,
      ),
      TimelineStatus.urgent => (
        '⚠️',
        const Color(0xFFFEF0EC),
        AppColors.burntSienna,
      ),
    };
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildTag() {
    final (text, bg, fg) = switch (status) {
      TimelineStatus.done => ('Fait', AppColors.persianGreen, AppColors.white),
      TimelineStatus.pending => (
        'En attente',
        AppColors.sandyYellow,
        AppColors.deepTeal,
      ),
      TimelineStatus.urgent => (
        'Action requise',
        AppColors.burntSienna,
        AppColors.white,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
