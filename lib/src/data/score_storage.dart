import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/rush_mode.dart';

/// Persistencia de récords por modo usando shared_preferences.
final scoreStorageProvider = Provider<ScoreStorage>((ref) => ScoreStorage());

class ScoreStorage {
  static const _recentPuzzlesKey = 'recent_puzzle_ids';
  static const _recentPuzzlesLimit = 200;

  SharedPreferences? _prefs;
  Future<void> _pendingPuzzleWrites = Future.value();

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<int> bestScore(RushMode mode) async {
    final prefs = await _instance;
    return prefs.getInt(mode.storageKey) ?? 0;
  }

  /// Guarda [score] si supera el récord actual. Devuelve true si fue récord.
  Future<bool> saveIfBest(RushMode mode, int score) async {
    final prefs = await _instance;
    final current = prefs.getInt(mode.storageKey) ?? 0;
    if (score > current) {
      await prefs.setInt(mode.storageKey, score);
      return true;
    }
    return false;
  }

  Future<List<String>> recentPuzzleIds() async {
    await _pendingPuzzleWrites;
    final prefs = await _instance;
    return prefs.getStringList(_recentPuzzlesKey) ?? const [];
  }

  Future<void> rememberPuzzle(String id) {
    return _pendingPuzzleWrites = _pendingPuzzleWrites.then((_) async {
      final prefs = await _instance;
      final recent = prefs.getStringList(_recentPuzzlesKey) ?? <String>[];
      recent.remove(id);
      recent.add(id);
      if (recent.length > _recentPuzzlesLimit) {
        recent.removeRange(0, recent.length - _recentPuzzlesLimit);
      }
      await prefs.setStringList(_recentPuzzlesKey, recent);
    });
  }
}
