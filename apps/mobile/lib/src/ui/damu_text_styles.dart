import 'package:flutter/material.dart';

import 'damu_colors.dart';

class DamuTextStyles {
  static TextStyle title() => const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: DamuColors.textOnBlue,
      );

  static TextStyle buttonBig({required Color color}) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle pillValue() => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: DamuColors.textPrimary,
      );

  static TextStyle pillPercent() => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: DamuColors.textMuted,
      );
}

