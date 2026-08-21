import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/grid/coordinates.dart';
import '../../../core/grid/grid.dart';
import '../grid_extensions.dart';

class GridWidget extends StatefulWidget {
  final Grid grid;

  const GridWidget({
    super.key,
    required this.grid,
  });

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> with SingleTickerProviderStateMixin {
  late final Timer timer;

  double zoom = 5.0;
  Offset offset = Offset.zero;

  Offset? panStart;

  int? previousI;
  int? previousJ;

  void onPointerDown(PointerDownEvent event) {
    if (event.buttons == kMiddleMouseButton) {
      panStart = event.localPosition;
      return;
    }

    if (event.buttons == kPrimaryMouseButton) {
      final cell = screenToCell(event.localPosition);

      previousI = cell.i;
      previousJ = cell.j;

      widget.grid.set(cell.i, cell.j, 1);
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (event.buttons == kMiddleMouseButton) {
      if (panStart != null) {
        final delta = event.localPosition - panStart!;

        offset += delta;
        panStart = event.localPosition;

        setState(() {});
      }

      return;
    }

    if (event.buttons == kPrimaryMouseButton) {
      final cell = screenToCell(event.localPosition);

      if (previousI != null && previousJ != null) {
        widget.grid.bresenham(
          previousI!,
          previousJ!,
          cell.i,
          cell.j,
        );
      }

      previousI = cell.i;
      previousJ = cell.j;

      setState(() {});
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (event.buttons == kMiddleMouseButton) {
      panStart = null;
    }

    if (event.buttons == kPrimaryMouseButton) {
      previousI = null;
      previousJ = null;
    }
  }

  void onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

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

    timer = Timer.periodic(
      const Duration(milliseconds: 16),
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
    return Listener(
      onPointerDown: onPointerDown,
      onPointerMove: onPointerMove,
      onPointerUp: onPointerUp,
      onPointerSignal: onPointerSignal,
      child: CustomPaint(
        painter: GridPainter(
          grid: widget.grid,
          zoom: zoom,
          offset: offset,
          isDark: Theme.of(context).brightness == Brightness.dark,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Grid grid;
  final double zoom;
  final Offset offset;
  final bool isDark;

  late final cellPaint = Paint()
    ..color = isDark ? Color(0xFFFFFFFF) : Color(0xFF000000)
    ..isAntiAlias = false;

  GridPainter({
    required this.grid,
    required this.zoom,
    required this.offset,
    required this.isDark,
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

      for (final index in chunk.nonZeroIndexes) {
        final i = index ~/ chunk.size;
        final j = index % chunk.size;

        canvas.drawRect(
          Rect.fromLTWH(
            coordinates.i * scaledChunkSize + i * cellSize + offset.dx,
            coordinates.j * scaledChunkSize + j * cellSize + offset.dy,
            cellSize,
            cellSize,
          ),
          cellPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return true;
  }
}
