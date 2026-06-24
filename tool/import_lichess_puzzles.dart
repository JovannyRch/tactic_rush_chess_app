// Importa una muestra equilibrada de la base CC0 oficial de Lichess.
//
// Uso: dart run tool/import_lichess_puzzles.dart [puzzles_por_banda]
// Ejemplo: 100 por banda * 9 bandas (600-2399) = 900 puzzles.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dartchess/dartchess.dart' hide File;

const _datasetRows =
    'https://datasets-server.huggingface.co/rows'
    '?dataset=Lichess%2Fchess-puzzles&config=default&split=train';
const _bandSize = 200;
const _minRating = 600;
const _bandCount = 9;
const _pageSize = 100;
const _totalRows = 6014381;

Future<void> main(List<String> args) async {
  final perBand = args.isEmpty ? 100 : int.parse(args.first);
  final bands = List.generate(_bandCount, (_) => <Map<String, dynamic>>[]);
  final seen = <String>{};
  final random = Random(432000);
  final client = HttpClient();

  var attempts = 0;
  while (bands.any((band) => band.length < perBand) && attempts < 500) {
    attempts++;
    final offset = random.nextInt(_totalRows - _pageSize);
    final rows = await _fetchRows(client, offset);
    for (final row in rows) {
      final rating = row['Rating'] as int;
      final bandIndex = (rating - _minRating) ~/ _bandSize;
      if (rating < _minRating ||
          bandIndex < 0 ||
          bandIndex >= _bandCount ||
          bands[bandIndex].length >= perBand ||
          (row['Popularity'] as int) < 80 ||
          (row['NbPlays'] as int) < 100 ||
          (row['RatingDeviation'] as int) > 100) {
        continue;
      }

      final puzzle = _normalize(row);
      if (puzzle != null && seen.add(puzzle['id'] as String)) {
        bands[bandIndex].add(puzzle);
      }
    }
    stdout.write(
      '\r${bands.map((band) => band.length).join('/')}'
      '  páginas: $attempts',
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
  client.close();

  if (bands.any((band) => band.length < perBand)) {
    throw StateError(
      'No se completaron todas las bandas: ${bands.map((b) => b.length)}',
    );
  }

  final puzzles = bands.expand((band) => band).toList()
    ..sort((a, b) => (a['rating'] as int).compareTo(b['rating'] as int));
  final file = File('assets/puzzles/sample_puzzles.json');
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(puzzles));
  stdout.writeln('\n${puzzles.length} puzzles escritos en ${file.path}');
}

Future<List<Map<String, dynamic>>> _fetchRows(
  HttpClient client,
  int offset,
) async {
  final uri = Uri.parse('$_datasetRows&offset=$offset&length=$_pageSize');
  for (var attempt = 0; attempt < 5; attempt++) {
    final request = await client.getUrl(uri);
    request.headers.set('Accept', 'application/json');
    request.headers.set('User-Agent', 'tactic-rush-chess-app/1.0');
    final response = await request.close();
    if (response.statusCode == HttpStatus.tooManyRequests) {
      await response.drain<void>();
      await Future<void>.delayed(Duration(seconds: 5 * (attempt + 1)));
      continue;
    }
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode}', uri: uri);
    }
    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    return (json['rows'] as List)
        .map((entry) => (entry as Map<String, dynamic>)['row'])
        .cast<Map<String, dynamic>>()
        .toList();
  }
  throw HttpException('HTTP 429 tras varios reintentos', uri: uri);
}

Map<String, dynamic>? _normalize(Map<String, dynamic> row) {
  try {
    Position position = Chess.fromSetup(Setup.parseFen(row['FEN'] as String));
    final moves = (row['Moves'] as String).split(' ');
    if (moves.length < 2) return null;

    final setup = NormalMove.fromUci(moves.first);
    if (!position.isLegal(setup)) return null;
    position = position.play(setup);

    final playerLine = moves.sublist(1);
    Position check = position;
    for (final uci in playerLine) {
      final move = NormalMove.fromUci(uci);
      if (!check.isLegal(move)) return null;
      check = check.play(move);
    }

    return {
      'id': row['PuzzleId'],
      'fen': position.fen,
      'moves': playerLine,
      'rating': row['Rating'],
      'themes': row['Themes'],
    };
  } catch (_) {
    return null;
  }
}
