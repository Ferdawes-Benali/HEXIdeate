## 🚀 HexIdeate Mobile App - Quick Start Guide

### 📁 New Project Structure

```
mobile_app/
├── lib/
│   ├── main.dart                           # App entry point (Riverpod + Flutter)
│   ├── INTEGRATION_EXAMPLES.dart           # 7 code examples
│   │
│   ├── core/                               # Core functionality
│   │   ├── constants/
│   │   │   └── api_constants.dart         # Gateway URLs & endpoints
│   │   └── network/
│   │       └── api_client.dart            # Dio HTTP client
│   │
│   ├── models/                             # Freezed data classes
│   │   ├── patient_model.dart
│   │   ├── medication_model.dart
│   │   ├── chat_model.dart
│   │   ├── alert_model.dart
│   │   └── analytics_model.dart
│   │
│   ├── services/                           # Backend API services
│   │   ├── patient_service.dart
│   │   ├── agent_service.dart
│   │   ├── analytics_service.dart
│   │   └── notification_service.dart
│   │
│   ├── providers/                          # Riverpod state management
│   │   └── service_providers.dart
│   │
│   └── screens/                            # Existing UI screens
│       ├── elderly_dashboard.dart
│       └── caregiver_dashboard.dart
│
├── pubspec.yaml                            # Project dependencies
├── pubspec.lock                            # Locked dependency versions
│
├── BACKEND_INTEGRATION.md                  # Setup & usage guide
├── PUBSPEC_SUMMARY.md                      # Dependency breakdown
├── IMPLEMENTATION_COMPLETE.md              # This implementation summary
├── setup.sh                                # Automated setup script
│
└── analysis_options.yaml                   # Lint rules
```

---

## 🎯 5-Minute Quick Start

### 1. Install Dependencies
```bash
cd mobile_app
flutter pub get
```

### 2. Generate Code
```bash
flutter pub run build_runner build
```

### 3. Update Gateway URL
Edit `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2';  // Android
// static const String baseUrl = 'http://localhost';  // iOS
```

### 4. Run
```bash
flutter run
```

### 5. Check Console
Look for network logs:
```
📤 [POST] /api/patients
✅ [200] /api/patients
```

---

## 🔌 Quick Reference: Using Services

### Get Patient Info
```dart
final patientService = ref.read(patientServiceProvider);
final patient = await patientService.getPatient(patientId);
```

### Chat with Agent
```dart
final agentService = ref.read(agentServiceProvider);
final response = await agentService.chat(message: "I took my pill");
print(response.reply);
```

### Get Adherence Stats
```dart
final analyticsService = ref.read(analyticsServiceProvider);
final stats = await analyticsService.getAdherenceStats(patientId);
print('${stats.adherenceRate}%');
```

### Get Alerts
```dart
final notificationService = ref.read(notificationServiceProvider);
final alerts = await notificationService.getPatientAlerts(patientId);
```

---

## 📊 API Endpoints Connected

| Endpoint | Purpose | Service |
|----------|---------|---------|
| `POST /api/patients` | Create patient | PatientService |
| `GET /api/patients/{id}` | Get patient info | PatientService |
| `GET /api/patients/{id}/medications` | List medications | PatientService |
| `POST /api/agent/chat` | Chat with AI | AgentService |
| `GET /api/analytics/stats/{id}` | Get adherence | AnalyticsService |
| `POST /api/analytics/predict/skip-risk` | Predict risk | AnalyticsService |
| `GET /api/notifications/patient/{id}/alerts` | Get alerts | NotificationService |

---

## 🛠️ Key Concepts

### Freezed Models
Immutable, type-safe data classes:
```dart
const Patient patient = Patient(
  id: 1,
  fullName: 'Ahmed',
  dateOfBirth: DateTime(1960, 1, 15),
  emergencyContact: 'Fatma',
  emergencyContactPhone: '+216 98765432',
);
```

### Riverpod Providers
Reactive state management:
```dart
// Service providers (singletons)
final patientServiceProvider = Provider((ref) => PatientService(...));

// State providers (mutable)
final currentPatientIdProvider = StateProvider<int?>((ref) => null);

// Watch providers
final isLoggedInProvider = Provider((ref) => ref.watch(authTokenProvider) != null);
```

### ApiClient
Centralized HTTP client with Dio:
```dart
// Automatic features:
// ✅ Request/response logging
// ✅ JWT authentication
// ✅ Error handling
// ✅ Timeouts
// ✅ Interceptors
```

---

## 🔐 Authentication Flow

```dart
// 1. User logs in
final token = 'jwt_token_from_backend';

// 2. Store token
final apiClient = ref.read(apiClientProvider);
await apiClient.setAuthToken(token);

// 3. Update state
ref.read(authTokenProvider.notifier).state = token;

// 4. All subsequent requests include:
// Authorization: Bearer jwt_token_from_backend

// 5. To logout
await apiClient.clearAuthToken();
ref.read(authTokenProvider.notifier).state = null;
```

---

## 📱 Integration with UI

### Example: Display Patient Name
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final patientService = ref.read(patientServiceProvider);
  
  return FutureBuilder<Patient>(
    future: patientService.getPatient(123),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Text('Welcome, ${snapshot.data!.fullName}');
      }
      return CircularProgressIndicator();
    },
  );
}
```

### Example: Chat Widget
```dart
ElevatedButton(
  onPressed: () async {
    final agentService = ref.read(agentServiceProvider);
    final response = await agentService.chat(message: userMessage);
    setState(() => chatMessages.add(response));
  },
  child: Text('Send'),
)
```

---

## ❌ Common Mistakes to Avoid

1. ❌ Forgetting to run code generation
   - ✅ `flutter pub run build_runner build`

2. ❌ Using wrong gateway URL
   - ✅ Update `ApiConstants.baseUrl`

3. ❌ Not wrapping widgets with ConsumerWidget/ConsumerStatefulWidget
   - ✅ Use `ConsumerWidget` to access `ref`

4. ❌ Forgetting await on async calls
   - ✅ `final data = await service.getData();`

5. ❌ Storing raw base64 video data
   - ✅ Convert to S3 URL or file path

---

## 🧪 Testing the Integration

### 1. Verify Gateway Connection
```bash
# In terminal
curl -i http://localhost/health

# Expected response:
# HTTP/1.1 200 OK
# {"status": "ok", "service": "gateway"}
```

### 2. Check Network Logs
```bash
# Run app
flutter run

# In console, you should see:
# 📤 [POST] /api/agent/chat
# ✅ [200] /api/agent/chat
```

### 3. Monitor API Calls
- Use network inspector in DevTools
- Check Dio logs in console
- All requests include timestamps and endpoints

---

## 📚 Documentation Index

| Document | Purpose |
|----------|---------|
| `BACKEND_INTEGRATION.md` | Complete setup guide + API reference |
| `PUBSPEC_SUMMARY.md` | Dependency breakdown + architecture diagram |
| `INTEGRATION_EXAMPLES.dart` | 7 real-world code examples |
| `IMPLEMENTATION_COMPLETE.md` | Full implementation summary |
| `setup.sh` | Automated setup script |

---

## 🚀 Deployment Checklist

- [ ] Update `ApiConstants.baseUrl` to production URL
- [ ] Test all API endpoints with real data
- [ ] Set up error tracking (Sentry)
- [ ] Configure JWT refresh token logic
- [ ] Test camera/media permissions
- [ ] Test local notifications
- [ ] Build APK: `flutter build apk --release`
- [ ] Build IPA: `flutter build ios --release`
- [ ] Test on real device
- [ ] Submit to Play Store / App Store

---

## 💡 Pro Tips

1. **Use ConsumerStatefulWidget for complex logic**
   ```dart
   class MyWidget extends ConsumerStatefulWidget {
     @override
     ConsumerState<MyWidget> createState() => _MyWidgetState();
   }
   
   class _MyWidgetState extends ConsumerState<MyWidget> {
     @override
     Widget build(BuildContext context) {
       final service = ref.read(patientServiceProvider);
       // ...
     }
   }
   ```

2. **Cache service calls to avoid redundant requests**
   ```dart
   final cachedPatientProvider = FutureProvider<Patient>((ref) async {
     return ref.read(patientServiceProvider).getPatient(123);
   });
   ```

3. **Use FutureBuilder for async data loading**
   ```dart
   FutureBuilder<Data>(
     future: service.getData(),
     builder: (context, snapshot) { ... }
   )
   ```

4. **Handle all exceptions**
   ```dart
   try {
     await service.operation();
   } on ApiException catch (e) {
     // Handle API errors
   } catch (e) {
     // Handle other errors
   }
   ```

---

## 🔍 Debugging Commands

```bash
# Clean and rebuild
flutter clean && flutter pub get

# Regenerate code
flutter pub run build_runner clean
flutter pub run build_runner build

# Run with logs
flutter run -v

# View gateway logs
docker compose logs gateway -f

# Test gateway health
curl http://localhost/health

# Check running containers
docker compose ps
```

---

## 📞 Troubleshooting

### App won't connect to gateway
- ✅ Check gateway is running: `docker compose ps`
- ✅ Verify gateway URL in `ApiConstants`
- ✅ For Android: Use `http://10.0.2.2`
- ✅ For iOS: Use `http://localhost`

### Models not generating
- ✅ Add `part 'model.g.dart';` imports
- ✅ Run: `flutter pub run build_runner build --delete-conflicting-outputs`

### JWT token not being sent
- ✅ Ensure token is set: `await apiClient.setAuthToken(token)`
- ✅ Check console logs for `Authorization` header

### Network timeout
- ✅ Increase timeout in `ApiConstants`
- ✅ Check gateway performance: `docker compose logs`

---

## ✨ Features Summary

✅ 40+ production dependencies installed
✅ HTTP client with automatic logging
✅ 5 data models (Patient, Medication, Chat, Alert, Analytics)
✅ 4 service classes (Patient, Agent, Analytics, Notification)
✅ Riverpod state management
✅ Secure token storage
✅ Type-safe API responses
✅ Comprehensive error handling
✅ Camera & media integration
✅ Local notifications
✅ Full documentation
✅ 7 integration examples
✅ Automated setup script

---

## 🎓 Next Level

### Advanced Features
- WebSocket for real-time updates
- Offline-first data sync
- Background tasks for reminders
- Custom error tracking
- Analytics integration

### Performance
- Response caching
- Image lazy loading
- Code splitting
- Minification

### Testing
- Unit tests for services
- Integration tests
- UI tests with Flutter Driver
- Load testing

---

**Everything is ready! Start building with the HexIdeate API.**

Follow the setup instructions and reference the examples to get started quickly.
