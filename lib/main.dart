import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/elderly_dashboard.dart';
import 'screens/caregiver_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF264653),
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MedAssistApp());
}

class MedAssistApp extends StatefulWidget {
  const MedAssistApp({super.key});
  @override
  State<MedAssistApp> createState() => _MedAssistAppState();
}

class _MedAssistAppState extends State<MedAssistApp> {
  bool _isElderlyMode = true; // Bascule entre les deux modes

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedAssist',
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          _isElderlyMode
              ? const ElderlyDashboard()
              : const CaregiverDashboard(),
          // Bouton de bascule pour la démo
          Positioned(
            top: 48,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'mode-toggle',
              backgroundColor: const Color(0xFFE9C46A),
              onPressed: () => setState(() => _isElderlyMode = !_isElderlyMode),
              tooltip: 'Changer de mode',
              child: Icon(
                _isElderlyMode ? Icons.medical_services : Icons.elderly,
                color: const Color(0xFF264653),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
