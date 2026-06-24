import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tactic_rush_chess_app/src/data/puzzle_repository.dart';

void main() {
  const sampleBlitz = {
    'id': 'hZbhy',
    'fen': '6k1/1p1N3p/1p4p1/2bP1p2/3r4/6P1/P4P1P/2R2K2 b - - 2 33',
    'lines': {
      'd7f6': {
        'g8f7': {'f6d5': 'win'},
      },
    },
    'initialMove': {'uci': 'd4d5'},
    'rating': 651,
  };

  test('parsea un puzzle de BlitzTactics', () {
    final repo = PuzzleRepository(client: MockClient((_) async => throw Exception('no network')));
    final puzzle = repo.parseBlitzPuzzleForTest(sampleBlitz);
    expect(puzzle, isNotNull);
    expect(puzzle!.id, 'blitz_hZbhy');
    expect(puzzle.rating, 651);
    expect(puzzle.moves, ['d7f6', 'g8f7', 'f6d5']);
  });
}
