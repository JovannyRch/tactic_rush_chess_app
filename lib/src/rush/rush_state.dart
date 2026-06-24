import 'package:chessground/chessground.dart' as cg;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../model/rush_mode.dart';

enum RushStatus { idle, loading, playing, finished }

/// Resultado de la última jugada del jugador, para feedback visual.
enum MoveFeedback { none, correct, wrong }

/// Estado inmutable de una sesión de Puzzle Rush. El controlador mantiene la
/// posición de ajedrez "viva" aparte; aquí solo va lo que la UI necesita pintar.
class RushState {
  const RushState({
    required this.mode,
    required this.status,
    required this.fen,
    required this.orientation,
    required this.sideToMove,
    required this.validMoves,
    required this.interactable,
    required this.isCheck,
    required this.solved,
    required this.strikes,
    required this.secondsLeft,
    required this.feedback,
    this.lastMove,
    this.puzzleId,
    this.isRecord = false,
  });

  final RushMode mode;
  final RushStatus status;

  // --- Tablero ---
  final String fen;
  final cg.Side orientation;
  final cg.Side sideToMove;
  final cg.ValidMoves validMoves;
  final cg.Move? lastMove;
  final bool interactable;
  final bool isCheck;

  // --- Marcador ---
  final int solved;
  final int strikes;
  final int secondsLeft;
  final MoveFeedback feedback;
  final String? puzzleId;
  final bool isRecord;

  int? get strikesAllowed => mode.maxStrikes;

  factory RushState.idle(RushMode mode) => RushState(
        mode: mode,
        status: RushStatus.idle,
        fen: _emptyFen,
        orientation: cg.Side.white,
        sideToMove: cg.Side.white,
        validMoves: const IMapConst({}),
        interactable: false,
        isCheck: false,
        solved: 0,
        strikes: 0,
        secondsLeft: mode.timeLimit?.inSeconds ?? 0,
        feedback: MoveFeedback.none,
      );

  RushState copyWith({
    RushStatus? status,
    String? fen,
    cg.Side? orientation,
    cg.Side? sideToMove,
    cg.ValidMoves? validMoves,
    bool? interactable,
    bool? isCheck,
    int? solved,
    int? strikes,
    int? secondsLeft,
    MoveFeedback? feedback,
    String? puzzleId,
    bool? isRecord,
    cg.Move? lastMove,
    bool clearLastMove = false,
  }) {
    return RushState(
      mode: mode,
      status: status ?? this.status,
      fen: fen ?? this.fen,
      orientation: orientation ?? this.orientation,
      sideToMove: sideToMove ?? this.sideToMove,
      validMoves: validMoves ?? this.validMoves,
      interactable: interactable ?? this.interactable,
      isCheck: isCheck ?? this.isCheck,
      solved: solved ?? this.solved,
      strikes: strikes ?? this.strikes,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      feedback: feedback ?? this.feedback,
      puzzleId: puzzleId ?? this.puzzleId,
      isRecord: isRecord ?? this.isRecord,
      lastMove: clearLastMove ? null : (lastMove ?? this.lastMove),
    );
  }

  static const _emptyFen = '8/8/8/8/8/8/8/8 w - - 0 1';
}
