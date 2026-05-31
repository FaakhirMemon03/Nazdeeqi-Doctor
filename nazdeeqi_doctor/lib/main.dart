import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'services/service_locator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed or credentials missing: $e");
    // Throwing so developer knows Firebase is strictly required
    rethrow;
  }

  // Initialize strictly Firebase services
  ServiceLocator.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const NazdeeqiDoctorApp(),
    ),
  );
}

class NazdeeqiDoctorApp extends StatelessWidget {
  const NazdeeqiDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nazdeeqi Doctor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
