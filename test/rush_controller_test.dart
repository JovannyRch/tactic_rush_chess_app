import 'package:chessground/chessground.dart' as cg;
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tactic_rush_chess_app/src/data/puzzle_repository.dart';
import 'package:tactic_rush_chess_app/src/data/score_storage.dart';
import 'package:tactic_rush_chess_app/src/model/puzzle.dart';
import 'package:tactic_rush_chess_app/src/model/rush_mode.dart';
import 'package:tactic_rush_chess_app/src/rush/rush_controller.dart';
import 'package:tactic_rush_chess_app/src/rush/rush_state.dart';
import 'package:tactic_rush_chess_app/src/sound/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SoundService.instance.enabled = false; // sin canales de audio en tests
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  test('start carga el primer puzzle y queda jugable', () async {
    final c = makeContainer();
    await c.read(rushControllerProvider.notifier).start(RushMode.survival);

    final state = c.read(rushControllerProvider);
    expect(state.status, RushStatus.playing);
    expect(state.interactable, isTrue);
    expect(state.puzzleId, isNotNull);
    expect(state.validMoves, isNotEmpty);
  });

  test('acepta la primera jugada correcta del puzzle', () async {
    final c = makeContainer();
    final notifier = c.read(rushControllerProvider.notifier);
    await notifier.start(RushMode.survival);
    final puzzle = notifier.debugCurrentPuzzle!;

    notifier.onUserMove(cg.Move.fromUci(puzzle.moves.first));

    final state = c.read(rushControllerProvider);
    if (puzzle.moves.length == 1) {
      expect(state.feedback, MoveFeedback.correct);
      expect(state.solved, 1);
      expect(state.combo, 1);
      expect(state.history, [PuzzleResult.correct]);
    } else {
      expect(state.interactable, isFalse);
      expect(state.strikes, 0);
    }
  });

  test('una jugada incorrecta cuenta como fallo (strike)', () async {
    final c = makeContainer();
    final notifier = c.read(rushControllerProvider.notifier);
    await notifier.start(RushMode.survival);

    // Una jugada legal pero que no es la solución (ni mate alternativo).
    final state0 = c.read(rushControllerProvider);
    final from = state0.validMoves.keys.first;
    final to = state0.validMoves[from]!.first;
    final wrong = cg.Move(from: from, to: to);

    // Asegurarnos de que no es justo la solución.
    if (wrong.uci != notifier.debugCurrentPuzzle!.moves.first) {
      notifier.onUserMove(wrong);
      final state = c.read(rushControllerProvider);
      expect(state.strikes + state.solved, greaterThanOrEqualTo(1));
      expect(state.combo, 0);
      expect(state.history.last, PuzzleResult.wrong);
    }
  });

  test('finished ya incluye el nuevo récord', () async {
    SharedPreferences.setMockInitialValues({RushMode.survival.storageKey: -1});
    final c = makeContainer();
    final notifier = c.read(rushControllerProvider.notifier);
    await notifier.start(RushMode.survival);

    await notifier.debugFinish();

    final state = c.read(rushControllerProvider);
    expect(state.status, RushStatus.finished);
    expect(state.solved, 0);
    expect(state.isRecord, isTrue);
  });

  test('quit descarta la sesión sin guardar resultado', () async {
    final c = makeContainer();
    final notifier = c.read(rushControllerProvider.notifier);
    await notifier.start(RushMode.survival);

    notifier.onUserMove(
      cg.Move.fromUci(notifier.debugCurrentPuzzle!.moves.first),
    );
    notifier.quit();

    expect(c.read(rushControllerProvider).status, RushStatus.idle);
    expect(await c.read(scoreStorageProvider).bestScore(RushMode.survival), 0);
  });

  test('mezcla por bandas y relega puzzles recientes', () {
    final client = http.Client();
    addTearDown(client.close);
    final repo = PuzzleRepository(client: client);
    const puzzles = [
      Puzzle(id: 'a', fen: '', moves: [], rating: 601),
      Puzzle(id: 'b', fen: '', moves: [], rating: 650),
      Puzzle(id: 'c', fen: '', moves: [], rating: 799),
      Puzzle(id: 'd', fen: '', moves: [], rating: 800),
      Puzzle(id: 'e', fen: '', moves: [], rating: 850),
    ];

    final pool = repo.buildSessionPool(puzzles, {'a', 'd'});

    expect(pool.take(3).map((p) => p.rating ~/ 200).toSet(), {3});
    expect(pool.skip(3).map((p) => p.rating ~/ 200).toSet(), {4});
    expect(pool.indexWhere((p) => p.id == 'a'), 2);
    expect(pool.indexWhere((p) => p.id == 'd'), 4);
  });

  test('recuerda solo los últimos 200 puzzles sin duplicados', () async {
    final storage = ScoreStorage();
    for (var i = 0; i < 205; i++) {
      await storage.rememberPuzzle('p$i');
    }
    await storage.rememberPuzzle('p100');

    final recent = await storage.recentPuzzleIds();
    expect(recent, hasLength(200));
    expect(recent, isNot(contains('p0')));
    expect(recent.last, 'p100');
    expect(recent.where((id) => id == 'p100'), hasLength(1));
  });
}
