import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'screens/elderly_dashboard.dart';
import 'services/medication_alarm_service.dart';
import 'package:hexideate/services/local_database_service.dart';
import 'package:hive_flutter/hive_flutter.dart';


final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // One-time cleanup of corrupt data
  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('medications');
  await Hive.deleteBoxFromDisk('patients');
  await Hive.deleteBoxFromDisk('intake_history');

  // NOW initialize — this opens fresh empty boxes
  try {
    await LocalDatabaseService().init();
    print('✅✅✅ Database initialized OK');
  } catch (e, stack) {
    print('❌❌❌ Database init FAILED: $e');
    print('❌❌❌ Stack: $stack');
  }

  final alarmService = MedicationAlarmService();
  await alarmService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF264653),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: MedAssistApp()));
}
class MedAssistApp extends StatefulWidget {
  const MedAssistApp({super.key});

  @override
  State<MedAssistApp> createState() => _MedAssistAppState();
}

class _MedAssistAppState extends State<MedAssistApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedAssist',
      debugShowCheckedModeBanner: false,
      home: const ElderlyDashboard(),
    );
  }
}