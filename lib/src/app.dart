import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'ui/home_screen.dart';

class TacticRushApp extends StatelessWidget {
  const TacticRushApp({
    super.key,
    this.overrideLocale,
    this.debugSkipCountdown = false,
  });

  /// Fuerza un locale concreto. Usado en tests para verificar cada traducción.
  final Locale? overrideLocale;

  /// Solo para tests: salta la cuenta atrás 3-2-1-GO.
  final bool debugSkipCountdown;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tactic Rush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      locale: overrideLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeScreen(debugSkipCountdown: debugSkipCountdown),
    );
  }
}
