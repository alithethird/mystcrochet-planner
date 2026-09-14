import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/motif.dart';

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
        borderRadius: BorderRadius.circular(size * 0.12),
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
          ? Image.memory(
              base64Decode(motif.photoBase64!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
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
    // Draw from outer round inwards, with cluster stitch cuts
    final halfSize = size.width / 2;

    for (int i = totalRounds - 1; i >= 0; i--) {
      final color = motif.rounds[i].color;
      final roundFraction = (i + 1) / totalRounds;
      final currentRadius = halfSize * roundFraction;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCenter(
        center: center,
        width: currentRadius * 2,
        height: currentRadius * 2,
      );
      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(currentRadius * 0.18),
      );
      canvas.drawRRect(rrect, paint);

      // Draw subtle crochet cluster stitch lines for classic granny look
      if (i > 0) {
        final strokePaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawRRect(rrect, strokePaint);
      }
    }

    // Inner center ring hole
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

      final rect = Rect.fromCenter(
        center: center,
        width: currentRadius * 2,
        height: currentRadius * 2,
      );
      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(currentRadius * 0.1),
      );
      canvas.drawRRect(rrect, paint);

      // Corner diagonal lines characteristic of solid granny
      final linePaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(center.dx - currentRadius, center.dy - currentRadius),
        center,
        linePaint,
      );
      canvas.drawLine(
        Offset(center.dx + currentRadius, center.dy - currentRadius),
        center,
        linePaint,
      );
      canvas.drawLine(
        Offset(center.dx - currentRadius, center.dy + currentRadius),
        center,
        linePaint,
      );
      canvas.drawLine(
        Offset(center.dx + currentRadius, center.dy + currentRadius),
        center,
        linePaint,
      );
    }
  }

  void _paintSunburst(Canvas canvas, Size size, Offset center, int totalRounds) {
    final halfSize = size.width / 2;

    // Outermost round (Round 4 or totalRounds - 1): Squared frame
    if (totalRounds >= 4) {
      final outerPaint = Paint()
        ..color = motif.rounds[totalRounds - 1].color
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: size.width, height: size.height),
          Radius.circular(size.width * 0.15),
        ),
        outerPaint,
      );
    }

    // Round 2 / 3: Radiating Petals (Sunburst floral ring)
    final petalColorIndex = totalRounds >= 3 ? totalRounds - 2 : 0;
    final petalColor = motif.rounds[petalColorIndex].color;
    final petalRadius = halfSize * 0.72;

    final petalPaint = Paint()
      ..color = petalColor
      ..style = PaintingStyle.fill;

    // Draw 16 radiating petal ovals
    const int petalCount = 16;
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

    // Round 1: Inner puff ring
    if (totalRounds >= 2) {
      final puffColorIndex = min(1, totalRounds - 1);
      final puffColor = motif.rounds[puffColorIndex].color;
      final puffRadius = halfSize * 0.42;

      final puffPaint = Paint()
        ..color = puffColor
        ..style = PaintingStyle.fill;

      const int puffCount = 8;
      for (int i = 0; i < puffCount; i++) {
        final angle = (i * 2 * pi) / puffCount;
        final px = center.dx + cos(angle) * (puffRadius * 0.55);
        final py = center.dy + sin(angle) * (puffRadius * 0.55);
        canvas.drawCircle(Offset(px, py), puffRadius * 0.35, puffPaint);
      }
    }

    // Round 0: Inner Center Circle
    final centerColor = motif.rounds[0].color;
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, halfSize * 0.22, centerPaint);

    // Center eye dot
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
