import 'package:flutter/material.dart';

/// Imzo olish widget
class SignaturePad extends StatefulWidget {
  final Function(List<Offset>) onSignature;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final double strokeWidth;

  const SignaturePad({
    super.key,
    required this.onSignature,
    this.height = 200,
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<Offset> _points = [];
  bool _hasSignature = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: _SignaturePainter(
                  points: _points,
                  strokeColor: widget.strokeColor,
                  strokeWidth: widget.strokeWidth,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Tozalash'),
            ),
          ],
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _points.add(details.localPosition);
      _hasSignature = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _points.add(Offset.zero); // Ajratuvchi
    });
    widget.onSignature(_points);
  }

  void _clear() {
    setState(() {
      _points.clear();
      _hasSignature = false;
    });
    widget.onSignature([]);
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset> points;
  final Color strokeColor;
  final double strokeWidth;

  _SignaturePainter({
    required this.points,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
