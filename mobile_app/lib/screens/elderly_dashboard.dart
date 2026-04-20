import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/greeting_header.dart';
import '../widgets/big_med_card.dart';
import '../widgets/emergency_fab.dart';
import 'medications_screen.dart';
import 'messages_screen.dart';
import 'settings_screen.dart';

class ElderlyDashboard extends StatefulWidget {
  const ElderlyDashboard({super.key});

  @override
  State<ElderlyDashboard> createState() => _ElderlyDashboardState();
}

class _ElderlyDashboardState extends State<ElderlyDashboard> {
  int _selectedIndex = 0;
  final int _patientId = 1;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.elderlyTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return MedicationsScreen(patientId: _patientId);
      case 2:
        return MessagesScreen(patientId: _patientId);
      case 3:
        return const SettingsScreen();
      default:
        return const Center(child: Text('Écran non trouvé'));
    }
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        GreetingHeader(name: 'Hmida', initials: 'H'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & day label
                _buildDateHeader(),
                const SizedBox(height: 20),

                // Quick stats row
                _buildQuickStats(),
                const SizedBox(height: 24),

                // Section title
                _buildSectionTitle("Aujourd'hui"),
                const SizedBox(height: 12),

                // Medication card
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
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                const SizedBox(height: 12),

                // Doctor card
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

                // Section title
                _buildSectionTitle('Accès rapide'),
                const SizedBox(height: 12),

                // Quick action grid
                _buildQuickActions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        EmergencyFab(onPressed: _showEmergencyDialog),
      ],
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final weekdays = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    final dayName = weekdays[now.weekday - 1];
    final monthName = months[now.month - 1];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.persianGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${now.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$monthName ${now.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildHealthBadge(),
        ],
      ),
    );
  }

  Widget _buildHealthBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.persianGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: const [
          Icon(Icons.favorite_rounded, color: AppColors.persianGreen, size: 14),
          SizedBox(width: 4),
          Text(
            'Bon état',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.persianGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.medication_rounded,
            iconColor: AppColors.persianGreen,
            bgColor: AppColors.cardGreen,
            value: '2/3',
            label: 'Médicaments pris',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.deepTeal,
            bgColor: AppColors.cardBlue,
            value: '1',
            label: 'RDV aujourd\'hui',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.chat_bubble_rounded,
            iconColor: const Color(0xFF7B5EA7),
            bgColor: const Color(0xFFF0EBF8),
            value: '3',
            label: 'Nouveaux messages',
            onTap: () => setState(() => _selectedIndex = 2),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [
        _buildActionTile(
          icon: Icons.medication_rounded,
          label: 'Médicaments',
          color: AppColors.persianGreen,
          onTap: () => setState(() => _selectedIndex = 1),
        ),
        _buildActionTile(
          icon: Icons.chat_bubble_rounded,
          label: 'Messages',
          color: const Color(0xFF7B5EA7),
          onTap: () => setState(() => _selectedIndex = 2),
        ),
        _buildActionTile(
          icon: Icons.local_hospital_rounded,
          label: 'Urgences',
          color: Colors.red.shade400,
          onTap: _showEmergencyDialog,
        ),
        _buildActionTile(
          icon: Icons.settings_rounded,
          label: 'Réglages',
          color: AppColors.deepTeal,
          onTap: () => setState(() => _selectedIndex = 3),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300, size: 18),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.red.withOpacity(0.3),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_rounded,
                  color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Appel d\'urgence',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Voulez-vous appeler les services d\'urgence (15) ?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: launch phone dialer with emergency number
            },
            icon: const Icon(Icons.phone_rounded, size: 18),
            label: const Text('Appeler le 15'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
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
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
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