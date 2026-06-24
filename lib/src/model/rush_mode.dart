/// Modos de juego soportados, al estilo de Puzzle Rush de chess.com.
enum RushMode {
  /// Resuelve puzzles de dificultad creciente hasta acumular 3 fallos.
  survival,

  /// Tantos puzzles como sea posible en 3 minutos.
  threeMinutes,

  /// Tantos puzzles como sea posible en 5 minutos.
  fiveMinutes;

  /// Límite de tiempo del modo, o `null` si es por vidas (survival).
  Duration? get timeLimit => switch (this) {
        RushMode.survival => null,
        RushMode.threeMinutes => const Duration(minutes: 3),
        RushMode.fiveMinutes => const Duration(minutes: 5),
      };

  /// Número de fallos permitidos antes de terminar, o `null` si es por tiempo.
  int? get maxStrikes => this == RushMode.survival ? 3 : null;

  bool get isTimed => timeLimit != null;

  String get label => switch (this) {
        RushMode.survival => 'Supervivencia',
        RushMode.threeMinutes => '3 minutos',
        RushMode.fiveMinutes => '5 minutos',
      };

  String get description => switch (this) {
        RushMode.survival => 'Dificultad creciente · 3 fallos y fuera',
        RushMode.threeMinutes => 'Máximos puzzles en 3:00',
        RushMode.fiveMinutes => 'Máximos puzzles en 5:00',
      };

  /// Clave estable para persistir el récord.
  String get storageKey => 'best_score_$name';
}
