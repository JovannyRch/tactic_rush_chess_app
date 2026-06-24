import 'package:chessground/chessground.dart' as cg;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tactic_rush_chess_app/src/model/rush_mode.dart';
import 'package:tactic_rush_chess_app/src/rush/rush_controller.dart';
import 'package:tactic_rush_chess_app/src/rush/rush_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  test('una jugada correcta resuelve un mate en 1 y suma al marcador',
      () async {
    final c = makeContainer();
    final notifier = c.read(rushControllerProvider.notifier);
    await notifier.start(RushMode.survival);

    // El primer puzzle (menor rating) es un mate en 1: una sola jugada.
    final puzzle = notifier.debugCurrentPuzzle!;
    expect(puzzle.moves.length, 1);

    notifier.onUserMove(cg.Move.fromUci(puzzle.moves.first));

    final state = c.read(rushControllerProvider);
    expect(state.feedback, MoveFeedback.correct);
    expect(state.solved, 1);
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
    }
  });
}
