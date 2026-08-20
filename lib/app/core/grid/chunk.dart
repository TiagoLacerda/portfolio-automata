final class Chunk<T extends num> {
  final int size;

  late final List<T> data;

  Chunk({
    this.size = 64,
  }) {
    data = List<T>.filled(size * size, 0 as T);
  }

  T get(int i, int j) {
    assert(0 <= i && i < size);
    assert(0 <= j && j < size);

    return data[i * size + j];
  }

  void set(int i, int j, T value) {
    assert(0 <= i && i < size);
    assert(0 <= j && j < size);

    data[i * size + j] = value;
  }

  void clear() {
    for (int k = 0; k < size * size; ++k) {
      data[k] = 0 as T;
    }
  }

  bool get isEmpty => data.every((cell) => cell == 0);
}
