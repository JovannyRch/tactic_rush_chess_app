// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Tactic Rush';

  @override
  String get homeSubtitle => 'Resuelve tantos puzzles como puedas.';

  @override
  String get homeAttribution =>
      'Puzzles de lichess (CC0) · tablero y lógica con chessground + dartchess';

  @override
  String get record => 'récord';

  @override
  String get hudSolved => 'RESUELTOS';

  @override
  String get hudTime => 'TIEMPO';

  @override
  String get modeSurvivalLabel => 'Supervivencia';

  @override
  String get modeThreeMinutesLabel => '3 minutos';

  @override
  String get modeFiveMinutesLabel => '5 minutos';

  @override
  String get modeSurvivalDescription =>
      'Dificultad creciente · 3 fallos y fuera';

  @override
  String get modeThreeMinutesDescription => 'Máximos puzzles en 3:00';

  @override
  String get modeFiveMinutesDescription => 'Máximos puzzles en 5:00';

  @override
  String get quitTitle => '¿Salir de la partida?';

  @override
  String get quitBody => 'Se perderá el progreso actual.';

  @override
  String get quitCancel => 'Seguir';

  @override
  String get quitConfirm => 'Salir';

  @override
  String get feedbackCorrect => '¡Correcto!';

  @override
  String get feedbackWrong => 'Fallo';

  @override
  String get comboGreat => '¡GENIAL!';

  @override
  String get comboPerfect => '¡PERFECTO!';

  @override
  String comboCount(int count) {
    return 'COMBO x$count';
  }

  @override
  String get turnWhite => 'Juegan blancas · encuentra la mejor jugada';

  @override
  String get turnBlack => 'Juegan negras · encuentra la mejor jugada';

  @override
  String get turnReplying => 'Respondiendo…';

  @override
  String get resultNewRecord => '¡Nuevo récord!';

  @override
  String get resultGameOver => 'Fin de la partida';

  @override
  String get resultPuzzlesSolved => 'puzzles resueltos';

  @override
  String get resultPlayAgain => 'Jugar de nuevo';

  @override
  String get resultHome => 'Inicio';
}
