import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tactic Rush'**
  String get appTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solve as many puzzles as you can.'**
  String get homeSubtitle;

  /// No description provided for @homeAttribution.
  ///
  /// In en, this message translates to:
  /// **'Puzzles by lichess (CC0) · board & logic with chessground + dartchess'**
  String get homeAttribution;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'record'**
  String get record;

  /// No description provided for @hudSolved.
  ///
  /// In en, this message translates to:
  /// **'SOLVED'**
  String get hudSolved;

  /// No description provided for @hudTime.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get hudTime;

  /// No description provided for @modeSurvivalLabel.
  ///
  /// In en, this message translates to:
  /// **'Survival'**
  String get modeSurvivalLabel;

  /// No description provided for @modeThreeMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'3 minutes'**
  String get modeThreeMinutesLabel;

  /// No description provided for @modeFiveMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get modeFiveMinutesLabel;

  /// No description provided for @modeSurvivalDescription.
  ///
  /// In en, this message translates to:
  /// **'Increasing difficulty · 3 misses and out'**
  String get modeSurvivalDescription;

  /// No description provided for @modeThreeMinutesDescription.
  ///
  /// In en, this message translates to:
  /// **'Max puzzles in 3:00'**
  String get modeThreeMinutesDescription;

  /// No description provided for @modeFiveMinutesDescription.
  ///
  /// In en, this message translates to:
  /// **'Max puzzles in 5:00'**
  String get modeFiveMinutesDescription;

  /// No description provided for @quitTitle.
  ///
  /// In en, this message translates to:
  /// **'Quit the game?'**
  String get quitTitle;

  /// No description provided for @quitBody.
  ///
  /// In en, this message translates to:
  /// **'Current progress will be lost.'**
  String get quitBody;

  /// No description provided for @quitCancel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get quitCancel;

  /// No description provided for @quitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quitConfirm;

  /// No description provided for @feedbackCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get feedbackCorrect;

  /// No description provided for @feedbackWrong.
  ///
  /// In en, this message translates to:
  /// **'Miss'**
  String get feedbackWrong;

  /// No description provided for @comboGreat.
  ///
  /// In en, this message translates to:
  /// **'GREAT!'**
  String get comboGreat;

  /// No description provided for @comboPerfect.
  ///
  /// In en, this message translates to:
  /// **'PERFECT!'**
  String get comboPerfect;

  /// No description provided for @comboCount.
  ///
  /// In en, this message translates to:
  /// **'{count} COMBO'**
  String comboCount(int count);

  /// No description provided for @turnWhite.
  ///
  /// In en, this message translates to:
  /// **'White to move · find the best move'**
  String get turnWhite;

  /// No description provided for @turnBlack.
  ///
  /// In en, this message translates to:
  /// **'Black to move · find the best move'**
  String get turnBlack;

  /// No description provided for @turnReplying.
  ///
  /// In en, this message translates to:
  /// **'Replying…'**
  String get turnReplying;

  /// No description provided for @resultNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New record!'**
  String get resultNewRecord;

  /// No description provided for @resultGameOver.
  ///
  /// In en, this message translates to:
  /// **'Game over'**
  String get resultGameOver;

  /// No description provided for @resultPuzzlesSolved.
  ///
  /// In en, this message translates to:
  /// **'puzzles solved'**
  String get resultPuzzlesSolved;

  /// No description provided for @resultPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get resultPlayAgain;

  /// No description provided for @resultHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get resultHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
