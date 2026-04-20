# HexIdeate Mobile App - Backend Integration Guide

## 📱 Setup Instructions

### 1. **Update Gateway URL** 
Edit [lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart):

```dart
// For Android Emulator (default localhost maps to host machine)
static const String baseUrl = 'http://10.0.2.2';

// For iOS Simulator
static const String baseUrl = 'http://localhost';

// For Real Device (replace with your server IP)
static const String baseUrl = 'http://192.168.x.x';
```

### 2. **Install Dependencies**
```bash
flutter pub get
```

### 3. **Generate Code**
This project uses **Freezed** for immutable models and **JSON serialization**:

```bash
flutter pub run build_runner build
# Or for continuous watching:
flutter pub run build_runner watch
```

### 4. **Run the App**
```bash
flutter run
```

---

## 🏗️ Architecture

### Backend Services Connected
- **Gateway** (`${API_BASE}/api`) - Main entry point
  - `/api/patients` - Patient management
  - `/api/agent` - Chat & medication verification
  - `/api/analytics` - Adherence stats & predictions
  - `/api/notifications` - Alert management

### Project Structure
```
lib/
├── main.dart                    # App entry point with Riverpod
├── core/
│   ├── constants/
│   │   └── api_constants.dart  # Gateway URL & endpoints
│   └── network/
│       └── api_client.dart     # Dio HTTP client with auth
├── models/                     # Freezed data classes
│   ├── patient_model.dart
│   ├── medication_model.dart
│   ├── chat_model.dart
│   ├── alert_model.dart
│   └── analytics_model.dart
├── services/                   # Backend communication
│   ├── patient_service.dart
│   ├── agent_service.dart
│   ├── analytics_service.dart
│   └── notification_service.dart
├── providers/                  # Riverpod state management
│   └── service_providers.dart
└── screens/                    # UI screens (existing)
```

---

## 🔌 Using the API Client

### Example 1: Fetch Patient
```dart
// In any widget wrapped with ConsumerWidget or ConsumerStatefulWidget
final patientService = ref.read(patientServiceProvider);
try {
  final patient = await patientService.getPatient(123);
  print('Patient: ${patient.fullName}');
} catch (e) {
  print('Error: $e');
}
```

### Example 2: Chat with Agent
```dart
final agentService = ref.read(agentServiceProvider);
try {
  final response = await agentService.chat(
    message: 'I took my medication',
    videoInput: base64VideoOrNull,  // Optional
  );
  print('Agent reply: ${response.reply}');
  if (response.safetyAlert) {
    print('⚠️ Safety Alert: ${response.status}');
  }
} catch (e) {
  print('Chat error: $e');
}
```

### Example 3: Get Analytics
```dart
final analyticsService = ref.read(analyticsServiceProvider);
try {
  final stats = await analyticsService.getAdherenceStats(123);
  print('Adherence: ${stats.adherenceRate}%');
} catch (e) {
  print('Analytics error: $e');
}
```

### Example 4: Handle Alerts
```dart
final notificationService = ref.read(notificationServiceProvider);
try {
  final alerts = await notificationService.getPatientAlerts(123);
  print('Unread alerts: ${alerts.unreadCount}');
} catch (e) {
  print('Notification error: $e');
}
```

---

## 🔐 Authentication

### Store & Use Auth Token
```dart
// After login, store token
final apiClient = ref.read(apiClientProvider);
await apiClient.setAuthToken('your_jwt_token_here');

// Subsequent requests will include Authorization header
// Authorization: Bearer your_jwt_token_here

// To check if logged in
final isLoggedIn = ref.watch(isLoggedInProvider);

// To logout
await apiClient.clearAuthToken();
```

---

## 📡 Error Handling

The `ApiClient` provides detailed error information:

```dart
try {
  final patient = await patientService.getPatient(999);
} on ApiException catch (e) {
  switch (e.statusCode) {
    case 404:
      print('Patient not found');
      break;
    case 401:
      print('Unauthorized - please login');
      break;
    case 503:
      print('Service unavailable');
      break;
    default:
      print('Error: ${e.message}');
  }
}
```

---

## 🌐 Environment Configuration

For different environments, create environment-specific files:

```dart
// lib/core/constants/api_constants.development.dart
const String baseUrl = 'http://localhost';

// lib/core/constants/api_constants.production.dart
const String baseUrl = 'https://api.hexideate.com';
```

Then import based on build flavor:
```bash
flutter run --dart-define=FLAVOR=development
flutter run --dart-define=FLAVOR=production
```

---

## 📦 Dependencies Used

### Networking
- **dio** (5.3.0) - HTTP client with interceptors
- **http** (1.6.0) - Alternative HTTP client

### State Management
- **flutter_riverpod** (2.4.0) - Reactive state management
- **riverpod** (2.4.0) - Core Riverpod

### Data Models
- **freezed_annotation** (2.4.1) - Immutable class generation
- **json_annotation** (4.8.1) - JSON serialization
- **freezed** (dev) - Code generator for models
- **json_serializable** (dev) - JSON serialization code generator
- **build_runner** (dev) - Dart code generation

### Storage & Security
- **shared_preferences** (2.2.2) - Simple key-value storage
- **flutter_secure_storage** (9.0.0) - Secure token storage
- **hive** (2.2.3) - Local NoSQL database
- **jwt_decoder** (2.0.1) - JWT token parsing

### UI & UX
- **google_fonts** (6.1.0) - Google Fonts
- **flutter_markdown** (0.7.0) - Markdown rendering
- **cupertino_icons** (1.0.8) - iOS icons

### Utilities
- **logger** (2.0.1) - Logging
- **connectivity_plus** (5.1.0) - Network detection
- **intl** (0.19.0) - Internationalization
- **form_validator** (2.1.1) - Form validation
- **permission_handler** (11.4.4) - Permission management
- **image_picker** (1.0.5) - Image selection
- **camera** (0.10.5) - Camera access
- **video_player** (2.8.1) - Video playback
- **flutter_local_notifications** (16.3.0) - Local notifications
- **sentry_flutter** (7.10.0) - Error tracking

---

## 🚀 Gateway API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/patients` | Create patient |
| GET | `/api/patients/{id}` | Get patient |
| GET | `/api/patients/{id}/medications` | List medications |
| POST | `/api/agent/chat` | Chat with agent |
| GET | `/api/analytics/stats/{patient_id}` | Get adherence stats |
| POST | `/api/analytics/predict/skip-risk` | Predict skip risk |
| GET | `/api/analytics/adherence-trend/{patient_id}` | Get trend |
| GET | `/api/notifications/patient/{patient_id}/alerts` | Get alerts |
| POST | `/api/notifications/dispatch` | Send alert |
| PUT | `/api/notifications/alert/{alert_id}/read` | Mark as read |
| PUT | `/api/notifications/alert/{alert_id}/acknowledge` | Acknowledge |

---

## 🔍 Debugging

Enable detailed logging:

```dart
// In main.dart
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);
```

Monitor network traffic:
```dart
// Dio interceptor logs all requests/responses
// Check console output for [📤] requests and [✅] responses
```

---

## 📚 Next Steps

1. **Update UI screens** to use the new services
2. **Implement authentication flow** with JWT tokens
3. **Add proper error handling** and user feedback
4. **Test with real backend** (gateway running)
5. **Configure different environments** (dev/staging/prod)

---

## ⚙️ Troubleshooting

### "Connection refused"
- Check if gateway is running: `docker compose up`
- Update `ApiConstants.baseUrl` for your network

### "Code generation failed"
```bash
flutter pub run build_runner clean
flutter pub run build_runner build
```

### "Models not generated"
- Ensure Freezed annotations are used correctly
- Run: `flutter pub run build_runner watch`

### "JSON serialization errors"
- Check model imports: `part 'model_name.g.dart';`
- Regenerate: `flutter pub run build_runner build --delete-conflicting-outputs`

---

## 📞 Support

For issues with backend integration, check:
- Gateway logs: `docker compose logs gateway`
- API response in network inspector (Dio logs)
- Model definitions in `lib/models/`
