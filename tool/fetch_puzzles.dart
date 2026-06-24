// Herramienta de línea de comandos para construir el bundle de puzzles de arranque.
//
// Descarga puzzles reales del endpoint público de lichess (`/api/puzzle/next`),
// reconstruye la FEN jugando el PGN con dartchess, NORMALIZA cada puzzle al
// modelo de la app y valida que toda la línea de solución sea legal antes de
// guardarla. Solo los puzzles que validan al 100% se escriben al asset.
//
// Modelo de salida (assets/puzzles/sample_puzzles.json):
//   {
//     "id": "abcde",
//     "fen": "<posición que VE el jugador, le toca mover>",
//     "moves": ["<jugador>", "<rival>", "<jugador>", ...],  // alterna, empieza jugador
//     "rating": 1500,
//     "themes": ["mateIn2", ...]
//   }
//
// Uso:  dart run tool/fetch_puzzles.dart [cantidad]
//
// Nota: el endpoint no requiere auth pero conviene no abusar; hay un pequeño
// retardo entre peticiones.

import 'dart:convert';
import 'dart:io';

import 'package:dartchess/dartchess.dart' hide File;

const _endpoint = 'https://lichess.org/api/puzzle/next';

Future<void> main(List<String> args) async {
  final target = args.isNotEmpty ? int.tryParse(args.first) ?? 40 : 40;
  final client = HttpClient();
  final seen = <String>{};
  final out = <Map<String, dynamic>>[];

  var attempts = 0;
  while (out.length < target && attempts < target * 4) {
    attempts++;
    try {
      final raw = await _get(client, _endpoint);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final puzzle = json['puzzle'] as Map<String, dynamic>;
      final game = json['game'] as Map<String, dynamic>;

      final id = puzzle['id'] as String;
      if (seen.contains(id)) continue;
      seen.add(id);

      final normalized = _normalize(
        pgn: game['pgn'] as String,
        solution: (puzzle['solution'] as List).cast<String>(),
        id: id,
        rating: puzzle['rating'] as int,
        themes: (puzzle['themes'] as List).cast<String>(),
      );

      if (normalized != null) {
        out.add(normalized);
        stdout.writeln('  [${out.length}/$target] $id  rating=${puzzle['rating']}');
      } else {
        stderr.writeln('  ✗ descartado (no valida): $id');
      }
    } catch (e) {
      stderr.writeln('  ! error en petición: $e');
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  client.close();

  out.sort((a, b) => (a['rating'] as int).compareTo(b['rating'] as int));

  final file = File('assets/puzzles/sample_puzzles.json');
  await file.parent.create(recursive: true);
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(out));
  stdout.writeln('\n✓ ${out.length} puzzles escritos en ${file.path}');
}

/// Reconstruye la posición jugando todo el PGN y normaliza el puzzle.
///
/// Convención de lichess: tras reproducir el PGN, la primera jugada de la
/// solución la realiza el RIVAL (jugada de preparación). El jugador ve la
/// posición resultante y debe encontrar la respuesta. Aquí aplicamos esa
/// primera jugada y guardamos la posición resultante como `fen`, con `moves`
/// = solución a partir de la 2ª jugada (alterna empezando por el jugador).
Map<String, dynamic>? _normalize({
  required String pgn,
  required List<String> solution,
  required String id,
  required int rating,
  required List<String> themes,
}) {
  if (solution.isEmpty) return null;
  try {
    // 1) Reproducir el PGN desde la posición inicial.
    final parsed = PgnGame.parsePgn(pgn);
    Position pos = Chess.initial;
    for (final node in parsed.moves.mainline()) {
      final move = pos.parseSan(node.san);
      if (move == null) return null; // PGN inválido
      pos = pos.play(move);
    }

    // 2) Aplicar la jugada de preparación del rival (solution[0]).
    final setup = NormalMove.fromUci(solution.first);
    if (!pos.isLegal(setup)) return null;
    pos = pos.play(setup);

    // 3) `pos` es ahora lo que ve el jugador. Validar el resto de la línea.
    final playerLine = solution.sublist(1);
    if (playerLine.isEmpty) return null;
    Position check = pos;
    for (final uci in playerLine) {
      final m = NormalMove.fromUci(uci);
      if (!check.isLegal(m)) return null;
      check = check.play(m);
    }

    return {
      'id': id,
      'fen': pos.fen,
      'moves': playerLine,
      'rating': rating,
      'themes': themes,
    };
  } catch (_) {
    return null;
  }
}

Future<String> _get(HttpClient client, String url) async {
  final req = await client.getUrl(Uri.parse(url));
  req.headers.set('Accept', 'application/json');
  req.headers.set('User-Agent', 'tactic_rush_chess_app/1.0 (bundle builder)');
  final res = await req.close();
  if (res.statusCode != 200) {
    throw HttpException('HTTP ${res.statusCode}');
  }
  return res.transform(utf8.decoder).join();
}
