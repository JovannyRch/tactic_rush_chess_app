import 'dart:async';

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart' as dc;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, visibleForTesting;
import 'package:flutter/services.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/puzzle_repository.dart';
import '../data/leaderboard_service.dart';
import '../data/score_storage.dart';
import '../logic/chess_bridge.dart';
import '../model/puzzle.dart';
import '../model/rush_mode.dart';
import '../sound/sound_service.dart';
import 'rush_state.dart';

/// Controlador único de Puzzle Rush. El modo se fija al llamar a [start].
final rushControllerProvider = NotifierProvider<RushController, RushState>(
  RushController.new,
);

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
  Timer? _setupTimer;
  bool _toppingUp = false;
  bool _finishing = false;

  static const _replyDelay = Duration(milliseconds: 360);
  static const _solvedDelay = Duration(milliseconds: 700);
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
  ///
  /// [skipCountdown] es útil en tests para evitar la cuenta atrás 3-2-1-GO.
  Future<void> start(RushMode mode, {bool skipCountdown = false}) async {
    _mode = mode;
    _cancelTimers();
    _pool.clear();
    _poolIndex = 0;
    _moveIndex = 0;
    _finishing = false;
    state = RushState.idle(_mode).copyWith(status: RushStatus.loading);

    final repo = ref.read(puzzleRepositoryProvider);
    final local = await repo.loadLocalPool();
    final recent = await ref.read(scoreStorageProvider).recentPuzzleIds();

    // Priorizar BlitzTactics (batch remoto) sobre el pool local.
    // Si no hay red, degradar silenciosamente al bundle offline.
    final remote = await repo.fetchRemote(count: 8);
    final basePool = remote.isNotEmpty ? remote : local;

    _pool.addAll(repo.buildSessionPool(basePool, recent.toSet()));
    if (_pool.isEmpty) {
      state = state.copyWith(status: RushStatus.finished);
      return;
    }

    if (skipCountdown) {
      _loadCurrent();
      if (_mode.isTimed) _startGameTimer();
      _maybeTopUp();
    } else {
      _startCountdown();
    }
  }

  /// Muestra la cuenta atrás 3-2-1-GO antes de comenzar a jugar.
  void _startCountdown() {
    const step = Duration(milliseconds: 700);
    var value = 3;

    void tick() {
      if (value >= 0) {
        state = state.copyWith(
          status: RushStatus.countdown,
          countdownValue: value,
        );
        value--;
        _setupTimer = Timer(step, tick);
      } else {
        _loadCurrent();
        if (_mode.isTimed) _startGameTimer();
        _maybeTopUp();
      }
    }

    tick();
  }

  void quit() {
    _cancelTimers();
    _finishing = false;
    state = RushState.idle(_mode);
  }

  @visibleForTesting
  Future<void> debugFinish() => _finish();

  // ---------------------------------------------------------------------------
  // Carga de puzzles
  // ---------------------------------------------------------------------------

  void _loadCurrent() {
    final puzzle = _pool[_poolIndex % _pool.length];
    _puzzle = puzzle;
    if (kDebugMode) {
      debugPrint(
        '[Puzzle] source=${puzzle.source.name} | id=${puzzle.id} | rating=${puzzle.rating}',
      );
    }
    unawaited(ref.read(scoreStorageProvider).rememberPuzzle(puzzle.id));
    _moveIndex = 0;

    if (puzzle.setupFen != null && puzzle.setupMove != null) {
      _playSetupAnimation(puzzle);
    } else {
      _renderPlayerPosition(puzzle.fen, puzzleId: puzzle.id);
    }
  }

  /// Renderiza la posición donde le toca jugar al usuario.
  void _renderPlayerPosition(String fen, {required String puzzleId}) {
    final position = positionFromFen(fen);
    _position = position;

    final playerSide = toCgSide(position.turn);
    state = state.copyWith(
      status: RushStatus.playing,
      puzzleId: puzzleId,
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

  /// Muestra la jugada de preparación del rival antes de dejar jugar al usuario.
  void _playSetupAnimation(Puzzle puzzle) {
    final setupPosition = positionFromFen(puzzle.setupFen!);
    _position = setupPosition;

    // La orientación es siempre la del jugador (bando después del setup).
    final playerSide = toCgSide(positionFromFen(puzzle.fen).turn);

    state = state.copyWith(
      status: RushStatus.playing,
      puzzleId: puzzle.id,
      fen: setupPosition.fen,
      orientation: playerSide,
      sideToMove: toCgSide(setupPosition.turn),
      validMoves: const IMapConst({}),
      interactable: false,
      isCheck: setupPosition.isCheck,
      feedback: MoveFeedback.none,
      clearLastMove: true,
    );

    _setupTimer = Timer(const Duration(milliseconds: 500), () {
      if (state.status != RushStatus.playing) return;
      final move = dc.NormalMove.fromUci(puzzle.setupMove!);
      final after = setupPosition.play(move);
      _position = after;
      SoundService.instance.move(
        capture: setupPosition.board.pieceAt(move.to) != null,
      );
      state = state.copyWith(
        fen: after.fen,
        sideToMove: toCgSide(after.turn),
        validMoves: legalMovesOf(after),
        interactable: true,
        isCheck: after.isCheck,
        lastMove: toCgMove(puzzle.setupMove!),
      );
    });
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
    final isAltMate =
        !matchesLine &&
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
    SoundService.instance.move(
      capture: position.board.pieceAt(dcMove.to) != null,
    );
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
      SoundService.instance.move(
        capture: current.board.pieceAt(oppMove.to) != null,
      );
      _renderPosition(next, lastMove: toCgMove(oppUci), interactable: true);
    });
  }

  void _onSolved() {
    state = state.copyWith(
      solved: state.solved + 1,
      feedback: MoveFeedback.correct,
      combo: state.combo + 1,
      history: [...state.history, PuzzleResult.correct],
      interactable: false,
    );
    _advanceTimer = Timer(_solvedDelay, _advanceToNext);
  }

  void _onWrong() {
    HapticFeedback.vibrate();
    final strikes = state.strikes + 1;
    state = state.copyWith(
      strikes: strikes,
      feedback: MoveFeedback.wrong,
      combo: 0,
      history: [...state.history, PuzzleResult.wrong],
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
        if (left == 10) SoundService.instance.lowTime();
        state = state.copyWith(secondsLeft: left);
      }
    });
  }

  Future<void> _finish() async {
    if (_finishing || state.status == RushStatus.finished) return;
    _finishing = true;
    _cancelTimers();
    SoundService.instance.result(state.solved);
    final record = await ref
        .read(scoreStorageProvider)
        .saveIfBest(_mode, state.solved)
        .catchError((_) => false);
    unawaited(
      ref.read(leaderboardServiceProvider).submitScore(_mode, state.solved),
    );
    if (!_finishing) return;
    state = state.copyWith(
      status: RushStatus.finished,
      interactable: false,
      isRecord: record,
    );
    _finishing = false;
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
    _setupTimer?.cancel();
    _gameTimer = _replyTimer = _advanceTimer = _setupTimer = null;
  }
}
