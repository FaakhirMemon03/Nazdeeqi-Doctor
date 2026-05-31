import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    firebaseAvailable = true;
  } catch (e) {
    debugPrint("Firebase init failed or credentials missing: $e");
    debugPrint("Falling back to Demo Mode.");
  }

  // Initialize services directly — no demo mode selector screen needed
  ServiceLocator.init(demoMode: !firebaseAvailable);

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
