import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:dartchess/dartchess.dart' as dc;

import '../logic/chess_bridge.dart';
import '../model/puzzle.dart';

/// Provee el repositorio de puzzles a la app.
final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  return PuzzleRepository(client: http.Client());
});

/// Provee el puzzle del día de lichess.
final dailyPuzzleProvider = FutureProvider<Puzzle?>((ref) async {
  final repo = ref.watch(puzzleRepositoryProvider);
  return repo.fetchDailyPuzzle();
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
  static const _blitzEndpoints = [
    'https://blitztactics.com/haste/puzzles',
    'https://blitztactics.com/three/puzzles',
  ];

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

  /// Trae un batch de puzzles desde BlitzTactics. Si falla, recae en
  /// lichess. Nunca lanza; devuelve lista vacía si no hay red.
  Future<List<Puzzle>> fetchRemote({int count = 8}) async {
    // 1) Intentar un batch completo de BlitzTactics.
    final shuffled = [..._blitzEndpoints]..shuffle(Random());
    for (final endpoint in shuffled) {
      try {
        final res = await _client
            .get(Uri.parse(endpoint))
            .timeout(const Duration(seconds: 10));
        if (res.statusCode != 200) continue;
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final puzzles = (body['puzzles'] as List)
            .map((e) => _fromBlitzTacticsJson(e as Map<String, dynamic>))
            .whereType<Puzzle>()
            .toList();
        if (puzzles.isNotEmpty) return puzzles;
      } catch (_) {
        continue;
      }
    }

    // 2) Fallback a lichess, puzzle por puzzle.
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
        break;
      }
    }
    return result;
  }

  /// Trae el puzzle del día de lichess. Devuelve null si falla.
  Future<Puzzle?> fetchDailyPuzzle() async {
    try {
      final res = await _client
          .get(Uri.parse('https://lichess.org/api/puzzle/daily'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      return _fromLichessDailyJson(
        jsonDecode(res.body) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
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
        source: PuzzleSource.lichess,
      );
    } catch (_) {
      return null;
    }
  }

  /// Convierte la respuesta de `/api/puzzle/daily` al modelo de la app.
  /// El JSON ya incluye el FEN final y la línea de solución completa.
  Puzzle? _fromLichessDailyJson(Map<String, dynamic> json) {
    try {
      final puzzle = json['puzzle'] as Map<String, dynamic>;
      final solution = (puzzle['solution'] as List).cast<String>();
      if (solution.isEmpty) return null;

      final fen = puzzle['fen'] as String;
      dc.Position pos = dc.Chess.fromSetup(dc.Setup.parseFen(fen));

      // Validar legalidad de toda la línea (empieza por el jugador).
      for (final uci in solution) {
        final m = dc.NormalMove.fromUci(uci);
        if (!pos.isLegal(m)) return null;
        pos = pos.play(m);
      }

      return Puzzle(
        id: puzzle['id'] as String,
        fen: fen,
        moves: solution,
        rating: puzzle['rating'] as int,
        themes: (puzzle['themes'] as List?)?.cast<String>() ?? const [],
        source: PuzzleSource.lichess,
      );
    } catch (_) {
      return null;
    }
  }

  @visibleForTesting
  Puzzle? parseBlitzPuzzleForTest(Map<String, dynamic> json) =>
      _fromBlitzTacticsJson(json);

  /// Convierte un puzzle de BlitzTactics al modelo de la app.
  ///
  /// El JSON trae un árbol (`lines`) y una `initialMove`; el FEN ya refleja
  /// la posición después de esa jugada inicial, así que solo hay que extraer
  /// la primera línea forzada y validarla contra dartchess.
  Puzzle? _fromBlitzTacticsJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] as String;
      final fen = json['fen'] as String;
      final lines = json['lines'] as Map<String, dynamic>;
      final rating = (json['rating'] as num).toInt();

      if (lines.isEmpty) return null;
      final moves = _extractBlitzLine(lines);
      if (moves.isEmpty) return null;

      final setup = dc.Setup.parseFen(fen);
      dc.Position pos = dc.Chess.fromSetup(setup);

      // Aplicar la jugada de preparación del rival.
      final initialUci = (json['initialMove']?['uci'] as String?) ?? '';
      if (initialUci.isNotEmpty) {
        final initialMove = dc.NormalMove.fromUci(initialUci);
        if (!pos.isLegal(initialMove)) return null;
        pos = pos.play(initialMove);
      }
      final playerFen = pos.fen;

      // Validar la línea de respuesta del jugador.
      for (final uci in moves) {
        final m = dc.NormalMove.fromUci(uci);
        if (!pos.isLegal(m)) return null;
        pos = pos.play(m);
      }

      return Puzzle(
        id: 'blitz_$id',
        fen: playerFen,
        moves: moves,
        rating: rating,
        themes: const [],
        source: PuzzleSource.blitztactics,
        setupFen: fen,
        setupMove: initialUci.isNotEmpty ? initialUci : null,
      );
    } catch (_) {
      return null;
    }
  }

  /// Extrae la primera línea forzada de un árbol de líneas de BlitzTactics.
  /// Las hojas se marcan con el string `"win"`.
  List<String> _extractBlitzLine(Map<String, dynamic> lines) {
    final result = <String>[];
    var current = lines;
    while (current.isNotEmpty) {
      final entry = current.entries.first;
      result.add(entry.key);
      final value = entry.value;
      if (value is String) break;
      if (value is Map<String, dynamic>) {
        current = value;
      } else {
        break;
      }
    }
    return result;
  }
}
