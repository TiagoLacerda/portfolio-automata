import 'dart:typed_data';

typedef Position = ({int i, int j});

/// Defines a fixed-size grid of boolean cells.
abstract interface class IChunk {
  /// The width and height of the chunk.
  int get size;

  /// Whether all cells in the chunk are false.
  bool get isEmpty;

  /// Positions of all cells whose value is true.
  Set<Position> get nonZeroPositions;

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

  UInt32Chunk() : _data = Uint32List(_size);

  @override
  final Set<Position> nonZeroPositions = {};

  @override
  int get size => _size;

  @override
  bool get isEmpty => nonZeroPositions.isEmpty;

  @override
  bool get(int i, int j) => (_data[i] & (1 << j)) != 0;

  @override
  void set(int i, int j, bool value) {
    final position = (i: i, j: j);

    if (value) {
      _data[i] |= 1 << j;
      nonZeroPositions.add(position);
    } else {
      _data[i] &= ~(1 << j);
      nonZeroPositions.remove(position);
    }
  }

  @override
  void clear() {
    _data.fillRange(0, size, 0);
    nonZeroPositions.clear();
  }
}
