import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/rush_mode.dart';

/// Persistencia de récords por modo usando shared_preferences.
final scoreStorageProvider = Provider<ScoreStorage>((ref) => ScoreStorage());

class ScoreStorage {
  SharedPreferences? _prefs;

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
}
