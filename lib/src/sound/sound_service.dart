import 'package:flutter/services.dart';

/// Feedback de audio/háptico para las jugadas, al estilo de lichess.
///
/// Por defecto usa sonidos del sistema + vibración (cero assets, funciona de
/// inmediato). Si en el futuro añades archivos de sonido propios a
/// `assets/sounds/`, este es el único punto a cambiar: mantén la misma API
/// pública ([move], [success], [error]) y reproduce los assets con audioplayers.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool enabled = true;

  void move({bool capture = false}) {
    if (!enabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  void success() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  void error() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }
}
