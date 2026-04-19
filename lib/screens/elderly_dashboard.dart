import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/greeting_header.dart';
import '../widgets/big_med_card.dart';
import '../widgets/emergency_fab.dart';

class ElderlyDashboard extends StatelessWidget {
  const ElderlyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.elderlyTheme,
      child: Scaffold(
        body: Column(
          children: [
            // En-tête avec avatar et salutation
            GreetingHeader(name: 'Hmida', initials: 'H'),
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Aujourd'hui",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Carte médicaments
                    BigMedCard(
                      icon: '💊',
                      iconBg: AppColors.persianGreen,
                      cardBg: AppColors.cardGreen,
                      borderColor: AppColors.persianGreen,
                      labelColor: const Color(0xFF1A7A6E),
                      label: 'Médicaments',
                      title: 'Médicaments du Matin',
                      subtitle: 'Paracétamol · Metformine',
                      pills: [pillDone('✅ Pris'), pillTime('08:00')],
                      onTap: () {},
                    ),
                    const SizedBox(height: 14),
                    // Carte médecin
                    BigMedCard(
                      icon: '🩺',
                      iconBg: AppColors.deepTeal,
                      cardBg: AppColors.cardBlue,
                      borderColor: AppColors.deepTeal,
                      labelColor: AppColors.deepTeal,
                      label: 'Mon Médecin',
                      title: 'Dr. Karim — 14h00',
                      subtitle: 'Consultation cardiologie',
                      pills: [pillSoon('⏳ Bientôt'), pillBlue('14:00')],
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bouton d'urgence géant
            EmergencyFab(onPressed: () {}),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.deepTeal,
      selectedItemColor: AppColors.sandyYellow,
      unselectedItemColor: const Color(0xFFA7F3D0),
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication_rounded),
          label: 'Médicaments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_rounded),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Réglages',
        ),
      ],
    );
  }
}
