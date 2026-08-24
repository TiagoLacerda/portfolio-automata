import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/automata/automaton.dart';

final class HomeController with ChangeNotifier {
  final neighborhoodGridSize = 9;
  final neighborhoodGridCellSize = 20;
  late final initialZoom = neighborhoodGridCellSize.toDouble();
  late final initialOffset = Offset(
    ((neighborhoodGridSize ~/ 2) * neighborhoodGridCellSize).toDouble(),
    ((neighborhoodGridSize ~/ 2) * neighborhoodGridCellSize).toDouble(),
  );

  bool running = true;

  late final Timer timer;

  final game = Automaton();

  HomeController() {
    timer = Timer.periodic(
      const Duration(milliseconds: 32),
      (_) {
        if (running) {
          update();
        }
      },
    );

    game.neighborhood.set(0, 0, 2);
    game.neighborhood.lock(0, 0);
  }

  void toggle() {
    running = !running;
  }

  void update() {
    game.update();
    notifyListeners();
  }
}
