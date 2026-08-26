/// A square chunk of values of type [T].
///
/// [T] must have equality semantics such that comparing a value with
/// [defaultValue] correctly determines whether the cell should be
/// considered empty.
final class Chunk<T> {
  final int size;
  final T defaultValue;

  late final List<T> data;
  late final Set<int> nonDefaultIndexes;

  Chunk({
    this.size = 64,
    required this.defaultValue,
  }) {
    assert(size >= 0);

    data = List<T>.filled(size * size, defaultValue);
    nonDefaultIndexes = {};
  }

  Chunk<U> map<U>(U Function(T value) transform) {
    final result = Chunk<U>(
      size: size,
      defaultValue: transform(defaultValue),
    );

    for (final index in nonDefaultIndexes) {
      final value = transform(data[index]);

      result.data[index] = value;

      if (value != result.defaultValue) {
        result.nonDefaultIndexes.add(index);
      }
    }

    return result;
  }

  T get(int i, int j) {
    assert(0 <= i && i < size);
    assert(0 <= j && j < size);

    return data[i * size + j];
  }

  void set(int i, int j, T value) {
    assert(0 <= i && i < size);
    assert(0 <= j && j < size);

    final index = i * size + j;

    if (value == defaultValue) {
      nonDefaultIndexes.remove(index);
    } else {
      nonDefaultIndexes.add(index);
    }

    data[index] = value;
  }

  void clear() {
    for (int k = 0; k < size * size; ++k) {
      data[k] = defaultValue;
    }

    nonDefaultIndexes.clear();
  }

  bool get isEmpty => nonDefaultIndexes.isEmpty;
}
