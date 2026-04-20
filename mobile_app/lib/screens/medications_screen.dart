import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../services/patient_service.dart';
import '../services/vision_service.dart';
import '../services/local_database_service.dart';
import '../services/mock_data_service.dart';
import '../core/network/api_client.dart';
import '../models/medication_model.dart';

// Fix #1: ConsumerStatefulWidget instead of StatefulWidget
class MedicationsScreen extends ConsumerStatefulWidget {
  final int patientId;

  const MedicationsScreen({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

// Fix #1 (cont): ConsumerState instead of State
class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  late PatientService _patientService;
  late VisionService _visionService;
  late LocalDatabaseService _dbService; // Fix #4: will be assigned below
  late Future<List<Medication>> _medicationsFuture;
  bool _isCapturing = false;
  String? _visionResult;

  @override
  void initState() {
    super.initState();
    _patientService = PatientService(ApiClient());
    _visionService = VisionService(ApiClient());
    _dbService = LocalDatabaseService(); // Fix #4: assign instance

    // Fix #3: chain init and fetch so _dbService is ready before use
    // Fix #2: removed invalid ref.watch + undefined 'medications' block
    _medicationsFuture = _fetchMedications();
  }

  Future<void> _initDatabase() async {
    try {
      await _dbService.init();
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  Future<List<Medication>> _fetchMedications() async {
    try {
      // Try to fetch from backend
      final response =
          await _patientService.getPatientMedications(widget.patientId);

      // Parse response into Medication objects
      final medications = _parseMedicationResponse(response);

      // Cache to local database
      if (medications.isNotEmpty) {
        await _dbService.cacheMedications(medications, widget.patientId);
      }

      return medications;
    } catch (e) {
      debugPrint('Error fetching medications from backend: $e');

      // Try cached data first
      final cached = _dbService.getCachedMedications();
      if (cached.isNotEmpty) {
        debugPrint('Using cached medications');
        return cached;
      }

      // Fall back to mock data for demo
      debugPrint('Using mock data for demo');
      final mockMeds =
          await MockDataService.getMockMedications(widget.patientId);

      // Cache the mock data for offline use
      if (mockMeds.isNotEmpty) {
        await _dbService.cacheMedications(mockMeds, widget.patientId);
      }

      return mockMeds;
    }
  }

  List<Medication> _parseMedicationResponse(List<dynamic> response) {
    final medications = <Medication>[];

    for (var item in response) {
      try {
        if (item is Map<String, dynamic>) {
          medications.add(Medication.fromJson(item));
        }
      } catch (e) {
        debugPrint('Error parsing medication: $e');
      }
    }

    return medications;
  }

  Future<void> _captureAndVerify() async {
    setState(() => _isCapturing = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        // Send to vision service
        final result = await _visionService.verifyFrame(base64String);

        setState(() {
          _visionResult =
              result.identifiedMedicine ?? 'No medication detected';
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result.alertMessage ?? _visionResult ?? 'Verification complete'),
            backgroundColor:
                result.safetyAlert == true ? Colors.red : Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.deepTeal,
        title: const Text('Mes Médicaments'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _isCapturing ? null : _captureAndVerify,
            tooltip: 'Vérifier les médicaments par caméra',
          ),
        ],
      ),
      body: FutureBuilder<List<Medication>>(
        future: _medicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _medicationsFuture = _fetchMedications();
                    }),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final medications = snapshot.data ?? [];

          if (medications.isEmpty) {
            return const Center(
              child: Text('Aucun médicament trouvé'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_visionResult != null)
                Card(
                  color: AppColors.cardGreen,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.verified,
                            color: AppColors.persianGreen),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Détecté: $_visionResult',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_visionResult != null) const SizedBox(height: 16),
              ...medications.map((med) => _buildMedicationCard(med)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMedicationCard(Medication med) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading:
            const Icon(Icons.medication, color: AppColors.persianGreen),
        title: Text(
          med.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(med.genericName),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Dosage:', med.dosage),
                _buildInfoRow('Fréquence:', med.frequency),
                if (med.indication != null)
                  _buildInfoRow('Indication:', med.indication!),
                if (med.sideEffects != null)
                  _buildInfoRow('Effets secondaires:', med.sideEffects!),
                if (med.startDate != null)
                  _buildInfoRow('Début:', _formatDate(med.startDate!)),
                if (med.endDate != null)
                  _buildInfoRow('Fin:', _formatDate(med.endDate!)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed:
                      _isCapturing ? null : () => _captureAndVerify(),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Vérifier ce médicament'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.persianGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}