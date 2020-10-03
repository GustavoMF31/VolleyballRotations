import 'package:flutter/material.dart';

import 'Court.dart';

class TransparentCanvas extends StatefulWidget {
  final Widget child;
  final List<Offset> points;
  final Function(Offset) onNewPoint;
  final Function() onLineEnd;

  const TransparentCanvas({
    Key key,
    @required this.child,
    @required this.points,
    @required this.onNewPoint,
    @required this.onLineEnd,
  }) : super(key: key);

  @override
  _TransparentCanvasState createState() => _TransparentCanvasState();
}

class _TransparentCanvasState extends State<TransparentCanvas> {

  @override
  Widget build(BuildContext context) {
    final courtSize = CourtSize.of(context);

    return GestureDetector(
      child: CustomPaint(
        size: Size(courtSize, courtSize),
        child: widget.child,
        foregroundPainter: CanvasPainter(widget.points, courtSize),
      ),
      onPanUpdate: (details) {
        final rb = context.findRenderObject() as RenderBox;
        widget.onNewPoint(rb.globalToLocal(details.globalPosition) / courtSize);
      },
      onPanEnd: (_) {
        widget.onLineEnd();
      },
    );
  }
}

class CanvasPainter extends CustomPainter {
  final List<Offset> points;
  final double courtSize;
  CanvasPainter(this.points, this.courtSize);

  var paintObject = Paint()
    ..color = Colors.black
    ..strokeWidth = 5
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {

    if (points.isEmpty) return;

    points.getRange(0, points.length - 1).toList().asMap().forEach((index, p) {
      final secondPoint = points[index + 1];
      if (p == null || secondPoint == null) return;
      canvas.drawLine(
          p * courtSize, points[index + 1] * courtSize, paintObject);
    });
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => true;
}