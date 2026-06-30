# Changelog

## 0.1.0

- Initial release.
- `RubiksCubeState` — 3x3 cube model: 12 outer + 6 slice moves, scrambling,
  solved-state detection, deep copy, JSON (de)serialisation and per-sticker
  painting.
- `CubeController` + `Cube` — interactive 3D widget with orbit, tap-to-select,
  and finger-following drag-to-turn (snaps to the nearest quarter-turn), plus
  queued/animated moves and `playSequence`.
- `CubeColorValidator` — validates whether a colouring is a real, solvable cube.
