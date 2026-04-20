import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BigMedCard extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final Color cardBg;
  final Color borderColor;
  final Color labelColor;
  final String label;
  final String title;
  final String subtitle;
  final List<Widget> pills;
  final VoidCallback onTap;

  /// Optional progress between 0.0 and 1.0 (shown as a thin bar under subtitle)
  final double? progress;

  /// Optional right-side meta text shown next to progress (e.g. "1 pris sur 3")
  final String? progressLabel;

  /// Optional time label shown on the right of the progress row (e.g. "08:00")
  final String? timeLabel;

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
    required this.onTap,
    this.progress,
    this.progressLabel,
    this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor.withOpacity(0.55), width: 1.5),
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: iconBg.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label badge
                  _buildBadge(),
                  const SizedBox(height: 10),

                  // Icon + title + progress row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon box
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(icon, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title + subtitle + progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary.withOpacity(0.55),
                              ),
                            ),
                            if (progress != null) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 5,
                                  backgroundColor:
                                      iconBg.withOpacity(0.2),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(iconBg),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (progressLabel != null)
                                    Text(
                                      progressLabel!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: labelColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (timeLabel != null)
                                    Text(
                                      timeLabel!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: labelColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Arrow button
                      const SizedBox(width: 8),
                      _buildArrow(),
                    ],
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      height: 1,
                      color: borderColor.withOpacity(0.25),
                    ),
                  ),

                  // Pills row
                  Wrap(spacing: 8, runSpacing: 6, children: pills),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: iconBg.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: iconBg,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

// ── Pill helpers ─────────────────────────────────────────────────────────────

Widget pillDone(String label) => _Pill(
      label: label,
      bg: const Color(0xFFC0EBE3),
      fg: const Color(0xFF0F6E56),
    );

Widget pillTime(String label) => _Pill(
      label: label,
      bg: const Color(0xFF085041),
      fg: const Color(0xFF9FE1CB),
    );

Widget pillSoon(String label) => _Pill(
      label: label,
      bg: const Color(0xFFFAC775),
      fg: const Color(0xFF633806),
    );

Widget pillBlue(String label) => _Pill(
      label: label,
      bg: const Color(0xFF185FA5),
      fg: const Color(0xFFB5D4F4),
    );

class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Pill({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}