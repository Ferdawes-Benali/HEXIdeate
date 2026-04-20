import 'package:flutter/material.dart';
import 'package:hexideate/theme/app_theme.dart';

class MedicationReminderDialog extends StatelessWidget {
  final String medicationName;
  final String? dosage;
  final String timeOfDay;
  final int patientId;
  final VoidCallback? onTaken;
  final VoidCallback? onSkipped;

  const MedicationReminderDialog({
    Key? key,
    required this.medicationName,
    this.dosage,
    required this.timeOfDay,
    required this.patientId,
    this.onTaken,
    this.onSkipped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.cardGreen,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.medication,
                size: 48,
                color: AppColors.persianGreen,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Rappel de médicament',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Medication name
            Text(
              medicationName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.persianGreen,
              ),
            ),
            const SizedBox(height: 8),

            // Dosage and time
            if (dosage != null)
              Text(
                '$dosage • $timeOfDay',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              )
            else
              Text(
                timeOfDay,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 24),

            // Message
            Text(
              'Il est temps de prendre votre médicament.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onSkipped?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Plus tard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onTaken?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.persianGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Pris ✓',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Show medication reminder dialog
void showMedicationReminder({
  required BuildContext context,
  required String medicationName,
  String? dosage,
  required String timeOfDay,
  required int patientId,
  VoidCallback? onTaken,
  VoidCallback? onSkipped,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => MedicationReminderDialog(
      medicationName: medicationName,
      dosage: dosage,
      timeOfDay: timeOfDay,
      patientId: patientId,
      onTaken: onTaken,
      onSkipped: onSkipped,
    ),
  );
}
