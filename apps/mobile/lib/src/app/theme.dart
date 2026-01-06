import 'package:flutter/material.dart';

class DamuTheme {
  static ThemeData light() {
    const primary = Color(0xFF2F7AD8);
    final scheme = ColorScheme.fromSeed(seedColor: primary, primary: primary, brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: null,
      scaffoldBackgroundColor: const Color(0xFF78B8F6),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    );
  }
}
