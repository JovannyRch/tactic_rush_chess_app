import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tactic_rush_chess_app/src/app.dart';
import 'package:tactic_rush_chess_app/src/sound/sound_service.dart';

Widget _app(Locale locale) => ProviderScope(
      child: Builder(
        builder: (_) => TacticRushApp(overrideLocale: locale),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.instance.enabled = false;
  });

  testWidgets('English locale shows correct strings', (tester) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pump();

    expect(find.text('Survival'), findsOneWidget);
    expect(find.text('3 minutes'), findsOneWidget);
    expect(find.text('5 minutes'), findsOneWidget);
    expect(find.text('record'), findsNWidgets(3));
  });

  testWidgets('Spanish locale shows correct strings', (tester) async {
    await tester.pumpWidget(_app(const Locale('es')));
    await tester.pump();

    expect(find.text('Supervivencia'), findsOneWidget);
    expect(find.text('3 minutos'), findsOneWidget);
    expect(find.text('5 minutos'), findsOneWidget);
    expect(find.text('récord'), findsNWidgets(3));
  });
}
