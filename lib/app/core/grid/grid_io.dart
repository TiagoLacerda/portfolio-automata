import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import 'grid.dart';

abstract interface class GridIO {
  static Future<Grid<T>?> pick<T extends num>() async {
    final file = await FilePicker.pickFile();

    if (file == null) return null;

    final data = await file.readAsBytes();

    final string = utf8.decode(data);

    final grid = GridIO.load<T>(string);

    return grid;
  }

  static Grid<T> load<T extends num>(String content) {
    final lines = content.split('\n');

    int? height;
    int? width;
    int? mapStart;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('height ')) {
        height = int.parse(line.substring(7));
      } else if (line.startsWith('width ')) {
        width = int.parse(line.substring(6));
      } else if (line == 'map') {
        mapStart = i + 1;
        break;
      }
    }

    if (height == null) {
      throw FormatException('Missing height');
    }

    if (width == null) {
      throw FormatException('Missing width');
    }

    if (mapStart == null) {
      throw FormatException('Missing map section');
    }

    if (lines.length - mapStart < height) {
      throw FormatException(
        'Expected $height map rows, found ${lines.length - mapStart}',
      );
    }

    final grid = Grid<T>(
      defaultValue: 0 as T,
    );

    for (var i = 0; i < height; i++) {
      final row = lines[mapStart + i];

      if (row.length < width) {
        throw FormatException(
          'Invalid row $i: expected width $width, got ${row.length}',
        );
      }

      for (var j = 0; j < width; j++) {
        if (row[j] == '@') {
          grid.set(i, j, 1 as T);
        }
      }
    }

    return grid;
  }
}
