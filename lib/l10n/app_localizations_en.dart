// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tactic Rush';

  @override
  String get homeSubtitle => 'Solve as many puzzles as you can.';

  @override
  String get homeAttribution =>
      'Puzzles by lichess (CC0) · board & logic with chessground + dartchess';

  @override
  String get record => 'record';

  @override
  String get hudSolved => 'SOLVED';

  @override
  String get hudTime => 'TIME';

  @override
  String get modeSurvivalLabel => 'Survival';

  @override
  String get modeThreeMinutesLabel => '3 minutes';

  @override
  String get modeFiveMinutesLabel => '5 minutes';

  @override
  String get modeSurvivalDescription =>
      'Increasing difficulty · 3 misses and out';

  @override
  String get modeThreeMinutesDescription => 'Max puzzles in 3:00';

  @override
  String get modeFiveMinutesDescription => 'Max puzzles in 5:00';

  @override
  String get quitTitle => 'Quit the game?';

  @override
  String get quitBody => 'Current progress will be lost.';

  @override
  String get quitCancel => 'Continue';

  @override
  String get quitConfirm => 'Quit';

  @override
  String get feedbackCorrect => 'Correct!';

  @override
  String get feedbackWrong => 'Miss';

  @override
  String get comboGreat => 'GREAT!';

  @override
  String get comboPerfect => 'PERFECT!';

  @override
  String comboCount(int count) {
    return '$count COMBO';
  }

  @override
  String get turnWhite => 'White to move · find the best move';

  @override
  String get turnBlack => 'Black to move · find the best move';

  @override
  String get turnReplying => 'Replying…';

  @override
  String get resultNewRecord => 'New record!';

  @override
  String get resultGameOver => 'Game over';

  @override
  String get resultPuzzlesSolved => 'puzzles solved';

  @override
  String get resultPlayAgain => 'Play again';

  @override
  String get resultHome => 'Home';
}
