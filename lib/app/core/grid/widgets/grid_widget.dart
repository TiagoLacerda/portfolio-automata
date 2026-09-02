import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/grid/grid.dart';
import '../chunk.dart';
import '../grid_extensions.dart';

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
  late final Timer timer;

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

    timer = Timer.periodic(
      Duration(milliseconds: (1000 / 20).toInt()),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    final colorWith = widget.colorWith ?? (_, _, value) => value ? color : null;

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

class GridPainter extends CustomPainter {
  final IGrid grid;
  final double zoom;
  final Offset offset;
  final Color? Function(int i, int j, bool value) colorWith;

  GridPainter({
    required this.grid,
    required this.zoom,
    required this.offset,
    required this.colorWith,
  });

  List<Position> getChunks(Rect visibleRect) {
    // TODO: This doesnt belong here
    const chunkSize = 32.0;

    final firstI = (visibleRect.left / chunkSize).floor();
    final firstJ = (visibleRect.top / chunkSize).floor();

    final lastI = ((visibleRect.right - 1) / chunkSize).floor();
    final lastJ = ((visibleRect.bottom - 1) / chunkSize).floor();

    return [
      for (var j = firstJ; j <= lastJ; j++)
        for (var i = firstI; i <= lastI; i++) (i: i, j: j),
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

      for (final position in chunk.nonZeroPositions) {
        final index = position.i * chunk.size + position.j;
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
