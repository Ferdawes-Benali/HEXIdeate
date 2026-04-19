import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class EmergencyFab extends StatelessWidget {
  final VoidCallback onPressed;

  const EmergencyFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: 72, // Très grand — accessible aux seniors
        child: ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.heavyImpact(); // Retour haptique fort
            onPressed();
          },
          icon: const Text('📞', style: TextStyle(fontSize: 30)),
          label: const Text(
            'Appeler l\'aide',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.burntSienna,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
            ),
            elevation: 8,
            shadowColor: AppColors.burntSienna.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
