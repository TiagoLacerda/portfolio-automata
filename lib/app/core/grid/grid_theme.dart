import 'package:material_ui/material_ui.dart';

/// Grid colors, lerped along with the rest of the theme.
final class GridTheme extends ThemeExtension<GridTheme> {
  final Color cellColor;
  final Color gridColor0;
  final Color gridColor1;

  const GridTheme({
    required this.cellColor,
    required this.gridColor0,
    required this.gridColor1,
  });

  static const light = GridTheme(
    cellColor: Colors.black,
    gridColor0: Color(0xFFF0F0F0),
    gridColor1: Color(0xFFE0E0E0),
  );

  static const dark = GridTheme(
    cellColor: Colors.white,
    gridColor0: Color(0xFF0F0F0F),
    gridColor1: Color(0xFF1F1F1F),
  );

  static GridTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<GridTheme>() ?? (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  GridTheme copyWith({
    Color? cellColor,
    Color? gridColor0,
    Color? gridColor1,
  }) {
    return GridTheme(
      cellColor: cellColor ?? this.cellColor,
      gridColor0: gridColor0 ?? this.gridColor0,
      gridColor1: gridColor1 ?? this.gridColor1,
    );
  }

  @override
  GridTheme lerp(GridTheme? other, double t) {
    if (other == null) return this;

    return GridTheme(
      cellColor: Color.lerp(cellColor, other.cellColor, t)!,
      gridColor0: Color.lerp(gridColor0, other.gridColor0, t)!,
      gridColor1: Color.lerp(gridColor1, other.gridColor1, t)!,
    );
  }
}
