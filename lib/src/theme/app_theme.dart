import 'package:flutter/material.dart';

/// Tema oscuro de la app alineado a la identidad de marca.
///
/// Colores principales:
/// - Naranja [#F88D04] como color de acento/primary.
/// - Azul muy oscuro [#071120] como fondo base.
class AppTheme {
  static const brand = Color(0xFFF88D04);
  static const brandDark = Color(0xFF071120);
  static const surface = Color(0xFF0D161F);
  static const surfaceAlt = Color(0xFF14202B);
  static const correct = Color(0xFFF88D04);
  static const wrong = Color(0xFFE0635A);
  static const onBrand = Colors.white;

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: Brightness.dark,
      primary: brand,
      onPrimary: onBrand,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brandDark,
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
      iconTheme: const IconThemeData(color: brand),
      appBarTheme: const AppBarTheme(
        backgroundColor: brandDark,
        foregroundColor: onBrand,
        elevation: 0,
      ),
    );
  }
}
