import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../../../core/grid/grid.dart';
import '../chunk.dart';
import '../grid_extensions.dart';
import '../grid_theme.dart';

class GridWidget extends StatefulWidget {
  final IGrid grid;
  final double initialZoom;
  final Offset initalOffset;
  final bool enableEditing;
  final bool enablePanAndZoom;
  final Color? Function(int i, int j, bool value)? colorWith;

  const GridWidget({
    super.key,
    required this.grid,
    this.initialZoom = 5.0,
    this.initalOffset = Offset.zero,
    this.enableEditing = true,
    this.enablePanAndZoom = true,
    this.colorWith,
  });

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> with SingleTickerProviderStateMixin {
  late double zoom;
  late Offset offset;

  Offset? panStart;

  int? previousI;
  int? previousJ;

  bool brush = true;

  void onPointerDown(PointerDownEvent event) {
    if (widget.enablePanAndZoom && event.buttons == kMiddleMouseButton) {
      panStart = event.localPosition;
      return;
    }

    if (widget.enableEditing && event.buttons == kPrimaryMouseButton) {
      final position = screenToWorld(event.localPosition);

      previousI = position.i;
      previousJ = position.j;

      brush = !widget.grid.get(position.i, position.j);

      widget.grid.set(position.i, position.j, brush);

      setState(() {});
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (widget.enablePanAndZoom && event.buttons == kMiddleMouseButton) {
      if (panStart != null) {
        final delta = event.localPosition - panStart!;

        offset += delta;
        panStart = event.localPosition;

        setState(() {});
      }

      return;
    }

    if (widget.enableEditing && event.buttons == kPrimaryMouseButton) {
      final cell = screenToWorld(event.localPosition);

      if (previousI != null && previousJ != null) {
        widget.grid.bresenham(
          previousI!,
          previousJ!,
          cell.i,
          cell.j,
          brush,
        );
      }

      previousI = cell.i;
      previousJ = cell.j;

      setState(() {});
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (widget.enablePanAndZoom && event.buttons == kMiddleMouseButton) {
      panStart = null;
    }

    if (widget.enableEditing && event.buttons == kPrimaryMouseButton) {
      previousI = null;
      previousJ = null;
    }
  }

  void onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

    if (!widget.enablePanAndZoom) return;

    final mouse = event.localPosition;
    final oldZoom = zoom;

    final newZoom = (zoom * (event.scrollDelta.dy > 0 ? 0.9 : 1.1)).clamp(0.1, 20.0);

    // World coordinate currently underneath the mouse.
    final world = (mouse - offset) / oldZoom;

    // Adjust the offset so that `world` remains underneath the mouse.
    final newOffset = mouse - world * newZoom;

    setState(() {
      zoom = newZoom;
      offset = newOffset;
    });
  }

  Position screenToWorld(Offset position) {
    return (
      i: ((position.dx - offset.dx) / zoom).floor(),
      j: ((position.dy - offset.dy) / zoom).floor(),
    );
  }

  @override
  void initState() {
    super.initState();

    zoom = widget.initialZoom;
    offset = widget.initalOffset;
  }

  @override
  Widget build(BuildContext context) {
    final gridTheme = GridTheme.of(context);

    return Listener(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      onPointerSignal: onPointerSignal,
      child: ClipRect(
        child: CustomPaint(
          painter: GridPainter(
            grid: widget.grid,
            zoom: zoom,
            offset: offset,
            colorWith: widget.colorWith,
            cellColor: gridTheme.cellColor,
            gridColor0: gridTheme.gridColor0,
            gridColor1: gridTheme.gridColor1,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final IGrid grid;
  final double zoom;
  final Offset offset;
  final Color? Function(int i, int j, bool value)? colorWith;
  final Color cellColor;
  final Color gridColor0;
  final Color gridColor1;

  // 2x2 mask, opaque on the anti-diagonal. Built once and tinted at paint
  // time, so colors can change every frame without creating images.
  static final ui.Image _checkerboardMask = () {
    final recorder = ui.PictureRecorder();
    final paint = Paint()..isAntiAlias = false;

    Canvas(recorder)
      ..drawRect(const Rect.fromLTWH(1, 0, 1, 1), paint)
      ..drawRect(const Rect.fromLTWH(0, 1, 1, 1), paint);

    return recorder.endRecording().toImageSync(2, 2);
  }();

  GridPainter({
    required this.grid,
    required this.zoom,
    required this.offset,
    required this.colorWith,
    required this.cellColor,
    required this.gridColor0,
    required this.gridColor1,
  });

  /// Coordinates of the existing chunks that overlap [visibleRect].
  List<Position> getVisibleChunks(Rect visibleRect) {
    final chunkSize = grid.chunkSize;

    final firstI = (visibleRect.left / chunkSize).floor();
    final firstJ = (visibleRect.top / chunkSize).floor();

    final lastI = (visibleRect.right / chunkSize).floor();
    final lastJ = (visibleRect.bottom / chunkSize).floor();

    final chunkPositions = grid.chunkPositions;

    // Zoomed out, visible slots can far outnumber existing chunks.
    if ((lastI - firstI + 1) * (lastJ - firstJ + 1) > chunkPositions.length) {
      return [
        for (final position in chunkPositions)
          if (position.i >= firstI && position.i <= lastI && position.j >= firstJ && position.j <= lastJ) position,
      ];
    }

    return [
      for (var j = firstJ; j <= lastJ; j++)
        for (var i = firstI; i <= lastI; i++)
          if (grid.getChunk(i, j) != null) (i: i, j: j),
    ];
  }

  void paintCheckerboard(Canvas canvas, Size size) {
    final image = _checkerboardMask;
    final tileSize = zoom * 2;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = gridColor0,
    );

    final matrix = Matrix4.identity()
      ..translateByVector2(Vector2(offset.dx, offset.dy))
      ..scaleByVector3(Vector3(tileSize / image.width, tileSize / image.height, 1));

    final shader = ui.ImageShader(
      image,
      TileMode.repeated,
      TileMode.repeated,
      matrix.storage,
    );

    final paint = Paint()
      ..shader = shader
      ..colorFilter = ColorFilter.mode(gridColor1, BlendMode.srcIn)
      ..isAntiAlias = false;

    canvas.drawRect(
      Offset.zero & size,
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintCheckerboard(canvas, size);

    final cellSize = zoom;
    final scaledChunkSize = grid.chunkSize * cellSize;

    final paint = Paint()..isAntiAlias = false;

    final visibleRect = Rect.fromLTWH(
      -offset.dx / zoom,
      -offset.dy / zoom,
      size.width / zoom,
      size.height / zoom,
    );

    final colorWith = this.colorWith;

    for (final coordinates in getVisibleChunks(visibleRect)) {
      final chunk = grid.getChunk(coordinates.i, coordinates.j)!;

      final chunkI = coordinates.i * grid.chunkSize;
      final chunkJ = coordinates.j * grid.chunkSize;

      for (final position in chunk.nonZeroPositions) {
        final color = colorWith == null ? cellColor : colorWith(chunkI + position.i, chunkJ + position.j, true);

        if (color == null) continue;
        if (color != paint.color) paint.color = color;

        canvas.drawRect(
          Rect.fromLTWH(
            coordinates.i * scaledChunkSize + position.i * cellSize + offset.dx,
            coordinates.j * scaledChunkSize + position.j * cellSize + offset.dy,
            cellSize,
            cellSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return true;
  }
}
