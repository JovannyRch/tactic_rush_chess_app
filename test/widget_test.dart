import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tactic_rush_chess_app/l10n/app_localizations.dart';
import 'package:tactic_rush_chess_app/src/app.dart';
import 'package:tactic_rush_chess_app/src/data/leaderboard_service.dart';
import 'package:tactic_rush_chess_app/src/data/puzzle_repository.dart';
import 'package:tactic_rush_chess_app/src/model/puzzle.dart';
import 'package:tactic_rush_chess_app/src/model/rush_mode.dart';
import 'package:tactic_rush_chess_app/src/rush/rush_state.dart';
import 'package:tactic_rush_chess_app/src/ui/leaderboard_screen.dart';
import 'package:tactic_rush_chess_app/src/ui/rush_screen.dart';
import 'package:tactic_rush_chess_app/src/sound/sound_service.dart';
import 'package:tactic_rush_chess_app/src/ui/widgets/rush_hud.dart';

class _FakeLeaderboardService extends LeaderboardService {
  _FakeLeaderboardService() : super.disabled();

  @override
  Future<List<LeaderboardEntry>> fetch(
    RushMode mode,
    LeaderboardPeriod period,
  ) async => const [
    LeaderboardEntry(rank: 1, displayName: 'Knight', score: 12, isMe: true),
  ];
}

// Los tests usan el locale por defecto del entorno (inglés). Las cadenas
// en español se verifican por separado en el l10n_test.dart.
class _FakePuzzleRepository extends PuzzleRepository {
  _FakePuzzleRepository()
      : super(client: MockClient((_) async => http.Response('Not found', 404)));

  @override
  Future<List<Puzzle>> loadLocalPool() async => const [
        Puzzle(
          id: 'test1',
          fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          moves: ['e2e4'],
          rating: 500,
        ),
        Puzzle(
          id: 'test2',
          fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          moves: ['e7e5'],
          rating: 600,
        ),
      ];

  @override
  Future<List<Puzzle>> fetchRemote({int count = 8}) async => const [];
}

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
      ProviderScope(
        overrides: [
          puzzleRepositoryProvider.overrideWithValue(_FakePuzzleRepository()),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: RushScreen(
            mode: RushMode.survival,
            skipCountdown: true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

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

  testWidgets('long HUD history fits on a narrow screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(220, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final history = List.generate(
      40,
      (index) => index.isEven ? PuzzleResult.correct : PuzzleResult.wrong,
    );
    final state = RushState.idle(
      RushMode.survival,
    ).copyWith(solved: 20, strikes: 1, history: history);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: RushHud(state: state),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.close_rounded), findsNWidgets(3));
  });

  testWidgets('online leaderboard shows periods and scores', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leaderboardServiceProvider.overrideWithValue(
            _FakeLeaderboardService(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LeaderboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Knight'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('quitting a game returns to the home screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzleRepositoryProvider.overrideWithValue(_FakePuzzleRepository()),
        ],
        child: const TacticRushApp(debugSkipCountdown: true),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Survival'));
    await tester.pump(const Duration(seconds: 1));
    debugDumpApp();
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quit'));
    await tester.pumpAndSettle();

    expect(find.text('Tactic Rush'), findsOneWidget);
    expect(find.byType(cg.Board), findsNothing);
  });
}
