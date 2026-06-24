# Tactic Rush ♟️⚡

App open source de resolución de puzzles de ajedrez al estilo **Puzzle Rush**
de chess.com, construida sobre los componentes open source de **lichess**.

En lugar de copiar código del repo móvil de lichess, la app usa los paquetes
oficiales que lichess publica en pub.dev (que *son* su tablero y su lógica):

| Pieza | Paquete | Origen |
|---|---|---|
| Tablero, arrastre, animaciones, temas, sets de piezas | [`chessground`](https://pub.dev/packages/chessground) | lichess-org |
| Lógica de ajedrez (movimientos legales, FEN, PGN, mate) | [`dartchess`](https://pub.dev/packages/dartchess) | lichess-org |
| Puzzles | Base de datos pública CC0 + API de lichess | lichess.org |
| Estado / arquitectura | [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) | (como la app de lichess) |

## Modos de juego

- **Supervivencia** — dificultad creciente; 3 fallos y termina (Puzzle Rush clásico).
- **3 minutos** / **5 minutos** — máximos puzzles posibles antes de que se agote el tiempo.

El récord de cada modo se guarda localmente con `shared_preferences`.

## Arquitectura

```
lib/
  main.dart                     ProviderScope + app
  src/
    app.dart                    MaterialApp, tema, navegación
    theme/app_theme.dart        tema oscuro con acentos verdes
    model/
      puzzle.dart               modelo normalizado de puzzle
      rush_mode.dart            modos (survival / 3min / 5min)
    data/
      puzzle_repository.dart     fuente HÍBRIDA: bundle local (offline) + API lichess
      score_storage.dart        récords con shared_preferences
    logic/
      chess_bridge.dart         puente dartchess <-> chessground (tipos homónimos)
    rush/
      rush_state.dart           estado inmutable de la sesión
      rush_controller.dart      bucle de juego (Riverpod Notifier)
    sound/sound_service.dart    feedback de audio (audioplayers) + háptico
    ui/
      home_screen.dart          selección de modo + récords
      rush_screen.dart          tablero + HUD + feedback
      result_screen.dart        marcador final
      widgets/rush_hud.dart     puntuación, vidas, cronómetro
assets/puzzles/sample_puzzles.json   bundle de arranque (offline)
assets/sounds/                       efectos de sonido (mp3)
tool/
  build_local_puzzles.dart      genera puzzles de mate forzado verificados (sin red)
  fetch_puzzles.dart            descarga puzzles reales de la API de lichess
```

### Modelo de puzzle

Cada puzzle se normaliza a: `fen` = posición que **ve el jugador** (la jugada de
preparación del rival ya aplicada), y `moves` = línea de solución en UCI que
**alterna empezando por el jugador** (índices pares = jugador, impares = rival).
El controlador valida la jugada del jugador contra la línea, reproduce
automáticamente la respuesta del rival, y acepta también mates alternativos.

## Cómo ejecutar

```bash
flutter pub get
flutter run
```

## Puzzles

El bundle `assets/puzzles/sample_puzzles.json` se incluye listo para usar
(funciona **offline**). Cuando hay red, el repositorio amplía el repertorio con
la API pública de lichess de forma transparente (si falla la red, degrada al
bundle local sin interrumpir la partida).

Regenerar el bundle local (mates forzados garantizados, sin red):

```bash
dart run tool/build_local_puzzles.dart <semilla> <nº mate-en-1> <nº mate-en-2>
# ej: dart run tool/build_local_puzzles.dart 7 45 30
```

Descargar puzzles reales de la API de lichess (requiere red):

```bash
dart run tool/fetch_puzzles.dart 40
```

## Tests

```bash
flutter test
```

Cubren: validez del bundle (toda solución es legal y termina en mate), el bucle
de resolución del controlador (acierto suma, fallo resta vida) y el render del
tablero.

## Sonido

Efectos en `assets/sounds/` (mp3), reproducidos con `audioplayers`:

| Evento | Sample |
|---|---|
| Puzzle resuelto | `correct.mp3` |
| Fallo | `incorrect.mp3` |
| Cuenta atrás (a 10 s del final en modos por tiempo) | `countdown.mp3` |
| Resultado final (según puntuación) | `result_{good,normal,bad}.mp3` |

Las jugadas usan click de sistema + vibración. Todo el audio se puede
desactivar con `SoundService.instance.enabled = false`.

## Licencias y atribución

- `chessground` y `dartchess`: GPL-3.0 (lichess-org).
- Puzzles de lichess: dominio público (**CC0**).
- Efectos de sonido: tomados del proyecto [mathrush](https://gitlab.com/jovannyrch/mathrush).
- Este proyecto es open source. Al usar dependencias GPL, distribúyelo de forma
  compatible con GPL-3.0.
