import 'dart:convert';
import 'dart:io';

import 'package:dartchess/dartchess.dart' hide File;
import 'package:flutter_test/flutter_test.dart';
import 'package:tactic_rush_chess_app/src/model/puzzle.dart';

/// Verifica que TODOS los puzzles del bundle son jugables: la FEN es válida y
/// la línea de solución es legal jugada alternadamente (jugador/rival). Es la
/// red de seguridad contra puzzles corruptos en el asset.
void main() {
  final raw = File('assets/puzzles/sample_puzzles.json').readAsStringSync();
  final puzzles = (jsonDecode(raw) as List)
      .map((e) => Puzzle.fromJson(e as Map<String, dynamic>))
      .toList();

  test('el bundle no está vacío y está ordenado por rating', () {
    expect(puzzles, isNotEmpty);
    for (var i = 1; i < puzzles.length; i++) {
      expect(puzzles[i].rating, greaterThanOrEqualTo(puzzles[i - 1].rating));
    }
  });

  test('cada puzzle tiene FEN válida y solución legal', () {
    for (final p in puzzles) {
      Position pos = Chess.fromSetup(Setup.parseFen(p.fen));
      expect(p.moves, isNotEmpty, reason: '${p.id} sin jugadas');
      for (final uci in p.moves) {
        final move = NormalMove.fromUci(uci);
        expect(pos.isLegal(move), isTrue,
            reason: 'Jugada ilegal $uci en ${p.id} (${pos.fen})');
        pos = pos.play(move);
      }
    }
  });

  test('la última jugada del jugador da jaque mate (puzzles de mate)', () {
    for (final p in puzzles.where((p) => p.themes.contains('mateIn1') ||
        p.themes.contains('mateIn2'))) {
      Position pos = Chess.fromSetup(Setup.parseFen(p.fen));
      for (final uci in p.moves) {
        pos = pos.play(NormalMove.fromUci(uci));
      }
      expect(pos.isCheckmate, isTrue, reason: '${p.id} no termina en mate');
    }
  });
}
