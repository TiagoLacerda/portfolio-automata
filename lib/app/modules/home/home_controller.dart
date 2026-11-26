import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/automata/automaton.dart';
import '../../core/automata/cell_pattern.dart';

final class HomeController with ChangeNotifier {
  final game = Automaton();

  final generation = ValueNotifier<int>(0);

  final targetUPS = 20;

  bool running = false;

  CellPattern? pattern;

  final neighborhoodGridSize = 9;

  final neighborhoodGridCellSize = 20;

  late final initialZoom = neighborhoodGridCellSize.toDouble();

  late final initialOffset = Offset(
    ((neighborhoodGridSize ~/ 2) * neighborhoodGridCellSize).toDouble(),
    ((neighborhoodGridSize ~/ 2) * neighborhoodGridCellSize).toDouble(),
  );

  late final Ticker _ticker = Ticker(_tick);

  Duration _lastElapsed = Duration.zero;

  double _pendingUpdates = 0;

  HomeController() {
    _load(CellPattern.gosperGliderGun);
  }

  @override
  void dispose() {
    _ticker.dispose();
    generation.dispose();
    super.dispose();
  }

  void step() {
    if (running) toggle();

    _update();
  }

  void toggle() {
    running = !running;

    if (running) {
      _lastElapsed = Duration.zero;
      _pendingUpdates = 0;
      _ticker.start();
    } else {
      _ticker.stop();
    }

    notifyListeners();
  }

  ({double zoom, Offset offset}) framing(Size size) {
    final pattern = this.pattern;

    if (pattern == null) return (zoom: 5.0, offset: Offset.zero);

    final zoom = min(size.width / (pattern.width * 4), size.height / (pattern.height * 4)).clamp(1.0, 20.0);

    return (
      zoom: zoom,
      offset: Offset(
        (size.width - pattern.width * zoom) / 2,
        (size.height - pattern.height * zoom) / 2,
      ),
    );
  }

  void clear() {
    game.clear();
    pattern = null;
    generation.value = 0;
    notifyListeners();
  }

  void _load(CellPattern pattern) {
    game.reset();

    for (final cell in pattern.cells) {
      game.set(cell.i, cell.j, true);
    }

    this.pattern = pattern;
    generation.value = 0;

    if (running) {
      notifyListeners();
    } else {
      toggle();
    }
  }

  void _update() {
    game.update();
    generation.value++;
  }

  void _tick(Duration elapsed) {
    _pendingUpdates += (elapsed - _lastElapsed).inMicroseconds * targetUPS / Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;

    if (_pendingUpdates < 1) return;

    _pendingUpdates = min(_pendingUpdates - 1, 1);

    _update();
  }
}
