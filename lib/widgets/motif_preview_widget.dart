import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/motif.dart';

Path createPolygonPath(Size size, MotifShape shape, {double factor = 1.0}) {
  final path = Path();
  final cx = size.width / 2;
  final cy = size.height / 2;
  final radius = (size.width / 2) * factor;

  if (shape == MotifShape.square) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: radius * 2, height: radius * 2);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.12));
    path.addRRect(rrect);
    return path;
  }

  final sides = shape.sides;
  final startAngle = -pi / 2;
  for (int i = 0; i < sides; i++) {
    final angle = startAngle + (i * 2 * pi) / sides;
    final x = cx + radius * cos(angle);
    final y = cy + radius * sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

class PolygonClipper extends CustomClipper<Path> {
  final MotifShape shape;

  PolygonClipper(this.shape);

  @override
  Path getClip(Size size) {
    return createPolygonPath(size, shape);
  }

  @override
  bool shouldReclip(covariant PolygonClipper oldDelegate) => oldDelegate.shape != shape;
}

class MotifPreviewWidget extends StatelessWidget {
  final Motif motif;
  final double size;
  final bool isSelected;
  final bool showShadow;
  final VoidCallback? onTap;

  const MotifPreviewWidget({
    super.key,
    required this.motif,
    this.size = 80,
    this.isSelected = false,
    this.showShadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: motif.shape == MotifShape.square
            ? BorderRadius.circular(size * 0.12)
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFD8D0C5),
          width: isSelected ? 3 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: motif.type == MotifType.photo && motif.photoBase64 != null
          ? ClipPath(
              clipper: PolygonClipper(motif.shape),
              child: Image.memory(
                base64Decode(motif.photoBase64!),
                width: size,
                height: size,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            )
          : CustomPaint(
              size: Size(size, size),
              painter: _GrannySquarePainter(motif: motif),
            ),
    );

    if (onTap != null) {
      content = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

class _GrannySquarePainter extends CustomPainter {
  final Motif motif;

  _GrannySquarePainter({required this.motif});

  @override
  void paint(Canvas canvas, Size size) {
    final rounds = motif.rounds;
    if (rounds.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final totalRounds = rounds.length;

    switch (motif.type) {
      case MotifType.classicGranny:
        _paintClassicGranny(canvas, size, center, totalRounds);
        break;
      case MotifType.solidGranny:
        _paintSolidGranny(canvas, size, center, totalRounds);
        break;
      case MotifType.sunburst:
        _paintSunburst(canvas, size, center, totalRounds);
        break;
      case MotifType.photo:
        break;
    }
  }

  void _paintClassicGranny(Canvas canvas, Size size, Offset center, int totalRounds) {
    final halfSize = size.width / 2;

    for (int i = totalRounds - 1; i >= 0; i--) {
      final color = motif.rounds[i].color;
      final roundFraction = (i + 1) / totalRounds;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final shapePath = createPolygonPath(size, motif.shape, factor: roundFraction);
      canvas.drawPath(shapePath, paint);

      if (i > 0) {
        final strokePaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawPath(shapePath, strokePaint);
      }
    }

    final centerHolePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, halfSize * 0.08, centerHolePaint);
  }

  void _paintSolidGranny(Canvas canvas, Size size, Offset center, int totalRounds) {
    final halfSize = size.width / 2;

    for (int i = totalRounds - 1; i >= 0; i--) {
      final color = motif.rounds[i].color;
      final roundFraction = (i + 1) / totalRounds;
      final currentRadius = halfSize * roundFraction;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final shapePath = createPolygonPath(size, motif.shape, factor: roundFraction);
      canvas.drawPath(shapePath, paint);

      final linePaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..strokeWidth = 1.2;

      final sides = motif.shape.sides;
      final startAngle = -pi / 2;
      for (int k = 0; k < sides; k++) {
        final angle = startAngle + (k * 2 * pi) / sides;
        final vx = center.dx + currentRadius * cos(angle);
        final vy = center.dy + currentRadius * sin(angle);
        canvas.drawLine(Offset(vx, vy), center, linePaint);
      }
    }
  }

  void _paintSunburst(Canvas canvas, Size size, Offset center, int totalRounds) {
    final halfSize = size.width / 2;

    if (totalRounds >= 4) {
      final outerPaint = Paint()
        ..color = motif.rounds[totalRounds - 1].color
        ..style = PaintingStyle.fill;
      final shapePath = createPolygonPath(size, motif.shape, factor: 1.0);
      canvas.drawPath(shapePath, outerPaint);
    }

    final petalColorIndex = totalRounds >= 3 ? totalRounds - 2 : 0;
    final petalColor = motif.rounds[petalColorIndex].color;
    final petalRadius = halfSize * 0.72;

    final petalPaint = Paint()
      ..color = petalColor
      ..style = PaintingStyle.fill;

    final int petalCount = motif.shape.sides * 3;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * pi) / petalCount;
      final px = center.dx + cos(angle) * (petalRadius * 0.65);
      final py = center.dy + sin(angle) * (petalRadius * 0.65);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: petalRadius * 0.55,
          height: petalRadius * 0.26,
        ),
        petalPaint,
      );
      canvas.restore();
    }

    if (totalRounds >= 2) {
      final puffColorIndex = min(1, totalRounds - 1);
      final puffColor = motif.rounds[puffColorIndex].color;
      final puffRadius = halfSize * 0.42;

      final puffPaint = Paint()
        ..color = puffColor
        ..style = PaintingStyle.fill;

      final int puffCount = motif.shape.sides * 2;
      for (int i = 0; i < puffCount; i++) {
        final angle = (i * 2 * pi) / puffCount;
        final px = center.dx + cos(angle) * (puffRadius * 0.55);
        final py = center.dy + sin(angle) * (puffRadius * 0.55);
        canvas.drawCircle(Offset(px, py), puffRadius * 0.35, puffPaint);
      }
    }

    final centerColor = motif.rounds[0].color;
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, halfSize * 0.22, centerPaint);

    final dotPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, halfSize * 0.06, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _GrannySquarePainter oldDelegate) {
    return oldDelegate.motif != motif;
  }
}
