import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tactic_rush_chess_app/l10n/app_localizations.dart';
import 'package:tactic_rush_chess_app/src/app.dart';
import 'package:tactic_rush_chess_app/src/model/rush_mode.dart';
import 'package:tactic_rush_chess_app/src/rush/rush_state.dart';
import 'package:tactic_rush_chess_app/src/ui/rush_screen.dart';
import 'package:tactic_rush_chess_app/src/sound/sound_service.dart';
import 'package:tactic_rush_chess_app/src/ui/widgets/rush_hud.dart';

// Los tests usan el locale por defecto del entorno (inglés). Las cadenas
// en español se verifican por separado en el l10n_test.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.instance.enabled = false;
  });

  testWidgets('home screen shows title and all three modes', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TacticRushApp()));
    await tester.pump();

    expect(find.text('Tactic Rush'), findsOneWidget);
    expect(find.text('Survival'), findsOneWidget);
    expect(find.text('3 minutes'), findsOneWidget);
    expect(find.text('5 minutes'), findsOneWidget);
  });

  testWidgets('game screen renders the board', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: RushScreen(mode: RushMode.survival),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(cg.Board), findsOneWidget);
  });

  testWidgets('HUD shows correct and missed puzzle history', (tester) async {
    final state = RushState.idle(RushMode.survival).copyWith(
      solved: 1,
      strikes: 1,
      history: const [PuzzleResult.correct, PuzzleResult.wrong],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RushHud(state: state)),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('rush-history')), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('quitting a game returns to the home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TacticRushApp()));
    await tester.pump();

    await tester.tap(find.text('Survival'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithIcon(IconButton, Icons.close_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quit'));
    await tester.pumpAndSettle();

    expect(find.text('Tactic Rush'), findsOneWidget);
    expect(find.byType(cg.Board), findsNothing);
  });
}
