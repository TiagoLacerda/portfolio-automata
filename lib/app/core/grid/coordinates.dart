final class Coordinates {
  final int i;
  final int j;

  const Coordinates(
    this.i,
    this.j,
  );

  @override
  bool operator ==(Object other) {
    return other is Coordinates && other.i == i && other.j == j;
  }

  @override
  int get hashCode => Object.hash(i, j);
}
