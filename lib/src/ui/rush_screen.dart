import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/rush_mode.dart';
import '../rush/rush_controller.dart';
import '../rush/rush_state.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';
import 'widgets/rush_hud.dart';

class RushScreen extends ConsumerStatefulWidget {
  const RushScreen({super.key, required this.mode});

  final RushMode mode;

  @override
  ConsumerState<RushScreen> createState() => _RushScreenState();
}

class _RushScreenState extends ConsumerState<RushScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rushControllerProvider.notifier).start(widget.mode);
    });
  }

  Future<bool> _confirmQuit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir de la partida?'),
        content: const Text('Se perderá el progreso actual.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Seguir')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salir')),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Navegar a resultados cuando la sesión termina.
    ref.listen(rushControllerProvider, (prev, next) {
      if (prev?.status != RushStatus.finished &&
          next.status == RushStatus.finished) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              mode: next.mode,
              score: next.solved,
              isRecord: next.isRecord,
            ),
          ),
        );
      }
    });

    final state = ref.watch(rushControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmQuit() && mounted) {
          ref.read(rushControllerProvider.notifier).quit();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () async {
                        if (await _confirmQuit() && mounted) {
                          ref.read(rushControllerProvider.notifier).quit();
                        }
                      },
                    ),
                    const Spacer(),
                    Text(widget.mode.label,
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 8),
                RushHud(state: state),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: _BoardArea(state: state),
                  ),
                ),
                const SizedBox(height: 12),
                _TurnIndicator(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardArea extends ConsumerWidget {
  const _BoardArea({required this.state});

  final RushState state;

  cg.InteractableSide get _interactable {
    if (!state.interactable) return cg.InteractableSide.none;
    return state.orientation == cg.Side.white
        ? cg.InteractableSide.white
        : cg.InteractableSide.black;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            constraints.biggest.shortestSide.clamp(0.0, 480.0).toDouble();
        return Stack(
          alignment: Alignment.center,
          children: [
            cg.Board(
              size: size,
              settings: const cg.BoardSettings(
                colorScheme: cg.BoardColorScheme.green,
                animationDuration: Duration(milliseconds: 220),
                showValidMoves: true,
                showLastMove: true,
                enableCoordinates: true,
              ),
              data: cg.BoardData(
                interactableSide: _interactable,
                orientation: state.orientation,
                fen: state.fen,
                sideToMove: state.sideToMove,
                validMoves: state.validMoves,
                lastMove: state.lastMove,
                isCheck: state.isCheck,
                opponentsPiecesUpsideDown: false,
              ),
              onMove: (move, {isDrop, isPremove}) {
                ref.read(rushControllerProvider.notifier).onUserMove(move);
              },
            ),
            _FeedbackBadge(feedback: state.feedback, size: size),
          ],
        );
      },
    );
  }
}

/// Marca visual de acierto/error que aparece brevemente sobre el tablero.
class _FeedbackBadge extends StatelessWidget {
  const _FeedbackBadge({required this.feedback, required this.size});

  final MoveFeedback feedback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visible = feedback != MoveFeedback.none;
    final correct = feedback == MoveFeedback.correct;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        child: Container(
          width: size * 0.28,
          height: size * 0.28,
          decoration: BoxDecoration(
            color: (correct ? AppTheme.correct : AppTheme.wrong)
                .withValues(alpha: 0.92),
            shape: BoxShape.circle,
          ),
          child: Icon(
            correct ? Icons.check_rounded : Icons.close_rounded,
            color: Colors.white,
            size: size * 0.18,
          ),
        ),
      ),
    );
  }
}

class _TurnIndicator extends StatelessWidget {
  const _TurnIndicator({required this.state});

  final RushState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (text, color) = switch (state.feedback) {
      MoveFeedback.correct => ('¡Correcto!', AppTheme.correct),
      MoveFeedback.wrong => ('Fallo', AppTheme.wrong),
      MoveFeedback.none => (
          state.interactable
              ? (state.orientation == cg.Side.white
                  ? 'Juegan blancas · encuentra la mejor jugada'
                  : 'Juegan negras · encuentra la mejor jugada')
              : 'Respondiendo…',
          Colors.white60,
        ),
    };
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 150),
      style: theme.textTheme.titleMedium!.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      child: Text(text),
    );
  }
}
