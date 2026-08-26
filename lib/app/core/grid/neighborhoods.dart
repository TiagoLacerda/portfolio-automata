import 'grid.dart';

class Neighborhoods<T extends num> {
  Grid<T> moore({
    int radius = 1,
  }) {
    assert(radius > 0);

    final grid = Grid<T>(defaultValue: 0 as T);

    for (int i = -radius; i <= radius; ++i) {
      for (int j = -radius; j <= radius; ++j) {
        grid.set(i, j, 1 as T);
      }
    }

    grid.set(0, 0, 0 as T);

    return grid;
  }

  Grid<T> vonNeumann({
    int radius = 1,
  }) {
    assert(radius > 0);

    final grid = Grid<T>(defaultValue: 0 as T);

    for (int i = -radius; i <= radius; ++i) {
      for (int j = -radius; j <= radius; ++j) {
        if (i.abs() + j.abs() > radius) continue;

        grid.set(i, j, 1 as T);
      }
    }

    grid.set(0, 0, 0 as T);

    return grid;
  }
}
