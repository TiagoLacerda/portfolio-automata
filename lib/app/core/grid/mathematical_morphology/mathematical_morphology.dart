import '../grid.dart';

/// Mathematical Morphology operations over a grid implementation, including:
///
/// - Translation
/// - Binary erosion
/// - Binary dilation
/// - Binary opening
/// - Binary closing
/// - Grayscale erosion
/// - Grayscale dilation
/// - Grayscale opening
/// - Grayscale closing
///
abstract final class MathematicalMorphology {
  static Grid<T> translation<T extends num>(
    Grid<T> grid,
    int di,
    int dj,
  ) {
    final result = Grid<T>(
      chunkSize: grid.chunkSize,
      defaultValue: 0 as T,
    );

    for (final (i, j, value) in grid.nonDefaultCells) {
      result.set(i + di, j + dj, value);
    }

    return result;
  }

  static Grid<T> binaryDilation<T extends num>(
    Grid<T> grid,
    Grid<T> structuringElement,
  ) {
    final result = Grid<T>(
      chunkSize: grid.chunkSize,
      defaultValue: 0 as T,
    );

    for (final (i, j, value) in grid.nonDefaultCells) {
      for (final (si, sj, _) in structuringElement.nonDefaultCells) {
        result.set(
          i + si,
          j + sj,
          value,
        );
      }
    }

    return result;
  }

  static Grid<T> binaryErosion<T extends num>(
    Grid<T> grid,
    Grid<T> structuringElement,
  ) {
    final result = Grid<T>(
      chunkSize: grid.chunkSize,
      defaultValue: 0 as T,
    );

    for (final (i, j, value) in grid.nonDefaultCells) {
      var fits = true;

      for (final (si, sj, _) in structuringElement.nonDefaultCells) {
        final ni = i + si;
        final nj = j + sj;

        if (grid.get(ni, nj) == 0) {
          fits = false;
          break;
        }
      }

      if (fits) {
        result.set(i, j, value);
      }
    }

    return result;
  }

  static Grid<T> binaryOpening<T extends num>(
    Grid<T> grid,
    Grid<T> structuringElement,
  ) {
    return binaryDilation(
      binaryErosion(grid, structuringElement),
      structuringElement,
    );
  }

  static Grid<T> binaryClosing<T extends num>(
    Grid<T> grid,
    Grid<T> structuringElement,
  ) {
    return binaryErosion(
      binaryDilation(grid, structuringElement),
      structuringElement,
    );
  }

  static Grid<T> grayscaleDilation<T extends num>(
    Grid<T> grid,
    Grid<T> structuringElement,
  ) {
    final result = Grid<T>(
      chunkSize: grid.chunkSize,
      defaultValue: 0 as T,
    );

    for (final (i, j, _) in grid.nonDefaultCells) {
      T? maxValue;

      for (final (si, sj, seValue) in structuringElement.nonDefaultCells) {
        final ni = i + si;
        final nj = j + sj;

        final gridValue = grid.get(ni, nj);

        if (gridValue == 0) {
          continue;
        }

        final value = (gridValue + seValue) as T;

        if (maxValue == null || value > maxValue) {
          maxValue = value;
        }
      }

      if (maxValue != null) {
        result.set(i, j, maxValue);
      }
    }

    return result;
  }

  static Grid<T> grayscaleErosion<T extends num>(
    Grid<T> grid,
    Grid<T> structuringElement,
  ) {
    final result = Grid<T>(
      chunkSize: grid.chunkSize,
      defaultValue: 0 as T,
    );

    for (final (i, j, _) in grid.nonDefaultCells) {
      T? minValue;

      for (final (si, sj, seValue) in structuringElement.nonDefaultCells) {
        final ni = i + si;
        final nj = j + sj;

        final gridValue = grid.get(ni, nj);

        final value = (gridValue - seValue) as T;

        if (minValue == null || value < minValue) {
          minValue = value;
        }
      }

      if (minValue != null) {
        result.set(i, j, minValue);
      }
    }

    return result;
  }

  static Grid<T> grayscaleOpening<T extends num>(
    Grid<T> grid,
    Grid<T> structuringElement,
  ) {
    return grayscaleDilation(
      grayscaleErosion(grid, structuringElement),
      structuringElement,
    );
  }

  static Grid<T> grayscaleClosing<T extends num>(
    Grid<T> grid,
    Grid<T> structuringElement,
  ) {
    return grayscaleErosion(
      grayscaleDilation(grid, structuringElement),
      structuringElement,
    );
  }
}
