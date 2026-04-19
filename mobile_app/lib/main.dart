// mobile_app/lib/main.dart
// ──────────────────────────────────────────────
// DwaFi - Healthcare Mobile App Entry Point
// Designed for elderly Tunisian patients (especially diabetic users)
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/api_client.dart';
import 'core/services/storage_service.dart';
import 'l10n/app_localizations.dart';

// BLoC Imports
import 'blocs/agent/agent_bloc.dart';
import 'blocs/vision/vision_bloc.dart';
import 'blocs/voice/voice_bloc.dart';
import 'blocs/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for elderly users)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    storageService: storageService,
  );

  runApp(
    DwaFiApp(
      apiClient: apiClient,
      storageService: storageService,
    ),
  );
}

/// Root widget that sets up BLoC providers and localization
class DwaFiApp extends StatelessWidget {
  final ApiClient apiClient;
  final StorageService storageService;

  const DwaFiApp({
    super.key,
    required this.apiClient,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Authentication BLoC
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            apiClient: apiClient,
            storageService: storageService,
          ),
        ),

        // Agent BLoC - Chat and medicine management
        BlocProvider<AgentBloc>(
          create: (context) => AgentBloc(
            apiClient: apiClient,
          ),
        ),

        // Vision BLoC - Camera and pill verification
        BlocProvider<VisionBloc>(
          create: (context) => VisionBloc(
            apiClient: apiClient,
          ),
        ),

        // Voice BLoC - STT/TTS for voice interactions
        BlocProvider<VoiceBloc>(
          create: (context) => VoiceBloc(
            apiClient: apiClient,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'DwaFi',
        debugShowCheckedModeBanner: false,

        // Localization configuration
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('fr', ''), // French
          Locale('ar', ''), // Arabic (Standard)
          Locale('ar', 'TN'), // Tunisian Arabic (Derja)
        ],
        locale: const Locale('ar', 'TN'), // Default to Tunisian Arabic

        // Main app widget
        home: const DwaFiMainApp(),
      ),
    );
  }
}

/// Main app shell with navigation
class DwaFiMainApp extends StatefulWidget {
  const DwaFiMainApp({super.key});

  @override
  State<DwaFiMainApp> createState() => _DwaFiMainAppState();
}

class _DwaFiMainAppState extends State<DwaFiMainApp> {
  @override
  Widget build(BuildContext context) {
    // Check authentication state
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const SplashScreen();
        }

        if (state is AuthAuthenticated) {
          return const MainNavigationShell();
        }

        // Not authenticated - show login
        return const LoginScreen();
      },
    );
  }
}

/// Splash screen shown during initialization
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.favorite,
                size: 64,
                color: AppConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // App name
            Text(
              'DwaFi',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Tagline
            Text(
              'رعايتك في يدك',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// Login screen for authentication
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Welcome text
              Text(
                'مرحباً بك',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              Text(
                'سجل دخولك للمتابعة',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 48),

              // Phone number input
              TextField(
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: '+216 XX XXX XXX',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password input
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Trigger authentication
                    context.read<AuthBloc>().add(AuthLoginRequested(
                          phone: '+21600000000',
                          password: 'password',
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'دخول',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main navigation shell after authentication
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CameraScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'التقاط',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'المحادثة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'ملفي',
          ),
        ],
      ),
    );
  }
}

// Placeholder screens - will be implemented in screens/
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Dashboard - TODO')),
    );
  }
}

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Camera - TODO')),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Chat - TODO')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile - TODO')),
    );
  }
}