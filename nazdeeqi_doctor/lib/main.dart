import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseAvailable = false;
  try {
    // Attempt Firebase SDK configuration load
    await Firebase.initializeApp();
    firebaseAvailable = true;
  } catch (e) {
    debugPrint("Firebase init failed or credentials file is missing: $e");
    debugPrint("Falling back to local Demo Sandbox Mode simulation.");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: NazdeeqiDoctorApp(firebaseInitialized: firebaseAvailable),
    ),
  );
}

class NazdeeqiDoctorApp extends StatelessWidget {
  final bool firebaseInitialized;
  const NazdeeqiDoctorApp({super.key, required this.firebaseInitialized});

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
