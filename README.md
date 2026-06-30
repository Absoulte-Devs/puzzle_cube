# puzzle_cube

An interactive 3D twisty-puzzle cube for Flutter. It bundles a pure-Dart 3x3
cube model (layer turns, scrambling, validation, JSON, solved-state detection)
with a gesture-driven widget that renders the cube in 3D and lets you orbit it,
tap its faces, and **turn layers by dragging** them with your finger.

The 3D rendering is built on [`ditredi`](https://pub.dev/packages/ditredi).

## Features

- `RubiksCubeState` — a 3x3 cube model of 27 cubies.
  - All 12 outer quarter-turns plus the 3 middle slices (M/E/S), each direction.
  - Reproducible scrambles with a seedable RNG.
  - Solved-state detection, deep copy and JSON (de)serialisation.
  - Per-sticker painting for "colour my cube" flows.
- `CubeController` + `Cube` — an interactive 3D widget.
  - **Orbit** the view by dragging off the cube.
  - **Drag-to-turn**: drag a layer and it follows your finger, snapping to the
    nearest quarter-turn on release.
  - **Tap-to-select** the front-most face under the tap (never falls through to
    the hidden side).
  - Animated, queued moves and `playSequence` for algorithms.
- `CubeColorValidator` — checks whether a colouring could be a real, solvable
  cube (centres fixed, valid edge/corner combinations, nine of each colour).
- `FaceColorScanner` — turns a photo of one face into its 9 sticker colours.

## Getting started

```yaml
dependencies:
  puzzle_cube: ^0.1.0
```

```dart
import 'package:puzzle_cube/puzzle_cube.dart';
```

## Usage

### Interactive widget

```dart
class MyCube extends StatefulWidget {
  const MyCube({super.key});
  @override
  State<MyCube> createState() => _MyCubeState();
}

class _MyCubeState extends State<MyCube> {
  final controller = CubeController(
    initialViewRotationX: -0.5,
    initialViewRotationY: 0.6,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Cube(
        controller: controller,
        // Enable drag-to-turn. Dragging off the cube orbits the view.
        onMove: (move) => debugPrint('turned $move'),
      ),
    );
  }
}
```

Buttons can drive the same controller:

```dart
ElevatedButton(onPressed: () => controller.play(CubeMove.r), child: const Text('R'));
ElevatedButton(onPressed: () => controller.scramble(), child: const Text('Scramble'));
ElevatedButton(onPressed: controller.reset, child: const Text('Reset'));
ElevatedButton(onPressed: controller.resetCamera, child: const Text('Recenter'));
```

Apply an algorithm as an animated sequence:

```dart
controller.playSequence(const [
  CubeMove.r, CubeMove.u, CubeMove.ri, CubeMove.ui,
]);
```

### Pure model (no widget)

```dart
final cube = RubiksCubeState.solved();
cube.applyMove(CubeMove.r);
cube.applyMove(CubeMove.u);
cube.applyMove(CubeMove.r.inverse); // R'
print(cube.isSolved); // false

final scrambled = RubiksCubeState.random(moves: 25, seed: 42);
final json = scrambled.toJson();
final restored = RubiksCubeState.fromJson(json);
```

### Validate a colouring

```dart
const validator = CubeColorValidator();
final result = validator.validate(cube);
if (!result.isValid) {
  for (final issue in result.issues) {
    debugPrint(issue.message);
  }
}
```

### Scan a face from a photo

```dart
const scanner = FaceColorScanner();
final List<Color> stickers = scanner.classify(jpegBytes); // 9, row-major
```

## API reference

| Class / member | Purpose |
| --- | --- |
| `RubiksCubeState.solved()` | A solved cube. |
| `RubiksCubeState.colorless()` | Centres fixed, every other sticker blank. |
| `RubiksCubeState.random({moves, seed})` | Reproducible scramble. |
| `applyMove(CubeMove)` | Apply one quarter-turn in place. |
| `isSolved`, `copy()`, `toJson()`/`fromJson()` | State helpers. |
| `CubeMove` / `.inverse` | 12 outer + 6 slice moves, with inverses. |
| `CubieModel`, `CubieFace` | A single cubie and its six faces. |
| `CubeColors` | The six colours, palette and nearest-colour snapping. |
| `CubeController` | Drives the widget: queue moves, orbit, scramble, paint. |
| `Cube` | The interactive 3D widget (`onMove`, `onFaceTap`). |
| `CubeColorValidator` | Real-cube colour validation. |
| `FaceColorScanner` | Photo → 9 sticker colours. |
| `cubeFaceAtTap`, `cubeDragFor`, `CubeDrag` | Low-level projection helpers. |
| `CubieBuilder` | Builds the DiTreDi geometry for a cubie. |

## Example app

A runnable demo lives in [example/](example/):

```bash
cd example
flutter run
```

## License

MIT. See [LICENSE](LICENSE).
