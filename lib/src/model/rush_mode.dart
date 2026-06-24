enum RushMode {
  survival,
  threeMinutes,
  fiveMinutes;

  Duration? get timeLimit => switch (this) {
        RushMode.survival => null,
        RushMode.threeMinutes => const Duration(minutes: 3),
        RushMode.fiveMinutes => const Duration(minutes: 5),
      };

  int? get maxStrikes => 3;

  bool get isTimed => timeLimit != null;

  String get storageKey => 'best_score_$name';
}
