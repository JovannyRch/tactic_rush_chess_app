import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../model/rush_mode.dart';
import '../theme/app_theme.dart';
import 'rush_mode_l10n.dart';
import 'rush_screen.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({
    super.key,
    required this.mode,
    required this.score,
    required this.isRecord,
  });

  final RushMode mode;
  final int score;
  final bool isRecord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRecord
                        ? Icons.emoji_events_rounded
                        : Icons.flag_rounded,
                    size: 72,
                    color:
                        isRecord ? const Color(0xFFE9B949) : AppTheme.seed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRecord ? l10n.resultNewRecord : l10n.resultGameOver,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.label(l10n),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white54),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '$score',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.correct,
                      height: 1,
                    ),
                  ),
                  Text(
                    l10n.resultPuzzlesSolved,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white54),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.resultPlayAgain),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => RushScreen(mode: mode),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.home_rounded),
                      label: Text(l10n.resultHome),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
