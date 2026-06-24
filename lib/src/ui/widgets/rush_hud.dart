import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../rush/rush_state.dart';
import '../../theme/app_theme.dart';

class RushHud extends StatelessWidget {
  const RushHud({super.key, required this.state});

  final RushState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.hudSolved,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
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
              _Clock(l10n: l10n, secondsLeft: state.secondsLeft),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 22,
          child: state.history.isNotEmpty
              ? _History(results: state.history)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.results});

  final List<PuzzleResult> results;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      key: const ValueKey('rush-history'),
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 28).floor().clamp(1, 12);
        final visible = results.length > count
            ? results.sublist(results.length - count)
            : results;
        return Row(
          children: [
            for (final (index, result) in visible.indexed)
              Padding(
                padding: EdgeInsets.only(
                  right: index == visible.length - 1 ? 0 : 6,
                ),
                child: AnimatedContainer(
                  key: ValueKey('${results.length}-$index-${result.name}'),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: result == PuzzleResult.correct
                        ? AppTheme.correct
                        : AppTheme.wrong,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    result == PuzzleResult.correct
                        ? Icons.check_rounded
                        : Icons.close_rounded,
                    size: 15,
                    color: Colors.white,
                    semanticLabel: result == PuzzleResult.correct
                        ? l10n.feedbackCorrect
                        : l10n.feedbackWrong,
                  ),
                ),
              ),
          ],
        );
      },
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
  const _Clock({required this.l10n, required this.secondsLeft});

  final AppLocalizations l10n;
  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = secondsLeft ~/ 60;
    final s = secondsLeft % 60;
    final low = secondsLeft <= 15;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.hudTime,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white38,
            letterSpacing: 1.5,
          ),
        ),
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
