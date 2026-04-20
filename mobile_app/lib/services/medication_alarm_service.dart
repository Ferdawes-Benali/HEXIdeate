import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

final logger = Logger();

class MedicationAlarmService {
  static final MedicationAlarmService _instance = MedicationAlarmService._internal();
  static const String _boxName = 'medication_alarms';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late Box<Map> _alarmBox;
  bool _isInitialized = false;

  MedicationAlarmService._internal();

  factory MedicationAlarmService() => _instance;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz_data.initializeTimeZones();

      // Open the alarm box (Hive should already be initialized by LocalDatabaseService)
      _alarmBox = await Hive.openBox<Map>(_boxName);

      // Android initialization settings
      final androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final iosSettings =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          logger.i('Notification clicked: ${details.payload}');
        },
      );

      // Create a Notification Channel (Required for Android 8.0+)
      final channel = AndroidNotificationChannel(
        'medication_reminders_channel',
        'Rappels de Médicaments',
        description: 'Canal pour les alertes de santé de HexIdeate',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      _isInitialized = true;
      logger.i('Medication alarm service fully initialized');
    } catch (e) {
      logger.e('Error initializing alarm service: $e');
      rethrow;
    }
  }

  Future<void> scheduleMedicationAlarm({
    required String medicationName,
    required String time,
    required List<int> daysOfWeek,
    required int patientId,
    String? dosage,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final alarmKey = '${patientId}_${medicationName}_$time';
      final timeparts = time.split(':');
      final hour = int.parse(timeparts[0]);
      final minute = int.parse(timeparts[1]);

      await _alarmBox.put(alarmKey, {
        'medication': medicationName,
        'time': time,
        'days': daysOfWeek,
        'patient_id': patientId,
        'dosage': dosage,
        'active': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      for (int dayOfWeek in daysOfWeek) {
        final notificationId = _generateNotificationId(alarmKey, dayOfWeek);
        await _scheduleWeeklyNotification(
          id: notificationId,
          medicationName: medicationName,
          dosage: dosage,
          dayOfWeek: dayOfWeek,
          hour: hour,
          minute: minute,
        );
      }
      logger.i('Scheduled: $medicationName at $time');
    } catch (e) {
      logger.e('Error scheduling alarm: $e');
    }
  }

  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String medicationName,
    required String? dosage,
    required int dayOfWeek,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    // Fix 3: Use AndroidScheduleMode.exactAllowWhileIdle for medicine
    await _notificationsPlugin.zonedSchedule(
      id,
      '💊 Rappel : $medicationName',
      dosage != null ? 'Il est temps de prendre $dosage.' : 'Il est temps de prendre votre médicament.',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders_channel',
          'Rappels de Médicaments',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true, // Critical for waking up the phone
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  int _generateNotificationId(String alarmKey, int dayOfWeek) {
    return (alarmKey.hashCode ^ dayOfWeek.hashCode).abs() % 2147483647;
  }

  // Helper to clear all (Useful for testing)
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    await _alarmBox.clear();
  }
}