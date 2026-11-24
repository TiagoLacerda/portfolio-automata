import 'chunk.dart';

/// Defines a sparse, chunked grid of boolean cells.
abstract interface class IGrid {
  /// The width and height of each chunk.
  int get chunkSize;

  /// Whether all cells in the grid are false.
  bool get isEmpty;

  /// Positions of all cells whose value is true.
  Iterable<Position> get nonZeroPositions;

  /// Chunk coordinates of all non-empty chunks.
  Iterable<Position> get chunkPositions;

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
}

final class UInt32Grid implements IGrid {
  static const int _chunkShift = 5;
  static const int _chunkSize = 1 << _chunkShift;
  static const int _chunkMask = _chunkSize - 1;

  // Dart web handles >> as unsigned.
  static int _chunkCoord(int v) => (v - (v & _chunkMask)) ~/ _chunkSize;

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
  Iterable<Position> get chunkPositions => _chunks.keys;

  @override
  UInt32Chunk? getChunk(int i, int j) => _chunks[(i: i, j: j)];

  @override
  bool get(int i, int j) {
    final chunk = _chunks[(i: _chunkCoord(i), j: _chunkCoord(j))];

    if (chunk == null) return false;

    return chunk.get(i & _chunkMask, j & _chunkMask);
  }

  @override
  void set(int i, int j, bool value) {
    final position = (i: i, j: j);

    if (_locked.contains(position)) return;

    final chunkPosition = (i: _chunkCoord(i), j: _chunkCoord(j));
    final localI = i & _chunkMask;
    final localJ = j & _chunkMask;

    if (value) {
      final chunk = _chunks.putIfAbsent(
        chunkPosition,
        () => UInt32Chunk(),
      );

      chunk.set(localI, localJ, value);
    } else {
      final chunk = _chunks[chunkPosition];

      if (chunk == null) return;

      chunk.set(localI, localJ, value);

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
