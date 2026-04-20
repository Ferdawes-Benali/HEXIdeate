import '../models/medication_model.dart';

/// Mock data service for development and offline testing
class MockDataService {
  static final List<Medication> sampleMedications = [
    Medication(
      id: '1',
      patientId: 1,
      name: 'Paracétamol',
      genericName: 'Acetaminophen',
      dosage: '500mg',
      frequency: '3 fois par jour',
      indication: 'Fièvre, douleur légère à modérée',
      sideEffects: 'Nausée, allergie',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Medication(
      id: '2',
      patientId: 1,
      name: 'Metformine',
      genericName: 'Metformin',
      dosage: '1000mg',
      frequency: '2 fois par jour',
      indication: 'Diabète type 2',
      sideEffects: 'Trouble gastrique, diarrhée',
      startDate: DateTime.now().subtract(const Duration(days: 365)),
      endDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Medication(
      id: '3',
      patientId: 1,
      name: 'Atorvastatine',
      genericName: 'Atorvastatin',
      dosage: '20mg',
      frequency: 'Une fois par jour le soir',
      indication: 'Cholestérol élevé',
      sideEffects: 'Douleur musculaire rare',
      startDate: DateTime.now().subtract(const Duration(days: 180)),
      endDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Medication(
      id: '4',
      patientId: 1,
      name: 'Lisinopril',
      genericName: 'Lisinopril',
      dosage: '10mg',
      frequency: 'Une fois par jour',
      indication: 'Hypertension artérielle',
      sideEffects: 'Toux sèche, vertiges',
      startDate: DateTime.now().subtract(const Duration(days: 90)),
      endDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Medication(
      id: '5',
      patientId: 1,
      name: 'Aspirin',
      genericName: 'Aspirin',
      dosage: '81mg',
      frequency: 'Une fois par jour le matin',
      indication: 'Prévention cardiovasculaire',
      sideEffects: 'Saignement gastrique rare',
      startDate: DateTime.now().subtract(const Duration(days: 365)),
      endDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Medication(
      id: '6',
      patientId: 1,
      name: 'Vitamine D3',
      genericName: 'Cholecalciferol',
      dosage: '1000 UI',
      frequency: 'Une fois par jour',
      indication: 'Santé osseuse, immunité',
      sideEffects: 'Aucun effet secondaire courant',
      startDate: DateTime.now().subtract(const Duration(days: 180)),
      endDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  /// Get mock medications
  static Future<List<Medication>> getMockMedications(int patientId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return sampleMedications.where((m) => m.patientId == patientId).toList();
  }

  /// Add a new mock medication
  static Medication addMockMedication({
    required int patientId,
    required String name,
    required String genericName,
    required String dosage,
    required String frequency,
    String? indication,
    String? sideEffects,
  }) {
    final newMed = Medication(
      id: (sampleMedications.length + 1).toString(),
      patientId: patientId,
      name: name,
      genericName: genericName,
      dosage: dosage,
      frequency: frequency,
      indication: indication,
      sideEffects: sideEffects,
      startDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    sampleMedications.add(newMed);
    return newMed;
  }
}
