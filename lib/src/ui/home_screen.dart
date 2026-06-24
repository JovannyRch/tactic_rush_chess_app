import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/score_storage.dart';
import '../model/rush_mode.dart';
import '../theme/app_theme.dart';
import 'rush_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

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
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RushScreen(mode: mode)),
    );
    _loadScores(); // refrescar récords al volver
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              children: [
                const _Logo(),
                const SizedBox(height: 8),
                Text(
                  'Resuelve tantos puzzles como puedas.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                for (final mode in RushMode.values) ...[
                  _ModeCard(
                    mode: mode,
                    best: _best[mode] ?? 0,
                    onTap: () => _play(mode),
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 16),
                Text(
                  'Puzzles de lichess (CC0) · tablero y lógica con\n'
                  'chessground + dartchess',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white38),
                ),
              ],
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
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppTheme.seed,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.bolt_rounded, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Tactic Rush',
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

  IconData get _icon => switch (mode) {
        RushMode.survival => Icons.favorite_rounded,
        RushMode.threeMinutes => Icons.timer_outlined,
        RushMode.fiveMinutes => Icons.timer_rounded,
      };

  @override
  Widget build(BuildContext context) {
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
                  color: AppTheme.seed.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: AppTheme.seed),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.label,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mode.description,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white60),
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
                      color: AppTheme.seed,
                    ),
                  ),
                  Text('récord',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.white38)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
