import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/rush_mode.dart';

final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  try {
    return LeaderboardService(Supabase.instance.client);
  } catch (_) {
    return LeaderboardService.disabled();
  }
});

enum LeaderboardPeriod { daily, weekly, monthly }

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.score,
    required this.isMe,
  });

  final int rank;
  final String displayName;
  final int score;
  final bool isMe;
}

class LeaderboardService {
  LeaderboardService(this._client) : _enabled = true;

  LeaderboardService.disabled() : _client = null, _enabled = false;

  static const _displayNameKey = 'leaderboard_display_name';

  final SupabaseClient? _client;
  final bool _enabled;

  Future<void> _ensureAuth() async {
    final client = _client!;
    if (client.auth.currentUser == null) {
      await client.auth.signInAnonymously();
    }
  }

  Future<String?> ensurePlayer() async {
    if (!_enabled) return null;
    await _ensureAuth();
    final client = _client!;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_displayNameKey);
    if (saved != null) return saved;

    final id = client.auth.currentUser!.id;
    final generated = 'Player-${id.substring(0, 4).toUpperCase()}';
    return setDisplayName(generated);
  }

  Future<String> setDisplayName(String value) async {
    final name = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.length < 2 || name.length > 20) {
      throw const FormatException('Display name must contain 2–20 characters');
    }
    await _ensureAuth();
    await _client!.rpc(
      'tactic_rush_set_name',
      params: {'p_display_name': name},
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, name);
    return name;
  }

  Future<String?> displayName() async {
    if (!_enabled) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_displayNameKey) ?? ensurePlayer();
  }

  Future<void> submitScore(RushMode mode, int score) async {
    if (!_enabled) return;
    try {
      await ensurePlayer();
      await _client!.rpc(
        'tactic_rush_submit_score',
        params: {'p_mode': mode.name, 'p_score': score},
      );
    } catch (_) {
      // El récord local sigue funcionando sin conexión.
    }
  }

  Future<List<LeaderboardEntry>> fetch(
    RushMode mode,
    LeaderboardPeriod period,
  ) async {
    if (!_enabled) return const [];
    await ensurePlayer();
    final rows =
        await _client!.rpc(
              'tactic_rush_leaderboard',
              params: {'p_mode': mode.name, 'p_period': period.name},
            )
            as List;
    return rows
        .cast<Map<String, dynamic>>()
        .map(
          (row) => LeaderboardEntry(
            rank: (row['rank'] as num).toInt(),
            displayName: row['display_name'] as String,
            score: row['score'] as int,
            isMe: row['is_me'] as bool,
          ),
        )
        .toList();
  }
}
