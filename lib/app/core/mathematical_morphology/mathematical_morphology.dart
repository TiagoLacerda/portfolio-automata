import '../grid/grid.dart';

typedef GridBounds = ({
  int minI,
  int minJ,
  int maxI,
  int maxJ,
});

abstract final class MathematicalMorphology {
  static GridBounds? boundingBox(Grid grid) {
    int? minI;
    int? minJ;
    int? maxI;
    int? maxJ;

    for (final (i, j, _) in grid.nonZeroCells) {
      minI = minI == null
          ? i
          : i < minI
          ? i
          : minI;
      minJ = minJ == null
          ? j
          : j < minJ
          ? j
          : minJ;
      maxI = maxI == null
          ? i
          : i > maxI
          ? i
          : maxI;
      maxJ = maxJ == null
          ? j
          : j > maxJ
          ? j
          : maxJ;
    }

    if (minI == null) {
      return null;
    }

    return (
      minI: minI,
      minJ: minJ!,
      maxI: maxI!,
      maxJ: maxJ!,
    );
  }

  static Grid<T> complement<T extends num>(Grid<T> grid) {
    final bounds = boundingBox(grid);

    if (bounds == null) {
      return Grid<T>(chunkSize: grid.chunkSize);
    }

    final result = Grid<T>(chunkSize: grid.chunkSize);

    for (var i = bounds.minI; i <= bounds.maxI; i++) {
      for (var j = bounds.minJ; j <= bounds.maxJ; j++) {
        result.set(
          i,
          j,
          grid.get(i, j) == 0 ? 1 as T : 0 as T,
        );
      }
    }

    return result;
  }

  static Grid<T> translation<T extends num>(
    Grid<T> grid,
    int di,
    int dj,
  ) {
    final result = Grid<T>(chunkSize: grid.chunkSize);

    for (final (i, j, value) in grid.nonZeroCells) {
      result.set(i + di, j + dj, value);
    }

    return result;
  }

  static Grid<T> dilation<T extends num>(
    Grid<T> grid,
    Grid<num> structuringElement,
  ) {
    final result = Grid<T>(chunkSize: grid.chunkSize);

    for (final (i, j, value) in grid.nonZeroCells) {
      for (final (si, sj, _) in structuringElement.nonZeroCells) {
        result.set(
          i + si,
          j + sj,
          value,
        );
      }
    }

    return result;
  }
}
