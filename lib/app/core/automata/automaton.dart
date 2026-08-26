import '../grid/grid.dart';
import '../grid/grid_extensions.dart';
import '../grid/neighborhoods.dart';

class Automaton {
  Grid<int> grid;

  final Grid<int> neighborhood;

  final (int, int) stable = (2, 3);
  final (int, int) birth = (3, 3);

  Automaton({Grid<int>? neighborhood})
    : grid = Grid<int>(defaultValue: 0),
      neighborhood = neighborhood ?? Neighborhoods<int>().moore();

  int get(int i, int j) => grid.get(i, j);

  void set(int i, int j, int value) {
    grid.set(i, j, value);
  }

  void clear() => grid.clear();

  void update() {
    final next = Grid<int>(defaultValue: grid.defaultValue);

    final Set<(int, int)> candidatesToBeBorn = {};

    // Count neighbors around every live cell.
    for (final (i, j, _) in grid.nonDefaultCells) {
      int neighborsAlive = 0;

      for (final (di, dj, _) in neighborhood.nonDefaultCells) {
        if (di == 0 && dj == 0) continue;

        final ni = i + di;
        final nj = j + dj;

        final neighbor = grid.get(ni, nj);

        if (neighbor == 0) {
          candidatesToBeBorn.add((ni, nj));
        } else {
          neighborsAlive += 1;
        }
      }

      final survives = neighborsAlive >= stable.$1 && neighborsAlive <= stable.$2;

      if (survives) {
        next.set(i, j, 1);
      }
    }

    for (final (i, j) in candidatesToBeBorn) {
      int neighborsAlive = 0;

      for (final (di, dj, _) in neighborhood.nonDefaultCells) {
        if (di == 0 && dj == 0) continue;

        final ni = i + di;
        final nj = j + dj;

        final neighbor = grid.get(ni, nj);

        if (neighbor != 0) {
          neighborsAlive += 1;
        }
      }

      final born = neighborsAlive >= birth.$1 && neighborsAlive <= birth.$2;

      if (born) {
        next.set(i, j, 1);
      }
    }

    grid = next;
  }

  void bresenham(int i, int j, int y, int x, int value) => grid.bresenham(i, j, y, x, value);
}
