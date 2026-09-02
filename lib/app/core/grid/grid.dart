import 'chunk.dart';

/// Defines a sparse, chunked grid of boolean cells.
abstract interface class IGrid {
  /// The width and height of each chunk.
  int get chunkSize;

  /// Whether all cells in the grid are false.
  bool get isEmpty;

  /// Positions of all cells whose value is true.
  Iterable<Position> get nonZeroPositions;

  /// Returns the chunk containing the given world coordinates, if present.
  IChunk? getChunk(int i, int j);

  /// Returns the value at the given world coordinates.
  bool get(int i, int j);

  /// Sets the value at the given world coordinates.
  void set(int i, int j, bool value);

  /// Clears all cells in the grid.
  void clear();

  /// Locks the cell at the given world coordinates.
  void lock(int i, int j);

  /// Unlocks the cell at the given world coordinates.
  void unlock(int i, int j);

  /// Converts world coordinates to chunk coordinates.
  static Position getChunkPosition(int i, int j, int chunkSize) {
    int convert(int value, int chunkSize) {
      final result = value ~/ chunkSize;

      if (value < 0 && value % chunkSize != 0) {
        return result - 1;
      }

      return result;
    }

    return (
      i: convert(i, chunkSize),
      j: convert(j, chunkSize),
    );
  }

  /// Converts world coordinates to local chunk coordinates.
  static Position getLocalPosition(int i, int j, int chunkSize) {
    int convert(int value, int chunkSize) {
      final result = value % chunkSize;
      return result < 0 ? result + chunkSize : result;
    }

    return (
      i: convert(i, chunkSize),
      j: convert(j, chunkSize),
    );
  }
}

final class UInt32Grid implements IGrid {
  static const int _chunkSize = 32;

  final Map<Position, UInt32Chunk> _chunks;

  final Set<Position> _locked;

  UInt32Grid() : _chunks = {}, _locked = {};

  @override
  int get chunkSize => _chunkSize;

  @override
  bool get isEmpty => nonZeroPositions.isEmpty;

  @override
  Iterable<Position> get nonZeroPositions sync* {
    for (final entry in _chunks.entries) {
      final chunkPosition = entry.key;
      final chunk = entry.value;

      for (final position in chunk.nonZeroPositions) {
        yield (
          i: chunkPosition.i * chunk.size + position.i,
          j: chunkPosition.j * chunk.size + position.j,
        );
      }
    }
  }

  @override
  UInt32Chunk? getChunk(int i, int j) => _chunks[(i: i, j: j)];

  @override
  bool get(int i, int j) {
    final chunkPosition = IGrid.getChunkPosition(i, j, chunkSize);
    final chunk = _chunks[chunkPosition];

    if (chunk == null) return false;

    final cellPosition = IGrid.getLocalPosition(i, j, chunkSize);

    return chunk.get(cellPosition.i, cellPosition.j);
  }

  @override
  void set(int i, int j, bool value) {
    final position = (i: i, j: j);

    if (_locked.contains(position)) return;

    final chunkPosition = IGrid.getChunkPosition(i, j, chunkSize);
    final localPosition = IGrid.getLocalPosition(i, j, chunkSize);

    if (value) {
      final chunk = _chunks.putIfAbsent(
        chunkPosition,
        () => UInt32Chunk(),
      );

      chunk.set(localPosition.i, localPosition.j, value);
    } else {
      final chunk = _chunks[chunkPosition];

      if (chunk == null) return;

      chunk.set(localPosition.i, localPosition.j, value);

      if (chunk.isEmpty) {
        _chunks.remove(chunkPosition);
      }
    }
  }

  @override
  void clear() {
    _chunks.clear();
  }

  @override
  void lock(int i, int j) => _locked.add((i: i, j: j));

  @override
  void unlock(int i, int j) => _locked.remove((i: i, j: j));
}
