import '../grid/grid.dart';

abstract interface class IAutomaton {
  IGrid get world;
  IGrid get neighborhood;

  bool get(int i, int j);
  void set(int i, int j, bool value);
  void clear();

  void update();
}

final class Automaton implements IAutomaton {
  UInt32Grid _world;

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
  bool get(int i, int j) => _world.get(i, j);

  @override
  void set(int i, int j, bool value) => _world.set(i, j, value);

  @override
  void clear() => _world.clear();

  @override
  void update() {
    final next = UInt32Grid();

    final Set<(int, int)> candidatesToBeBorn = {};

    for (final position in _world.nonZeroPositions) {
      int neighborsAlive = 0;

      for (final delta in neighborhood.nonZeroPositions) {
        if (delta.i == 0 && delta.j == 0) continue;

        final ni = position.i + delta.i;
        final nj = position.j + delta.j;

        final neighbor = _world.get(ni, nj);

        if (neighbor) {
          neighborsAlive += 1;
        } else {
          candidatesToBeBorn.add((ni, nj));
        }
      }

      final survives = neighborsAlive == 2 || neighborsAlive == 3;

      if (survives) {
        next.set(position.i, position.j, true);
      }
    }

    for (final (i, j) in candidatesToBeBorn) {
      int neighborsAlive = 0;

      for (final delta in neighborhood.nonZeroPositions) {
        if (delta.i == 0 && delta.j == 0) continue;

        final ni = i + delta.i;
        final nj = j + delta.j;

        final neighbor = _world.get(ni, nj);

        if (neighbor) {
          neighborsAlive += 1;
        }
      }

      final born = neighborsAlive >= 3 && neighborsAlive <= 3;

      if (born) {
        next.set(i, j, true);
      }
    }

    _world = next;
  }
}
