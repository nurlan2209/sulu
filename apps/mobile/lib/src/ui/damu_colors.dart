import 'package:flutter/material.dart';

class DamuColors {
  static const startBg = Color(0xFF0E2D64);
  static const lightBg = Color(0xFFF0F7FF);
  static const card = Color(0xFFF7FBFF);

  static const primary = Color(0xFF1F7BFF);
  static const primarySoft = Color(0xFF65B6FF);
  static const primaryDeep = Color(0xFF0D4BBF);
  static const accent = Color(0xFF00C9FF);

  static const textOnBlue = Colors.white;
  static const textPrimary = Color(0xFF0A2A43);
  static const textMuted = Color(0xFF7E8CA0);
  static const textMutedLight = Color(0xFFB7C5D8);

  static const shadow = Color(0x22000000);
}

class DamuGradients {
  static const hero = LinearGradient(
    colors: [Color(0xFF0F3FA7), Color(0xFF0AC8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glass = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE8F2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const action = LinearGradient(
    colors: [Color(0xFF0C2E66), Color(0xFF0D64D5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
