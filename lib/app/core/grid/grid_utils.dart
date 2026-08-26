import 'grid.dart';

typedef GridBounds = ({
  int minI,
  int minJ,
  int maxI,
  int maxJ,
});

abstract final class GridUtils {
  static GridBounds? boundingBox(Grid grid) {
    int? minI;
    int? minJ;
    int? maxI;
    int? maxJ;

    for (final (i, j, _) in grid.nonDefaultCells) {
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
}
