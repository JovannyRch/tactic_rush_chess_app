import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../model/rush_mode.dart';

extension RushModeL10n on RushMode {
  String label(AppLocalizations l10n) => switch (this) {
        RushMode.survival => l10n.modeSurvivalLabel,
        RushMode.threeMinutes => l10n.modeThreeMinutesLabel,
        RushMode.fiveMinutes => l10n.modeFiveMinutesLabel,
      };

  String description(AppLocalizations l10n) => switch (this) {
        RushMode.survival => l10n.modeSurvivalDescription,
        RushMode.threeMinutes => l10n.modeThreeMinutesDescription,
        RushMode.fiveMinutes => l10n.modeFiveMinutesDescription,
      };

  IconData get icon => switch (this) {
        RushMode.survival => Icons.favorite_rounded,
        RushMode.threeMinutes => Icons.timer_outlined,
        RushMode.fiveMinutes => Icons.timer_rounded,
      };
}
