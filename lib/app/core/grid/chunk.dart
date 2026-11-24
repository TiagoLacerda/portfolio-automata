import 'dart:typed_data';

typedef Position = ({int i, int j});

/// Defines a fixed-size grid of boolean cells.
abstract interface class IChunk {
  /// The width and height of the chunk.
  int get size;

  /// Whether all cells in the chunk are false.
  bool get isEmpty;

  /// Positions of all cells whose value is true.
  Iterable<Position> get nonZeroPositions;

  /// Returns the value at the given local coordinates.
  bool get(int i, int j);

  /// Sets the value at the given local coordinates.
  void set(int i, int j, bool value);

  /// Sets all cells to false.
  void clear();
}

final class UInt32Chunk implements IChunk {
  static const _size = 32;

  final Uint32List _data;

  int _count = 0;

  UInt32Chunk() : _data = Uint32List(_size);

  @override
  Iterable<Position> get nonZeroPositions sync* {
    for (int i = 0; i < _size; ++i) {
      int row = _data[i];

      while (row != 0) {
        // Two's complement: row & -row keeps only the lowest set bit.
        final lowest = row & -row;

        yield (i: i, j: lowest.bitLength - 1);

        row ^= lowest;
      }
    }
  }

  @override
  int get size => _size;

  @override
  bool get isEmpty => _count == 0;

  @override
  bool get(int i, int j) => (_data[i] & (1 << j)) != 0;

  @override
  void set(int i, int j, bool value) {
    final mask = 1 << j;
    final row = _data[i];

    if (((row & mask) != 0) == value) return;

    _data[i] = row ^ mask;
    _count += value ? 1 : -1;
  }

  @override
  void clear() {
    _data.fillRange(0, size, 0);
    _count = 0;
  }
}
