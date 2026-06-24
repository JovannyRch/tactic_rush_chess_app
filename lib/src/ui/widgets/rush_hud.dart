import 'package:flutter/material.dart';

import '../../model/rush_mode.dart';
import '../../rush/rush_state.dart';
import '../../theme/app_theme.dart';

/// Marcador superior: puntuación grande y, según el modo, vidas (corazones) o
/// cronómetro.
class RushHud extends StatelessWidget {
  const RushHud({super.key, required this.state});

  final RushState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RESUELTOS',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: Colors.white38, letterSpacing: 1.5)),
            Text(
              '${state.solved}',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.correct,
                height: 1,
              ),
            ),
          ],
        ),
        if (state.mode.maxStrikes != null)
          _Lives(strikes: state.strikes, allowed: state.mode.maxStrikes!)
        else
          _Clock(secondsLeft: state.secondsLeft, mode: state.mode),
      ],
    );
  }
}

class _Lives extends StatelessWidget {
  const _Lives({required this.strikes, required this.allowed});

  final int strikes;
  final int allowed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(allowed, (i) {
        final lost = i < strikes;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Icon(
            lost ? Icons.heart_broken_rounded : Icons.favorite_rounded,
            color: lost ? Colors.white24 : AppTheme.wrong,
            size: 30,
          ),
        );
      }),
    );
  }
}

class _Clock extends StatelessWidget {
  const _Clock({required this.secondsLeft, required this.mode});

  final int secondsLeft;
  final RushMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = secondsLeft ~/ 60;
    final s = secondsLeft % 60;
    final low = secondsLeft <= 15;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('TIEMPO',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: Colors.white38, letterSpacing: 1.5)),
        Text(
          '$m:${s.toString().padLeft(2, '0')}',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: low ? AppTheme.wrong : Colors.white,
            height: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
