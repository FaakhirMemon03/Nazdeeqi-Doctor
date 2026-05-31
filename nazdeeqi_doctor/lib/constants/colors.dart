import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryDark = Color(0xFF085041);
  static const Color primaryLight = Color(0xFFE1F5EE);
  
  static const Color secondary = Color(0xFF148F77);
  static const Color accent = Color(0xFFE8F8F5);

  static const Color background = Color(0xFFF9FBFB);
  static const Color cardBg = Colors.white;

  static const Color textDark = Color(0xFF1C2833);
  static const Color textLight = Color(0xFF7F8C8D);

  static const Color success = Color(0xFF27AE60);
  static const Color successBg = Color(0xFFE8F8F5);

  static const Color error = Color(0xFFC0392B);
  static const Color errorBg = Color(0xFFFDEDEC);

  static const Color warning = Color(0xFFF39C12);
  static const Color warningBg = Color(0xFFFEF9E7);

  // Elegant Gradients
  static const LinearGradient tealGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Colors.white70, Colors.white12],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
