import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/automata/automaton.dart';

final class HomeController with ChangeNotifier {
  final game = Automaton();

  final generation = ValueNotifier<int>(0);

  final targetUPS = 20;

  bool running = false;

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

  void clear() {
    game.clear();
    generation.value++;
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
