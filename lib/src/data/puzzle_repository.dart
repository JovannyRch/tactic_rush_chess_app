import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:dartchess/dartchess.dart' as dc;

import '../model/puzzle.dart';

/// Provee el repositorio de puzzles a la app.
final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  return PuzzleRepository(client: http.Client());
});

/// Repositorio híbrido de puzzles:
///   - Fuente local: bundle de arranque empaquetado como asset (offline).
///   - Fuente remota: endpoint público de lichess para ampliar el repertorio
///     cuando hay red. Si la red falla, se degrada silenciosamente al local.
class PuzzleRepository {
  PuzzleRepository({required http.Client client}) : _client = client;

  final http.Client _client;

  static const _assetPath = 'assets/puzzles/sample_puzzles.json';
  static const _nextEndpoint = 'https://lichess.org/api/puzzle/next';

  List<Puzzle>? _localCache;

  /// Carga el bundle local (cacheado tras la primera lectura), ordenado por
  /// rating ascendente para alimentar la progresión de dificultad.
  Future<List<Puzzle>> loadLocalPool() async {
    if (_localCache != null) return _localCache!;
    final raw = await rootBundle.loadString(_assetPath);
    final list =
        (jsonDecode(raw) as List)
            .map((e) => Puzzle.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.rating.compareTo(b.rating));
    _localCache = list;
    return list;
  }

  /// Mezcla cada banda de 200 Elo sin romper la progresión. Los puzzles
  /// recientes quedan al final de su banda y solo reaparecen al agotarla.
  List<Puzzle> buildSessionPool(
    List<Puzzle> puzzles,
    Set<String> recentIds, {
    Random? random,
  }) {
    final rng = random ?? Random();
    final bands = <int, List<Puzzle>>{};
    for (final puzzle in puzzles) {
      (bands[puzzle.rating ~/ 200] ??= []).add(puzzle);
    }

    final result = <Puzzle>[];
    for (final band in bands.keys.toList()..sort()) {
      final fresh = <Puzzle>[];
      final recent = <Puzzle>[];
      for (final puzzle in bands[band]!) {
        (recentIds.contains(puzzle.id) ? recent : fresh).add(puzzle);
      }
      fresh.shuffle(rng);
      recent.shuffle(rng);
      result
        ..addAll(fresh)
        ..addAll(recent);
    }
    return result;
  }

  /// Intenta traer [count] puzzles nuevos desde lichess. Devuelve lista vacía
  /// si no hay red o algo falla (nunca lanza). Usado para ampliar el pool.
  Future<List<Puzzle>> fetchRemote({int count = 8}) async {
    final result = <Puzzle>[];
    final seen = <String>{};
    for (var i = 0; i < count; i++) {
      try {
        final res = await _client
            .get(
              Uri.parse(_nextEndpoint),
              headers: const {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 8));
        if (res.statusCode != 200) break;
        final puzzle = _fromLichessJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
        if (puzzle != null && seen.add(puzzle.id)) {
          result.add(puzzle);
        }
      } catch (_) {
        break; // sin red: degradar al pool local
      }
    }
    return result;
  }

  /// Convierte el formato crudo de lichess (`game.pgn` + `puzzle.solution`) al
  /// modelo de la app, reconstruyendo la FEN con dartchess y normalizando la
  /// línea para que empiece por el jugador. Devuelve null si no valida.
  Puzzle? _fromLichessJson(Map<String, dynamic> json) {
    try {
      final puzzle = json['puzzle'] as Map<String, dynamic>;
      final game = json['game'] as Map<String, dynamic>;
      final solution = (puzzle['solution'] as List).cast<String>();
      if (solution.isEmpty) return null;

      // Reproducir el PGN para reconstruir la posición.
      dc.Position pos = dc.Chess.initial;
      for (final node in dc.PgnGame.parsePgn(
        game['pgn'] as String,
      ).moves.mainline()) {
        final move = pos.parseSan(node.san);
        if (move == null) return null;
        pos = pos.play(move);
      }
      // Aplicar la jugada de preparación del rival (solution[0]).
      final setup = dc.NormalMove.fromUci(solution.first);
      if (!pos.isLegal(setup)) return null;
      pos = pos.play(setup);

      final playerLine = solution.sublist(1);
      if (playerLine.isEmpty) return null;
      // Validar legalidad de la línea.
      dc.Position check = pos;
      for (final uci in playerLine) {
        final m = dc.NormalMove.fromUci(uci);
        if (!check.isLegal(m)) return null;
        check = check.play(m);
      }

      return Puzzle(
        id: puzzle['id'] as String,
        fen: pos.fen,
        moves: playerLine,
        rating: puzzle['rating'] as int,
        themes: (puzzle['themes'] as List?)?.cast<String>() ?? const [],
      );
    } catch (_) {
      return null;
    }
  }
}
