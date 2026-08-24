import 'chunk.dart';
import 'coordinates.dart';

final class Grid<T extends num> {
  final int chunkSize;

  final Map<Coordinates, Chunk<T>> _chunks;

  final Set<Coordinates> _locked;

  Grid({
    this.chunkSize = 64,
  }) : _chunks = {},
       _locked = {};

  T get(int i, int j) {
    final chunkCoordinates = _getChunkCoordinates(i, j, chunkSize);

    final chunk = _chunks[chunkCoordinates];

    if (chunk == null) {
      return 0 as T;
    }

    final cellCoordinates = _getLocalCoordinates(i, j, chunkSize);

    return chunk.get(cellCoordinates.i, cellCoordinates.j);
  }

  void set(int i, int j, T value) {
    final chunkCoordinates = _getChunkCoordinates(i, j, chunkSize);
    final cellCoordinates = _getLocalCoordinates(i, j, chunkSize);

    if (_locked.contains(cellCoordinates)) return;

    if (value != 0) {
      final chunk = _chunks.putIfAbsent(chunkCoordinates, () => Chunk(size: chunkSize));

      chunk.set(cellCoordinates.i, cellCoordinates.j, value);
    } else {
      final chunk = _chunks[chunkCoordinates];

      if (chunk == null) return;

      chunk.set(cellCoordinates.i, cellCoordinates.j, value);

      if (chunk.isEmpty) {
        _chunks.remove(chunkCoordinates);
      }
    }
  }

  void lock(int i, int j) => _locked.add(Coordinates(i, j));

  void unlock(int i, int j) => _locked.remove(Coordinates(i, j));

  void clear() {
    _chunks.clear();
  }

  Chunk? getChunk(int i, int j) => _chunks[Coordinates(i, j)];

  Iterable<(int, int, T)> get nonZeroCells sync* {
    for (final entry in _chunks.entries) {
      final chunkCoordinates = entry.key;
      final chunk = entry.value;

      for (final index in chunk.nonZeroIndexes) {
        final i = index ~/ chunk.size;
        final j = index % chunk.size;

        yield (
          chunkCoordinates.i * chunkSize + i,
          chunkCoordinates.j * chunkSize + j,
          chunk.data[index],
        );
      }
    }
  }

  /// Takes the coordinates of a cell in world space and returns the coordinates to the corresponding chunk.
  static Coordinates _getChunkCoordinates(int i, int j, int chunkSize) {
    int convert(int value, int chunkSize) {
      final result = value ~/ chunkSize;

      if (value < 0 && value % chunkSize != 0) {
        return result - 1;
      }

      return result;
    }

    return Coordinates(
      convert(i, chunkSize),
      convert(j, chunkSize),
    );
  }

  /// Takes the coordinates of a cell in world space and returns those coordinates in chunk space.
  static Coordinates _getLocalCoordinates(int i, int j, int chunkSize) {
    int convert(int value, int chunkSize) {
      final result = value % chunkSize;
      return result < 0 ? result + chunkSize : result;
    }

    return Coordinates(
      convert(i, chunkSize),
      convert(j, chunkSize),
    );
  }
}
