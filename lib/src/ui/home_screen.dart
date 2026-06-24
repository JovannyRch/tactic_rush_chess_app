import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations.dart';
import '../data/puzzle_repository.dart';
import '../data/score_storage.dart';
import '../model/puzzle.dart';
import '../model/rush_mode.dart';
import '../theme/app_theme.dart';
import 'daily_puzzle_screen.dart';
import 'rush_mode_l10n.dart';
import 'rush_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.debugSkipCountdown = false});

  /// Solo para tests: salta la cuenta atrás 3-2-1-GO al entrar en una partida.
  final bool debugSkipCountdown;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<RushMode, int> _best = {};

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final storage = ref.read(scoreStorageProvider);
    final entries = <RushMode, int>{};
    for (final mode in RushMode.values) {
      entries[mode] = await storage.bestScore(mode);
    }
    if (mounted) setState(() => _best = entries);
  }

  Future<void> _play(RushMode mode) async {
    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder: (_) => RushScreen(
          mode: mode,
          skipCountdown: widget.debugSkipCountdown,
        ),
      ),
    );
    _loadScores();
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) return;

    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.brand,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.bolt_rounded, color: Colors.white),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.homeAttribution,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              child: Column(
                children: [
                const _Logo(),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: l10n.aboutTitle,
                    icon: const Icon(Icons.info_outline_rounded),
                    onPressed: () => _showAboutDialog(context),
                  ),
                ),
                Text(
                  l10n.homeSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                _DailyPuzzleCard(
                  onPlay: (puzzle) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DailyPuzzleScreen(puzzle: puzzle),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                for (final mode in RushMode.values) ...[
                  _ModeCard(
                    mode: mode,
                    best: _best[mode] ?? 0,
                    onTap: () => _play(mode),
                  ),
                  const SizedBox(height: 10),
                ],
                /* const SizedBox(height: 16),
                Text(
                  l10n.homeAttribution,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                  ),
                ), */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.brand.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset('assets/img/logo.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.best,
    required this.onTap,
  });

  final RushMode mode;
  final int best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(mode.icon, color: AppTheme.brand),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.label(l10n),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mode.description(l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    '$best',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brand,
                    ),
                  ),
                  Text(
                    l10n.record,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyPuzzleCard extends ConsumerWidget {
  const _DailyPuzzleCard({required this.onPlay});

  final void Function(Puzzle puzzle) onPlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final daily = ref.watch(dailyPuzzleProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: daily.value != null ? () => onPlay(daily.value!) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.brand.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      color: AppTheme.brand,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dailyPuzzleTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: daily.when(
                            data: (puzzle) => puzzle != null
                                ? Text(
                                    'Rating ${puzzle.rating}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white60,
                                    ),
                                  )
                                : Text(
                                    'Unavailable',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white38,
                                    ),
                                  ),
                            loading: () => const SizedBox(
                              height: 14,
                              width: 80,
                              child: LinearProgressIndicator(),
                            ),
                            error: (_, __) => Text(
                              'Unavailable',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (daily.value != null)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white38,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
