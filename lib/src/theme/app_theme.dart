import 'package:flutter/material.dart';

/// Tema oscuro de la app, con acentos verdes al estilo de las apps de ajedrez.
class AppTheme {
  static const seed = Color(0xFF6F9F3F); // verde "tablero"
  static const correct = Color(0xFF7FB23E);
  static const wrong = Color(0xFFE0635A);
  static const surface = Color(0xFF1E2226);
  static const surfaceAlt = Color(0xFF272C31);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF161A1D),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
