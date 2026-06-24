/// Origen de un puzzle (útil para depuración y métricas).
enum PuzzleSource { local, lichess, blitztactics }

/// Un puzzle táctico normalizado al modelo de la app.
///
/// A diferencia del formato crudo de lichess, aquí [fen] ya es la posición que
/// VE el jugador (la jugada de preparación del rival ya está aplicada) y le
/// toca mover. [moves] es la línea de solución en UCI, alternando y empezando
/// SIEMPRE por el jugador: índices pares = jugador, impares = rival.
class Puzzle {
  const Puzzle({
    required this.id,
    required this.fen,
    required this.moves,
    required this.rating,
    this.themes = const [],
    this.source = PuzzleSource.local,
    this.setupFen,
    this.setupMove,
  });

  final String id;
  final String fen;
  final List<String> moves;
  final int rating;
  final List<String> themes;
  final PuzzleSource source;

  /// FEN de la posición justo antes de la jugada de preparación del rival.
  /// Si existe, la UI puede animar esa jugada antes de dejar jugar al usuario.
  final String? setupFen;

  /// Jugada de preparación del rival (UCI) que lleva a [fen].
  final String? setupMove;

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] as String,
      fen: json['fen'] as String,
      moves: (json['moves'] as List).cast<String>(),
      rating: json['rating'] as int,
      themes:
          (json['themes'] as List?)?.cast<String>() ?? const <String>[],
      source: PuzzleSource.values.byName(
        (json['source'] as String?) ?? 'local',
      ),
      setupFen: json['setupFen'] as String?,
      setupMove: json['setupMove'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fen': fen,
        'moves': moves,
        'rating': rating,
        'themes': themes,
        'source': source.name,
        if (setupFen != null) 'setupFen': setupFen,
        if (setupMove != null) 'setupMove': setupMove,
      };

  /// URL del puzzle en lichess (útil para depurar / abrir en el navegador).
  String get lichessUrl => 'https://lichess.org/training/$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Puzzle && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
