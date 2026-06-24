import 'dart:async';

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart' as dc;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/puzzle_repository.dart';
import '../data/score_storage.dart';
import '../logic/chess_bridge.dart';
import '../model/puzzle.dart';
import '../model/rush_mode.dart';
import '../sound/sound_service.dart';
import 'rush_state.dart';

/// Controlador único de Puzzle Rush. El modo se fija al llamar a [start].
final rushControllerProvider =
    NotifierProvider<RushController, RushState>(RushController.new);

/// Orquesta el bucle de juego de Puzzle Rush: cola de puzzles con dificultad
/// creciente, validación de jugadas contra la línea solución, reproducción
/// automática de las respuestas del rival, vidas/tiempo y récord.
class RushController extends Notifier<RushState> {
  RushMode _mode = RushMode.survival;
  final List<Puzzle> _pool = [];
  int _poolIndex = 0;

  dc.Position? _position;
  Puzzle? _puzzle;
  int _moveIndex = 0;

  Timer? _gameTimer;
  Timer? _replyTimer;
  Timer? _advanceTimer;
  bool _toppingUp = false;

  static const _replyDelay = Duration(milliseconds: 360);
  static const _solvedDelay = Duration(milliseconds: 480);
  static const _wrongDelay = Duration(milliseconds: 760);

  @override
  RushState build() {
    ref.onDispose(_cancelTimers);
    return RushState.idle(_mode);
  }

  /// Puzzle en curso. Expuesto para pruebas.
  @visibleForTesting
  Puzzle? get debugCurrentPuzzle => _puzzle;

  // ---------------------------------------------------------------------------
  // Ciclo de vida de la sesión
  // ---------------------------------------------------------------------------

  /// Inicia (o reinicia) una sesión en el [mode] indicado.
  Future<void> start(RushMode mode) async {
    _mode = mode;
    _cancelTimers();
    _pool.clear();
    _poolIndex = 0;
    _moveIndex = 0;
    state = RushState.idle(_mode).copyWith(status: RushStatus.loading);

    final repo = ref.read(puzzleRepositoryProvider);
    final local = await repo.loadLocalPool();
    _pool.addAll(local);
    if (_pool.isEmpty) {
      state = state.copyWith(status: RushStatus.finished);
      return;
    }

    _loadCurrent();
    if (_mode.isTimed) _startGameTimer();
    _maybeTopUp();
  }

  void quit() {
    _cancelTimers();
    _finish();
  }

  // ---------------------------------------------------------------------------
  // Carga de puzzles
  // ---------------------------------------------------------------------------

  void _loadCurrent() {
    final puzzle = _pool[_poolIndex % _pool.length];
    _puzzle = puzzle;
    final position = positionFromFen(puzzle.fen);
    _position = position;
    _moveIndex = 0;

    final playerSide = toCgSide(position.turn);
    state = state.copyWith(
      status: RushStatus.playing,
      puzzleId: puzzle.id,
      fen: position.fen,
      orientation: playerSide,
      sideToMove: playerSide,
      validMoves: legalMovesOf(position),
      interactable: true,
      isCheck: position.isCheck,
      feedback: MoveFeedback.none,
      clearLastMove: true,
    );
  }

  void _advanceToNext() {
    _poolIndex++;
    _maybeTopUp();
    if (state.status == RushStatus.playing ||
        state.status == RushStatus.loading) {
      _loadCurrent();
    }
  }

  // ---------------------------------------------------------------------------
  // Jugadas del usuario
  // ---------------------------------------------------------------------------

  void onUserMove(cg.Move move) {
    final position = _position;
    final puzzle = _puzzle;
    if (position == null ||
        puzzle == null ||
        !state.interactable ||
        state.status != RushStatus.playing) {
      return;
    }

    final userUci = move.uci;
    final expected = puzzle.moves[_moveIndex];
    final dcMove = dc.NormalMove.fromUci(userUci);

    // Correcta si coincide con la línea, o si es un mate alternativo legal.
    final matchesLine = userUci == expected;
    final isAltMate = !matchesLine &&
        position.isLegal(dcMove) &&
        position.play(dcMove).isCheckmate;

    if (!matchesLine && !isAltMate) {
      _onWrong();
      return;
    }

    // Aplicar la jugada del jugador.
    final after = position.play(dcMove);
    _position = after;
    _moveIndex++;
    SoundService.instance.move(capture: position.board.pieceAt(dcMove.to) != null);
    _renderPosition(after, lastMove: move, interactable: false);

    if (isAltMate || _moveIndex >= puzzle.moves.length) {
      _onSolved();
      return;
    }

    // Reproducir la respuesta del rival tras una breve pausa.
    _replyTimer = Timer(_replyDelay, () {
      if (state.status != RushStatus.playing) return;
      final current = _position;
      if (current == null) return;
      final oppUci = puzzle.moves[_moveIndex];
      final oppMove = dc.NormalMove.fromUci(oppUci);
      final next = current.play(oppMove);
      _position = next;
      _moveIndex++;
      SoundService.instance
          .move(capture: current.board.pieceAt(oppMove.to) != null);
      _renderPosition(next, lastMove: toCgMove(oppUci), interactable: true);
    });
  }

  void _onSolved() {
    SoundService.instance.success();
    state = state.copyWith(
      solved: state.solved + 1,
      feedback: MoveFeedback.correct,
      interactable: false,
    );
    _advanceTimer = Timer(_solvedDelay, _advanceToNext);
  }

  void _onWrong() {
    SoundService.instance.error();
    final strikes = state.strikes + 1;
    state = state.copyWith(
      strikes: strikes,
      feedback: MoveFeedback.wrong,
      interactable: false,
    );

    final limit = _mode.maxStrikes;
    if (limit != null && strikes >= limit) {
      _advanceTimer = Timer(_wrongDelay, _finish);
      return;
    }
    // Modo por tiempo (o aún con vidas): pasar al siguiente puzzle.
    _advanceTimer = Timer(_wrongDelay, _advanceToNext);
  }

  // ---------------------------------------------------------------------------
  // Helpers de render / tiempo
  // ---------------------------------------------------------------------------

  void _renderPosition(
    dc.Position position, {
    required cg.Move lastMove,
    required bool interactable,
  }) {
    state = state.copyWith(
      fen: position.fen,
      sideToMove: toCgSide(position.turn),
      validMoves: interactable ? legalMovesOf(position) : const IMapConst({}),
      interactable: interactable,
      isCheck: position.isCheck,
      lastMove: lastMove,
      feedback: MoveFeedback.none,
    );
  }

  void _startGameTimer() {
    final total = _mode.timeLimit!.inSeconds;
    state = state.copyWith(secondsLeft: total);
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = state.secondsLeft - 1;
      if (left <= 0) {
        state = state.copyWith(secondsLeft: 0);
        _finish();
      } else {
        state = state.copyWith(secondsLeft: left);
      }
    });
  }

  void _finish() {
    if (state.status == RushStatus.finished) return;
    _cancelTimers();
    state = state.copyWith(status: RushStatus.finished, interactable: false);
    ref.read(scoreStorageProvider).saveIfBest(_mode, state.solved).then((rec) {
      if (state.status == RushStatus.finished) {
        state = state.copyWith(isRecord: rec);
      }
    });
  }

  Future<void> _maybeTopUp() async {
    if (_toppingUp || _poolIndex < _pool.length - 5) return;
    _toppingUp = true;
    try {
      final more = await ref.read(puzzleRepositoryProvider).fetchRemote();
      if (more.isNotEmpty) _pool.addAll(more);
    } finally {
      _toppingUp = false;
    }
  }

  void _cancelTimers() {
    _gameTimer?.cancel();
    _replyTimer?.cancel();
    _advanceTimer?.cancel();
    _gameTimer = _replyTimer = _advanceTimer = null;
  }
}
