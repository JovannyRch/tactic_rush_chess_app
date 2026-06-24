import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'ui/home_screen.dart';

class TacticRushApp extends StatelessWidget {
  const TacticRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tactic Rush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
