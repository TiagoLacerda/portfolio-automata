import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/grid/coordinates.dart';
import '../../../core/grid/grid.dart';
import '../grid_extensions.dart';

class GridWidget<T> extends StatefulWidget {
  final Grid<T> grid;
  final double initialZoom;
  final Offset initalOffset;
  final bool enableEditing;
  final bool enablePanAndZoom;
  final Color? Function(int i, int j, T value)? colorWith;
  final T pencil;

  const GridWidget({
    super.key,
    required this.grid,
    this.initialZoom = 5.0,
    this.initalOffset = Offset.zero,
    this.enableEditing = true,
    this.enablePanAndZoom = true,
    this.colorWith,
    required this.pencil,
  });

  @override
  State<GridWidget<T>> createState() => _GridWidgetState<T>();
}

class _GridWidgetState<T> extends State<GridWidget<T>> with SingleTickerProviderStateMixin {
  late final Timer timer;

  late double zoom;
  late Offset offset;

  Offset? panStart;

  int? previousI;
  int? previousJ;

  late T brush;

  void onPointerDown(PointerDownEvent event) {
    if (widget.enablePanAndZoom && event.buttons == kMiddleMouseButton) {
      panStart = event.localPosition;
      return;
    }

    if (widget.enableEditing && event.buttons == kPrimaryMouseButton) {
      final cell = screenToCell(event.localPosition);

      previousI = cell.i;
      previousJ = cell.j;

      brush = widget.grid.get(cell.i, cell.j) == widget.grid.defaultValue ? widget.pencil : widget.grid.defaultValue;

      widget.grid.set(cell.i, cell.j, brush);
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
      final cell = screenToCell(event.localPosition);

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

  Coordinates screenToCell(Offset position) {
    return Coordinates(
      ((position.dx - offset.dx) / zoom).floor(),
      ((position.dy - offset.dy) / zoom).floor(),
    );
  }

  @override
  void initState() {
    super.initState();

    zoom = widget.initialZoom;
    offset = widget.initalOffset;

    brush = widget.pencil;

    timer = Timer.periodic(
      const Duration(milliseconds: 32),
      (_) => setState(() {}),
    );
  }

  @override
  void didUpdateWidget(covariant GridWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (brush == oldWidget.pencil) {
      brush = widget.pencil;
    } else {
      brush = widget.grid.defaultValue;
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    final colorWith = widget.colorWith ?? (i, j, value) => value == 0 ? null : color;

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
            colorWith: colorWith,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class GridPainter<T> extends CustomPainter {
  final Grid<T> grid;
  final double zoom;
  final Offset offset;
  final Color? Function(int i, int j, T value) colorWith;

  GridPainter({
    required this.grid,
    required this.zoom,
    required this.offset,
    required this.colorWith,
  });

  List<Coordinates> getChunks(Rect visibleRect) {
    const chunkSize = 64.0;

    final firstI = (visibleRect.left / chunkSize).floor();
    final firstJ = (visibleRect.top / chunkSize).floor();

    final lastI = ((visibleRect.right - 1) / chunkSize).floor();
    final lastJ = ((visibleRect.bottom - 1) / chunkSize).floor();

    return [
      for (var j = firstJ; j <= lastJ; j++)
        for (var i = firstI; i <= lastI; i++) Coordinates(i, j),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = zoom;
    final scaledChunkSize = grid.chunkSize * cellSize;

    final paint = Paint()..isAntiAlias = false;

    final visibleRect = Rect.fromLTWH(
      -offset.dx / zoom,
      -offset.dy / zoom,
      size.width / zoom,
      size.height / zoom,
    );

    for (final coordinates in getChunks(visibleRect)) {
      final chunk = grid.getChunk(
        coordinates.i,
        coordinates.j,
      );

      if (chunk == null) {
        continue;
      }

      for (final index in chunk.nonDefaultIndexes) {
        final i = index ~/ chunk.size;
        final j = index % chunk.size;
        final value = chunk.get(i, j);
        final color = colorWith(i, j, value);

        if (color == null) continue;
        if (color != paint.color) paint.color = color;

        canvas.drawRect(
          Rect.fromLTWH(
            coordinates.i * scaledChunkSize + i * cellSize + offset.dx,
            coordinates.j * scaledChunkSize + j * cellSize + offset.dy,
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
