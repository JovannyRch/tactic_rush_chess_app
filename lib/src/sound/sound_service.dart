import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Feedback de audio/háptico, al estilo de lichess.
///
/// Reproduce los efectos de sonido (originados en el proyecto `mathrush`)
/// empaquetados en `assets/sounds/`. Las jugadas usan un click de sistema +
/// vibración (no hay sample de "mover"); los eventos relevantes (acierto,
/// fallo, cuenta atrás, resultado) usan los samples mp3.
///
/// Toda reproducción es tolerante a fallos y desactivable con [enabled]
/// (útil en tests para no tocar canales de plataforma).
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  bool enabled = true;

  // Un reproductor para SFX cortos (acierto/fallo) y otro para los más largos
  // (cuenta atrás / resultado), para que no se interrumpan entre sí.
  AudioPlayer? _sfx;
  AudioPlayer? _aux;

  AudioPlayer _ensure(AudioPlayer? p) =>
      p ?? (AudioPlayer()..setReleaseMode(ReleaseMode.stop));

  Future<void> _play(bool aux, String asset, {double volume = 1.0}) async {
    if (!enabled) return;
    try {
      if (aux) {
        _aux = _ensure(_aux);
        await _aux!.stop();
        await _aux!.play(AssetSource(asset), volume: volume);
      } else {
        _sfx = _ensure(_sfx);
        await _sfx!.stop();
        await _sfx!.play(AssetSource(asset), volume: volume);
      }
    } catch (_) {
      // Sin plataforma de audio (p. ej. en tests): ignorar.
    }
  }

  /// Sonido de movimiento o captura de pieza.
  void move({bool capture = false}) {
    if (!enabled) return;
    HapticFeedback.selectionClick();
    _play(false, capture ? 'sounds/capture.mp3' : 'sounds/move.mp3');
  }

  /// Puzzle resuelto.
  void success() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
    _play(false, 'sounds/correct.mp3');
  }

  /// Jugada incorrecta / fallo.
  void error() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
    _play(false, 'sounds/incorrect.mp3');
  }

  /// Aviso de cuenta atrás en los últimos segundos (modos por tiempo).
  void countdown() => _play(true, 'sounds/countdown.mp3', volume: 0.7);

  /// Sonido de poco tiempo restante.
  void lowTime() => _play(true, 'sounds/low_time.mp3', volume: 0.8);

  /// Sonido de la pantalla final según la puntuación obtenida.
  void result(int score) {
    final asset = score >= 15
        ? 'sounds/result_good.mp3'
        : score >= 5
            ? 'sounds/result_normal.mp3'
            : 'sounds/result_bad.mp3';
    _play(true, asset);
  }

  void dispose() {
    _sfx?.dispose();
    _aux?.dispose();
    _sfx = _aux = null;
  }
}
