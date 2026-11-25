import 'dart:math';

import '../grid/chunk.dart';

final class CellPattern {
  final List<String> rows;

  CellPattern(this.rows);

  late final int width = rows.fold(0, (width, row) => max(width, row.length));

  int get height => rows.length;

  late final List<Position> cells = [
    for (int j = 0; j < rows.length; ++j)
      for (int i = 0; i < rows[j].length; ++i)
        if (rows[j][i] != '.') (i: i, j: j),
  ];

  static final gosperGliderGun = CellPattern([
    '........................O...........',
    '......................O.O...........',
    '............OO......OO............OO',
    '...........O...O....OO............OO',
    'OO........O.....O...OO..............',
    'OO........O...O.OO....O.O...........',
    '..........O.....O.......O...........',
    '...........O...O....................',
    '............OO......................',
  ]);
}
