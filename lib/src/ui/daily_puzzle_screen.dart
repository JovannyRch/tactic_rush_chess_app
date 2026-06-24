import 'dart:async';

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart' as dc;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../logic/chess_bridge.dart';
import '../model/puzzle.dart';
import '../sound/sound_service.dart';
import '../theme/app_theme.dart';

/// Pantalla para jugar el puzzle del día de lichess.
///
/// Es una experiencia de un solo puzzle: el usuario intenta seguir la línea
/// solución completa. Un fallo termina el intento.
class DailyPuzzleScreen extends ConsumerStatefulWidget {
  const DailyPuzzleScreen({super.key, required this.puzzle});

  final Puzzle puzzle;

  @override
  ConsumerState<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends ConsumerState<DailyPuzzleScreen> {
  late dc.Position _position;
  late cg.Side _orientation;
  int _moveIndex = 0;
  bool _finished = false;
  bool _solved = false;
  bool _interactable = true;

  @override
  void initState() {
    super.initState();
    _position = positionFromFen(widget.puzzle.fen);
    _orientation = toCgSide(_position.turn);
  }

  void _onUserMove(cg.Move move, {bool? isDrop, bool? isPremove}) {
    if (!_interactable || _finished) return;

    final expected = widget.puzzle.moves[_moveIndex];
    final userUci = move.uci;

    // También aceptamos mates alternativos legales.
    final isAltMate = userUci != expected &&
        _position.isLegal(dc.NormalMove.fromUci(userUci)) &&
        _position.play(dc.NormalMove.fromUci(userUci)).isCheckmate;

    if (userUci != expected && !isAltMate) {
      _setWrong();
      return;
    }

    _applyMove(move);
    SoundService.instance.move();

    final nextIndex = _moveIndex + 1;
    if (nextIndex >= widget.puzzle.moves.length) {
      _setSolved();
      return;
    }

    // Reproducir la respuesta del rival tras una breve pausa.
    setState(() => _interactable = false);
    Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final oppUci = widget.puzzle.moves[nextIndex];
      _applyMove(cg.Move.fromUci(oppUci));
      SoundService.instance.move();
      setState(() {
        _moveIndex = nextIndex + 1;
        _interactable = true;
      });
    });
  }

  void _applyMove(cg.Move move) {
    final dcMove = dc.NormalMove.fromUci(move.uci);
    _position = _position.play(dcMove);
  }

  void _setSolved() {
    SoundService.instance.success();
    setState(() {
      _finished = true;
      _solved = true;
      _interactable = false;
    });
  }

  void _setWrong() {
    HapticFeedback.heavyImpact();
    setState(() {
      _finished = true;
      _solved = false;
      _interactable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyPuzzleTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _StatusBar(
                moveIndex: _moveIndex,
                total: widget.puzzle.moves.length,
                finished: _finished,
                solved: _solved,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.biggest.shortestSide
                          .clamp(0.0, 480.0)
                          .toDouble();
                      return cg.Board(
                        size: size,
                        settings: const cg.BoardSettings(
                          colorScheme: cg.BoardColorScheme.brown,
                          animationDuration: Duration(milliseconds: 220),
                          showValidMoves: true,
                          showLastMove: true,
                          enableCoordinates: true,
                        ),
                        data: cg.BoardData(
                          interactableSide: _interactable
                              ? (_orientation == cg.Side.white
                                  ? cg.InteractableSide.white
                                  : cg.InteractableSide.black)
                              : cg.InteractableSide.none,
                          orientation: _orientation,
                          fen: _position.fen,
                          sideToMove: toCgSide(_position.turn),
                          validMoves: _interactable
                              ? legalMovesOf(_position)
                              : const IMapConst({}),
                          isCheck: _position.isCheck,
                        ),
                        onMove: _onUserMove,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_finished) ...[
                Text(
                  _solved ? l10n.feedbackCorrect : l10n.feedbackWrong,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: _solved ? AppTheme.correct : AppTheme.wrong,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.resultHome),
                  ),
                ),
              ] else ...[
                Text(
                  l10n.dailyPuzzleHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white60),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.moveIndex,
    required this.total,
    required this.finished,
    required this.solved,
  });

  final int moveIndex;
  final int total;
  final bool finished;
  final bool solved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          finished
              ? (solved ? 'Solved' : 'Failed')
              : 'Move ${moveIndex + 1} / $total',
          style: theme.textTheme.titleMedium?.copyWith(
            color: finished
                ? (solved ? AppTheme.correct : AppTheme.wrong)
                : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
