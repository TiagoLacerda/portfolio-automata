import '../grid/grid.dart';

abstract interface class IAutomaton {
  IGrid get world;
  IGrid get neighborhood;

  int get survivalMin;
  set survivalMin(int value);
  int get survivalMax;
  set survivalMax(int value);
  int get birthMin;
  set birthMin(int value);
  int get birthMax;
  set birthMax(int value);

  bool get(int i, int j);
  void set(int i, int j, bool value);
  void clear();

  void update();
}

final class Automaton implements IAutomaton {
  UInt32Grid _world;

  int _survivalMin = 2;
  int _survivalMax = 3;
  int _birthMin = 3;
  int _birthMax = 3;

  Automaton() : _world = UInt32Grid(), neighborhood = UInt32Grid() {
    for (int i = -1; i <= 1; ++i) {
      for (int j = -1; j <= 1; ++j) {
        neighborhood.set(i, j, true);
      }
    }

    neighborhood.lock(0, 0);
  }

  @override
  UInt32Grid get world => _world;

  @override
  final UInt32Grid neighborhood;

  @override
  int get survivalMin => _survivalMin;

  @override
  set survivalMin(int value) => _survivalMin = value.clamp(0, _survivalMax);

  @override
  int get survivalMax => _survivalMax;

  @override
  set survivalMax(int value) => _survivalMax = value < _survivalMin ? _survivalMin : value;

  @override
  int get birthMin => _birthMin;

  @override
  set birthMin(int value) => _birthMin = value.clamp(0, _birthMax);

  @override
  int get birthMax => _birthMax;

  @override
  set birthMax(int value) => _birthMax = value < _birthMin ? _birthMin : value;

  @override
  bool get(int i, int j) => _world.get(i, j);

  @override
  void set(int i, int j, bool value) => _world.set(i, j, value);

  @override
  void clear() => _world.clear();

  @override
  void update() {
    final next = UInt32Grid();

    final Set<(int, int)> candidatesToBeBorn = {};

    final offsets = [
      for (final delta in neighborhood.nonZeroPositions)
        if (delta.i != 0 || delta.j != 0) delta,
    ];

    for (final position in _world.nonZeroPositions) {
      int neighborsAlive = 0;

      for (final delta in offsets) {
        final ni = position.i + delta.i;
        final nj = position.j + delta.j;

        final neighbor = _world.get(ni, nj);

        if (neighbor) {
          neighborsAlive += 1;
        } else {
          candidatesToBeBorn.add((ni, nj));
        }
      }

      final survives = neighborsAlive >= _survivalMin && neighborsAlive <= _survivalMax;

      if (survives) {
        next.set(position.i, position.j, true);
      }
    }

    for (final (i, j) in candidatesToBeBorn) {
      int neighborsAlive = 0;

      for (final delta in offsets) {
        final ni = i + delta.i;
        final nj = j + delta.j;

        final neighbor = _world.get(ni, nj);

        if (neighbor) {
          neighborsAlive += 1;
        }
      }

      final born = neighborsAlive >= _birthMin && neighborsAlive <= _birthMax;

      if (born) {
        next.set(i, j, true);
      }
    }

    _world = next;
  }
}
