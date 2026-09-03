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

  bool running = false;

  late final Timer timer;

  final game = Automaton();

  HomeController() {
    timer = Timer.periodic(
      Duration(milliseconds: (1000 / 20).toInt()),
      (_) {
        if (running) {
          update();
        }
      },
    );
  }

  void step() {
    running = false;
    game.update();
    notifyListeners();
  }

  void toggle() {
    running = !running;
    notifyListeners();
  }

  void update() {
    game.update();
    notifyListeners();
  }
}
