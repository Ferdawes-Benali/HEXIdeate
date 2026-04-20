/// Example: Using Backend Services in Elderly Dashboard
/// 
/// This file shows how to integrate the new API services with the existing UI screens.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../models/chat_model.dart';
import '../models/patient_model.dart';
import '../providers/service_providers.dart';


final logger = Logger();

/// EXAMPLE 1: Display Patient Information
/// 
/// Use this to show patient details from the backend
class PatientInfoCard extends ConsumerWidget {
  final int patientId;

  const PatientInfoCard({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientService = ref.watch(patientServiceProvider);

    return FutureBuilder<Patient>(
      future: patientService.getPatient(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          logger.e('Error loading patient: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Text('Patient not found');
        }

        final patient = snapshot.data!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Age: ${calculateAge(patient.dateOfBirth)} years'),
                Text('Emergency: ${patient.emergencyContactPhone}'),
              ],
            ),
          ),
        );
      },
    );
  }

  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

/// EXAMPLE 2: Chat Interface (Medicine Verification)
/// 
/// Integrate AI agent chat for medication verification
class MedicineVerificationChat extends ConsumerStatefulWidget {
  const MedicineVerificationChat({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicineVerificationChat> createState() =>
      _MedicineVerificationChatState();
}

class _MedicineVerificationChatState
    extends ConsumerState<MedicineVerificationChat> {
  late TextEditingController _messageController;
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    // Add user message to UI
    setState(() {
      _messages.add(ChatMessage(
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      ));
    });

    // Set loading state
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final agentService = ref.read(agentServiceProvider);
      final response = await agentService.chat(message: message);

      // Add agent response to UI
      setState(() {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: response.reply,
          timestamp: DateTime.now(),
        ));
      });

      // Handle safety alerts
      if (response.safetyAlert ?? false) {
        _showSafetyAlert(response.status);
      }
    } catch (e) {
      logger.e('Chat error: $e');
      _showErrorDialog('Communication Error', 'Could not reach the AI assistant: $e');
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void _showSafetyAlert(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Safety alert from AI assistant'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 10),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    return Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUser = message.role == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(message.content),
                ),
              );
            },
          ),
        ),
        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'Tell the AI about your medication...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: isLoading ? null : _sendMessage,
                mini: true,
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// EXAMPLE 3: Medication Adherence Display
/// 
/// Show adherence statistics from analytics service
class AdherenceStatsDisplay extends ConsumerWidget {
  final int patientId;

  const AdherenceStatsDisplay({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsService = ref.watch(analyticsServiceProvider);

    return FutureBuilder(
      future: analyticsService.getAdherenceStats(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          logger.e('Error loading stats: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }

        final stats = snapshot.data;
        if (stats == null) return const Text('No data');

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medication Adherence',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _StatRow(
                  label: 'Adherence Rate',
                  value: '${stats.adherenceRate.toStringAsFixed(1)}%',
                  valueColor: _getColorForAdherence(stats.adherenceRate),
                ),
                _StatRow(
                  label: 'Total Doses Taken',
                  value: '${stats.successfulIntakes}/${stats.totalIntakes}',
                ),
                _StatRow(
                  label: 'Missed Doses',
                  value: '${stats.missedIntakes}',
                  valueColor: Colors.red,
                ),
                _StatRow(
                  label: 'Wrong Time Doses',
                  value: '${stats.wrongTimeIntakes}',
                  valueColor: Colors.orange,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorForAdherence(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// EXAMPLE 4: Medication Alerts/Notifications
/// 
/// Display recent alerts from notification service
class RecentAlertsWidget extends ConsumerWidget {
  final int patientId;

  const RecentAlertsWidget({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.watch(notificationServiceProvider);

    return FutureBuilder(
      future: notificationService.getPatientAlerts(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          logger.e('Error loading alerts: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        }

        final alertResponse = snapshot.data;
        if (alertResponse?.alerts.isEmpty ?? true) {
          return const Center(
            child: Text('No alerts'),
          );
        }

        return ListView.builder(
          itemCount: alertResponse!.alerts.length,
          itemBuilder: (context, index) {
            final alert = alertResponse.alerts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(alert.message),
                subtitle: Text(alert.type),
                leading: _getAlertIcon(alert.severity),
                trailing: alert.isRead ? null : const Icon(Icons.circle, size: 12),
                onTap: () async {
                  if (!alert.isRead) {
                    await notificationService.markAlertAsRead(alert.id);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _getAlertIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Icon(Icons.error, color: Colors.red);
      case 'warning':
        return const Icon(Icons.warning, color: Colors.orange);
      default:
        return const Icon(Icons.info, color: Colors.blue);
    }
  }
}

/// EXAMPLE 5: Skip Risk Prediction
/// 
/// Show predicted skip risk for proactive interventions
class SkipRiskWarning extends ConsumerWidget {
  final int patientId;

  const SkipRiskWarning({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsService = ref.watch(analyticsServiceProvider);

    return FutureBuilder(
      future: analyticsService.predictSkipRisk(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          logger.e('Error predicting skip risk: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        final prediction = snapshot.data;
        if (prediction == null) return const SizedBox.shrink();

        // Only show warning if risk is high
        if (prediction.riskLevel.toLowerCase() == 'low') {
          return const SizedBox.shrink();
        }

        return AlertCard(
          title: 'Medication Skip Risk Alert',
          message: prediction.recommendation,
          riskLevel: prediction.riskLevel,
          factors: prediction.riskFactors,
        );
      },
    );
  }
}

class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final String riskLevel;
  final List<String> factors;

  const AlertCard({
    Key? key,
    required this.title,
    required this.message,
    required this.riskLevel,
    required this.factors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = riskLevel.toLowerCase() == 'high'
        ? Colors.red.shade100
        : Colors.orange.shade100;

    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: riskLevel.toLowerCase() == 'high'
              ? Colors.red
              : Colors.orange,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 8),
          Text(
            'Contributing factors:',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          ...factors.map((f) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('• $f', style: Theme.of(context).textTheme.bodySmall),
          )),
        ],
      ),
    );
  }
}

/// EXAMPLE 6: Authentication Flow
/// 
/// Handle login and store JWT tokens
class LoginButton extends ConsumerWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    return ElevatedButton(
      onPressed: isLoading ? null : () => _handleLogin(context, ref),
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text('Login'),
    );
  }

  Future<void> _handleLogin(BuildContext context, WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      // After successful authentication from your backend
      final token = 'jwt_token_from_backend';
      
      final apiClient = ref.read(apiClientProvider);
      await apiClient.setAuthToken(token);

      // Update auth state
      ref.read(authTokenProvider.notifier).state = token;

      // Navigate to main app
      // Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      logger.e('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}

/// EXAMPLE 7: Logout Handler
/// 
/// Clear authentication and return to login
class LogoutButton extends ConsumerWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _handleLogout(context, ref),
      child: const Text('Logout'),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.clearAuthToken();

    ref.read(authTokenProvider.notifier).state = null;
    ref.read(currentPatientIdProvider.notifier).state = null;

    // Navigate to login
    // Navigator.of(context).pushReplacementNamed('/login');
  }
}
