import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/timeline_item.dart';

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.caregiverTheme,
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AUJOURD'HUI — CHRONOLOGIE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepTeal,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const TimelineItem(
                      time: '08:00',
                      title: 'Paracétamol 500mg',
                      detail: 'Pris à 08:07 · Confirmé',
                      status: TimelineStatus.done,
                    ),
                    const TimelineItem(
                      time: '08:00',
                      title: 'Metformine 850mg',
                      detail: ' Pris à 08:05 · Confirmé',
                      status: TimelineStatus.done,
                    ),
                    const TimelineItem(
                      time: '12:00',
                      title: 'Mesure de tension',
                      detail: 'À faire · Rappel envoyé',
                      status: TimelineStatus.pending,
                    ),
                    const TimelineItem(
                      time: '14:00',
                      title: 'Consultation Dr. Karim',
                      detail: 'Rappel à envoyer — 2h avant',
                      status: TimelineStatus.urgent,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: AppColors.persianGreen,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Ajouter un médicament',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.deepTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 22),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.sandyYellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.persianGreen, width: 2.5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'H',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepTeal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suivi de Hmida',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Dernière mise à jour : 08:12',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFA7F3D0),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.persianGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Actif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats rapides
          Row(
            children: [
              _statChip('3/4', 'Méds. pris'),
              const SizedBox(width: 8),
              _statChip('118/75', 'Tension'),
              const SizedBox(width: 8),
              _statChip('1', 'Alerte'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.sandyYellow,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFA7F3D0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: AppColors.deepTeal,
      selectedItemColor: AppColors.sandyYellow,
      unselectedItemColor: const Color(0xFFA7F3D0),
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 10,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.people_rounded),
          label: 'Patients',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Rapports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_rounded),
          label: 'Alertes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Réglages',
        ),
      ],
    );
  }
}
