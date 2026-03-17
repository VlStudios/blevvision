import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandBlue = Color(0xFF0D2B57);
  static const Color brandOrange = Color(0xFFF28C18);
  static const Color bg = Color(0xFFF7F8FB);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandOrange,
      brightness: Brightness.light,
      primary: brandOrange,
    ).copyWith(
      primary: brandOrange,
      secondary: brandBlue,
      background: bg,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: brandBlue,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: brandOrange.withOpacity(.15),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
