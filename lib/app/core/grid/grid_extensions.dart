import 'grid.dart';

extension GridBresenham<T> on Grid {
  void bresenham(int i, int j, int y, int x, T value) {
    var x0 = i;
    var y0 = j;
    final x1 = y;
    final y1 = x;

    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();

    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;

    var error = dx - dy;

    while (true) {
      set(x0, y0, value);

      if (x0 == x1 && y0 == y1) {
        break;
      }

      final error2 = error * 2;

      if (error2 > -dy) {
        error -= dy;
        x0 += sx;
      }

      if (error2 < dx) {
        error += dx;
        y0 += sy;
      }
    }
  }
}
