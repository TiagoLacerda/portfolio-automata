import 'grid.dart';

extension Bresenham on IGrid {
  void bresenham(int i0, int j0, int i1, int j1, bool value) {
    var x0 = i0;
    var y0 = j0;
    final x1 = i1;
    final y1 = j1;

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
