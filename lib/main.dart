import 'package:annadanam_food_charity/pages/role_selection_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'models/user_model.dart';
import 'models/user_role.dart';
import 'pages/auth/auth_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/splash_screen.dart';
import 'services/database_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to disable screen security globally at startup
  try {
    const channel = MethodChannel('com.annadanam.app/security');
    await channel.invokeMethod('disableSecure');
    print('✅ Global: Requested screen security disable');
  } catch (e) {
    print('⚠️ Global: Error requesting screen security disable: $e');
  }

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ .env file not found or could not be loaded: $e');
    print('ℹ️  Using hardcoded default API URL: http://localhost:3000/api');
    // We don't rethrow because ApiService has a fallback
  }

  // STEP 1: Initialize Database FIRST (Only on mobile/desktop)
  if (!kIsWeb) {
    try {
      final dbService = DatabaseService();
      await dbService.database;
      print('✅ Database initialized successfully');
    } catch (e) {
      print('❌ Database initialization failed: $e');
    }
  } else {
    print('ℹ️ Skipping SQLite initialization on Web');
  }

  // STEP 2: Initialize Firebase (optional)
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDEXAMPLEKEY1234567890",
        appId: "1:123456789012:android:abcdef1234567890",
        messagingSenderId: "123456789012",
        projectId: "annadanam-food-charity",
        databaseURL:
            "https://annadanam-food-charity-default-rtdb.asia-south1.firebasedatabase.app",
      ),
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print(
        '⚠️ Firebase initialization failed: $e. Continuing without Firebase...');
  }

  runApp(const AnnadanamApp());
}

class AnnadanamApp extends StatelessWidget {
  const AnnadanamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Annadanam Food Charity',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.green),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
          case '/role-selection':
            return MaterialPageRoute(
              builder: (context) => const RoleSelectionPage(),
            );
          case '/auth':
            final args = settings.arguments;
            return MaterialPageRoute(
              builder: (context) => AuthPage(
                initialRole: args is UserRole ? args : UserRole.donor,
              ),
              settings: settings,
            );
          case '/dashboard':
            final args = settings.arguments;
            if (args is User) {
              return MaterialPageRoute(
                builder: (context) => DashboardPage(user: args),
                settings: const RouteSettings(name: '/dashboard'),
              );
            }
            return MaterialPageRoute(
              builder: (context) => const RoleSelectionPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
        }
      },
    );
  }
}

