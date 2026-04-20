import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = false;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = true;
  double _fontSize = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: AppColors.deepTeal,
        title: const Text(
          'Réglages',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Profile card
          _buildProfileCard(),
          const SizedBox(height: 24),

          // Notifications section
          _buildSectionLabel('Notifications & Confidentialité'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _buildSwitch(
              icon: Icons.notifications_active_rounded,
              iconColor: AppColors.persianGreen,
              title: 'Notifications',
              subtitle: 'Alertes de médicaments et rappels',
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            _buildDivider(),
            _buildSwitch(
              icon: Icons.location_on_rounded,
              iconColor: Colors.orange,
              title: 'Localisation',
              subtitle: 'Partager ma position avec les soignants',
              value: _locationEnabled,
              onChanged: (v) => setState(() => _locationEnabled = v),
            ),
          ]),
          const SizedBox(height: 20),

          // Accessibility section
          _buildSectionLabel('Accessibilité'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _buildSwitch(
              icon: Icons.dark_mode_rounded,
              iconColor: const Color(0xFF5B5EA6),
              title: 'Mode sombre',
              subtitle: 'Réduire la luminosité de l\'écran',
              value: _darkModeEnabled,
              onChanged: (v) => setState(() => _darkModeEnabled = v),
            ),
            _buildDivider(),
            _buildFontSizeTile(),
          ]),
          const SizedBox(height: 20),

          // Security section
          _buildSectionLabel('Sécurité'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _buildSwitch(
              icon: Icons.fingerprint_rounded,
              iconColor: AppColors.deepTeal,
              title: 'Biométrie',
              subtitle: 'Accès par empreinte ou Face ID',
              value: _biometricEnabled,
              onChanged: (v) => setState(() => _biometricEnabled = v),
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.lock_rounded,
              iconColor: Colors.red.shade400,
              title: 'Gérer les accès',
              subtitle: 'Permissions et sécurité avancée',
              onTap: () => _showComingSoon(),
            ),
          ]),
          const SizedBox(height: 20),

          // Account section
          _buildSectionLabel('Compte'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _buildNavTile(
              icon: Icons.person_rounded,
              iconColor: AppColors.persianGreen,
              title: 'Profil',
              subtitle: 'Gérer mes informations personnelles',
              onTap: () => _showComingSoon(),
            ),
            _buildDivider(),
            _buildNavTile(
              icon: Icons.info_outline_rounded,
              iconColor: Colors.blueGrey,
              title: 'À propos',
              subtitle: 'Version 1.0.0 · MedAssist',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'MedAssist',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 HexIdeate. Tous droits réservés.',
              ),
            ),
          ]),
          const SizedBox(height: 28),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(),
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepTeal,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepTeal.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.persianGreen,
            child: const Text(
              'H',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hmida',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Patient · MedAssist',
                  style: TextStyle(
                    color: Color(0xFFB2DFDB),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showComingSoon(),
            icon: const Icon(Icons.edit_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitch({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconBox(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.persianGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildIconBox(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBox(Icons.text_fields_rounded, Colors.teal),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Taille du texte',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('${_fontSize.round()} pt',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          Slider(
            value: _fontSize,
            min: 12,
            max: 24,
            divisions: 6,
            activeColor: AppColors.persianGreen,
            onChanged: (v) => setState(() => _fontSize = v),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: Colors.grey.shade100,
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fonctionnalité à venir'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showComingSoon();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnecter',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}