import 'package:flutter/material.dart';
import 'package:puzzle_cube/puzzle_cube.dart';

void main() => runApp(const PuzzleCubeExampleApp());

/// Demo app showing the interactive [Cube] widget.
class PuzzleCubeExampleApp extends StatelessWidget {
  /// Creates the example app.
  const PuzzleCubeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'puzzle_cube',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final CubeController _controller = CubeController(
    initialViewRotationX: -0.5,
    initialViewRotationY: 0.6,
  );

  CubeMove? _lastMove;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  String get _statusText {
    if (_controller.isSolved) return 'Solved 🎉';
    if (_lastMove == null) return 'Drag a layer to turn it';
    return 'Last move: ${_lastMove!.name.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('puzzle_cube'),
        actions: [
          IconButton(
            tooltip: 'Recenter',
            onPressed: _controller.resetCamera,
            icon: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              _statusText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: Cube(
                    controller: _controller,
                    onMove: (move) {
                      _controller.applyMoveInstant(move);
                      setState(() => _lastMove = move);
                    },
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _MoveRow(controller: _controller),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => _controller.scramble(),
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Scramble'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            _controller.reset();
                            setState(() => _lastMove = null);
                          },
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _controller.playSequence(const [
                      CubeMove.r,
                      CubeMove.u,
                      CubeMove.ri,
                      CubeMove.ui,
                    ]),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Play sexy move (R U R' U')"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoveRow extends StatelessWidget {
  const _MoveRow({required this.controller});

  final CubeController controller;

  static const _moves = <(String, CubeMove)>[
    ('U', CubeMove.u),
    ('D', CubeMove.d),
    ('L', CubeMove.l),
    ('R', CubeMove.r),
    ('F', CubeMove.f),
    ('B', CubeMove.b),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final (label, move) in _moves) ...[
          _key(label, move),
          _key("$label'", move.inverse),
        ],
      ],
    );
  }

  Widget _key(String label, CubeMove move) {
    return SizedBox(
      width: 44,
      child: ElevatedButton(
        onPressed: () => controller.play(move),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(label),
      ),
    );
  }
}
