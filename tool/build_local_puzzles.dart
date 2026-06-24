// Genera un bundle de puzzles tácticos GARANTIZADAMENTE correctos sin red.
//
// Estrategia: partidas aleatorias sesgadas hacia jaques/capturas (para alcanzar
// posiciones tácticas) y, en cada posición, búsqueda de mate forzado:
//   - mate en 1: existe una jugada que da mate.
//   - mate en 2: existe una jugada tal que, para TODA respuesta del rival,
//     hay mate en 1 (mate forzado real). Se guarda una sola línea representativa,
//     igual que hace lichess.
//
// Cada puzzle resultante es sólido por construcción. Salida con el mismo modelo
// que el origen remoto (assets/puzzles/sample_puzzles.json):
//   { id, fen, moves:[jugador, rival, jugador...], rating, themes }
//
// Uso:  dart run tool/build_local_puzzles.dart [semilla] [mate1] [mate2]

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dartchess/dartchess.dart' hide File;

void main(List<String> args) {
  final seed = args.isNotEmpty ? int.tryParse(args[0]) ?? 7 : 7;
  final wantMate1 = args.length > 1 ? int.tryParse(args[1]) ?? 16 : 16;
  final wantMate2 = args.length > 2 ? int.tryParse(args[2]) ?? 10 : 10;
  final rng = Random(seed);

  final out = <Map<String, dynamic>>[];
  final seenFen = <String>{};
  var mate1 = 0, mate2 = 0;
  var attempts = 0;
  const maxAttempts = 400000;

  while ((mate1 < wantMate1 || mate2 < wantMate2) && attempts < maxAttempts) {
    attempts++;
    final pos = _randomPosition(rng);
    if (pos == null || pos.isGameOver) continue;
    final fen = pos.fen;
    if (seenFen.contains(fen)) continue;

    // Mate en 1 (barato): se intenta siempre.
    if (mate1 < wantMate1) {
      final m = _mateInOne(pos);
      if (m != null) {
        seenFen.add(fen);
        out.add(_puzzle(pos, [m], 1));
        mate1++;
        stdout.writeln('  mate1 [$mate1/$wantMate1] ${pos.fen}  (${m.uci})');
        continue;
      }
    }

    // Mate en 2 (caro): solo en finales (<= 12 piezas) para acotar el coste.
    if (mate2 < wantMate2 && pos.board.occupied.size <= 12) {
      final line = _mateInTwo(pos, rng);
      if (line != null) {
        seenFen.add(fen);
        out.add(_puzzle(pos, line, 2));
        mate2++;
        stdout.writeln(
            '  mate2 [$mate2/$wantMate2] ${pos.fen}  (${line.map((m) => m.uci).join(" ")})');
      }
    }
  }

  out.sort((a, b) => (a['rating'] as int).compareTo(b['rating'] as int));

  final file = File('assets/puzzles/sample_puzzles.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(out));
  stdout.writeln(
      '\n✓ ${out.length} puzzles ($mate1 mate-en-1, $mate2 mate-en-2) en $attempts intentos → ${file.path}');
}

// ---------------------------------------------------------------------------
// Generación de posiciones
// ---------------------------------------------------------------------------

/// Reproduce una partida aleatoria sesgada hacia jaques y capturas para
/// alcanzar posiciones con mayor densidad de mates.
Position? _randomPosition(Random rng) {
  Position pos = Chess.initial;
  final steps = 8 + rng.nextInt(50);
  for (var i = 0; i < steps; i++) {
    if (pos.isGameOver) return null;
    final moves = _legalMoves(pos);
    if (moves.isEmpty) return null;

    // Sesgo: con prob. 0.65 elegir entre jugadas "agresivas" (jaque/captura).
    final aggressive = <NormalMove>[];
    for (final m in moves) {
      final capture = pos.board.pieceAt(m.to) != null;
      if (capture || pos.play(m).isCheck) aggressive.add(m);
    }
    final pool = (aggressive.isNotEmpty && rng.nextDouble() < 0.65)
        ? aggressive
        : moves;
    pos = pos.play(pool[rng.nextInt(pool.length)]);
  }
  return pos;
}

/// Todas las jugadas legales como [NormalMove], expandiendo promociones.
List<NormalMove> _legalMoves(Position pos) {
  final result = <NormalMove>[];
  for (final entry in pos.legalMoves.entries) {
    final from = entry.key;
    final isPawn = pos.board.roleAt(from) == Role.pawn;
    for (final to in entry.value.squares) {
      final promoting = isPawn &&
          (to.rank == Rank.eighth || to.rank == Rank.first);
      if (promoting) {
        for (final r in const [
          Role.queen,
          Role.knight,
          Role.rook,
          Role.bishop
        ]) {
          result.add(NormalMove(from: from, to: to, promotion: r));
        }
      } else {
        result.add(NormalMove(from: from, to: to));
      }
    }
  }
  return result;
}

// ---------------------------------------------------------------------------
// Búsqueda de mate
// ---------------------------------------------------------------------------

NormalMove? _mateInOne(Position pos) {
  for (final m in _legalMoves(pos)) {
    if (pos.play(m).isCheckmate) return m;
  }
  return null;
}

/// Devuelve [m1, respuestaRival, m3] si [pos] es mate forzado en 2; si no, null.
List<NormalMove>? _mateInTwo(Position pos, Random rng) {
  final candidates = _legalMoves(pos)..shuffle(rng);
  for (final m1 in candidates) {
    final p2 = pos.play(m1);
    if (p2.isGameOver) continue; // mate en 1 o tablas: no es lo que buscamos
    final replies = _legalMoves(p2);
    if (replies.isEmpty) continue;

    var forced = true;
    for (final r in replies) {
      if (_mateInOne(p2.play(r)) == null) {
        forced = false;
        break;
      }
    }
    if (!forced) continue;

    // Línea representativa: la primera respuesta y su mate.
    final reply = replies.first;
    final m3 = _mateInOne(p2.play(reply))!;
    return [m1, reply, m3];
  }
  return null;
}

// ---------------------------------------------------------------------------
// Serialización
// ---------------------------------------------------------------------------

Map<String, dynamic> _puzzle(Position pos, List<NormalMove> line, int mateIn) {
  final pieces = pos.board.occupied.size;
  // Rating sintético: el mate en 2 y las posiciones con más material son más
  // difíciles. Bandas aproximadas al estilo de lichess.
  final base = mateIn == 1 ? 750 : 1450;
  final rating = base + (pieces * 12) + line.length * 10;
  final id = 'gen_${pos.fen.hashCode.toUnsigned(32).toRadixString(16)}';
  return {
    'id': id,
    'fen': pos.fen,
    'moves': line.map((m) => m.uci).toList(),
    'rating': rating,
    'themes': [mateIn == 1 ? 'mateIn1' : 'mateIn2'],
  };
}
