import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tactic_rush_chess_app/src/app.dart';
import 'package:tactic_rush_chess_app/src/model/rush_mode.dart';
import 'package:tactic_rush_chess_app/src/ui/rush_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('La pantalla de inicio muestra el título y los modos',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TacticRushApp()));
    await tester.pump();

    expect(find.text('Tactic Rush'), findsOneWidget);
    expect(find.text('Supervivencia'), findsOneWidget);
    expect(find.text('3 minutos'), findsOneWidget);
    expect(find.text('5 minutos'), findsOneWidget);
  });

  testWidgets('La pantalla de juego renderiza el tablero', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: RushScreen(mode: RushMode.survival)),
      ),
    );
    // Deja correr el postFrame que carga el primer puzzle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(cg.Board), findsOneWidget);
  });
}
