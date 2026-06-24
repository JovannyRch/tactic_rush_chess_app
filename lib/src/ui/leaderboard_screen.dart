import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../data/leaderboard_service.dart';
import '../model/rush_mode.dart';
import '../theme/app_theme.dart';
import 'rush_mode_l10n.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key, this.initialMode = RushMode.survival});

  final RushMode initialMode;

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  late RushMode _mode = widget.initialMode;
  LeaderboardPeriod _period = LeaderboardPeriod.weekly;
  late Future<List<LeaderboardEntry>> _entries = _load();

  Future<List<LeaderboardEntry>> _load() =>
      ref.read(leaderboardServiceProvider).fetch(_mode, _period);

  void _reload() => setState(() => _entries = _load());

  Future<void> _editName() async {
    final service = ref.read(leaderboardServiceProvider);
    final controller = TextEditingController(
      text: await service.displayName() ?? '',
    );
    if (!mounted) return;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.leaderboardNameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.quitCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(AppLocalizations.of(context)!.leaderboardSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    try {
      await service.setDisplayName(value);
      _reload();
    } on FormatException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.leaderboardNameInvalid),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboardTitle),
        actions: [
          IconButton(
            tooltip: l10n.leaderboardEditName,
            onPressed: _editName,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedButton<RushMode>(
                    segments: [
                      for (final mode in RushMode.values)
                        ButtonSegment(
                          value: mode,
                          label: Text(mode.label(l10n)),
                        ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (value) {
                      _mode = value.first;
                      _reload();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<LeaderboardPeriod>(
                  segments: [
                    ButtonSegment(
                      value: LeaderboardPeriod.daily,
                      label: Text(l10n.leaderboardDaily),
                    ),
                    ButtonSegment(
                      value: LeaderboardPeriod.weekly,
                      label: Text(l10n.leaderboardWeekly),
                    ),
                    ButtonSegment(
                      value: LeaderboardPeriod.monthly,
                      label: Text(l10n.leaderboardMonthly),
                    ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (value) {
                    _period = value.first;
                    _reload();
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder<List<LeaderboardEntry>>(
                    future: _entries,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _Message(
                          icon: Icons.cloud_off_rounded,
                          text: l10n.leaderboardOffline,
                          action: _reload,
                        );
                      }
                      final entries = snapshot.data ?? const [];
                      if (entries.isEmpty) {
                        return _Message(
                          icon: Icons.emoji_events_outlined,
                          text: l10n.leaderboardEmpty,
                          action: _reload,
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => _reload(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: entries.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Card(
                              color: entry.isMe
                                  ? AppTheme.brand.withValues(alpha: 0.18)
                                  : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: entry.rank <= 3
                                      ? AppTheme.brand
                                      : AppTheme.surfaceAlt,
                                  child: Text('${entry.rank}'),
                                ),
                                title: Text(entry.displayName),
                                trailing: Text(
                                  '${entry.score}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppTheme.brand,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    required this.action,
  });

  final IconData icon;
  final String text;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.white38),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: action,
              child: Text(AppLocalizations.of(context)!.leaderboardRetry),
            ),
          ],
        ),
      ),
    );
  }
}
