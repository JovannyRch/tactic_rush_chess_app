import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart' as dc;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

/// Conversiones entre la lógica de ajedrez (dartchess) y el widget de tablero
/// (chessground). Ambos paquetes definen tipos homónimos (`Side`, `Move`,
/// `Role`...), por eso este archivo los importa con prefijos y centraliza el
/// puente para que el resto de la app no tenga que lidiar con la ambigüedad.

/// Construye la posición de dartchess a partir de una FEN.
dc.Position positionFromFen(String fen) =>
    dc.Chess.fromSetup(dc.Setup.parseFen(fen));

cg.Side toCgSide(dc.Side side) =>
    side == dc.Side.white ? cg.Side.white : cg.Side.black;

/// Mapa de movimientos legales en el formato que espera chessground
/// (`casilla origen -> conjunto de casillas destino`), usado para resaltar
/// destinos válidos al arrastrar una pieza.
cg.ValidMoves legalMovesOf(dc.Position position) {
  final map = <cg.SquareId, ISet<cg.SquareId>>{};
  for (final entry in position.legalMoves.entries) {
    final dests = entry.value.squares.map((s) => s.name).toISet();
    if (dests.isNotEmpty) {
      map[entry.key.name] = dests;
    }
  }
  return map.lock;
}

/// Convierte un movimiento de chessground (basado en strings de casilla) a un
/// [dc.NormalMove] de dartchess.
dc.NormalMove toDartMove(cg.Move move) => dc.NormalMove.fromUci(move.uci);

/// Convierte un UCI a un movimiento de chessground para reproducir la línea.
cg.Move toCgMove(String uci) => cg.Move.fromUci(uci);
