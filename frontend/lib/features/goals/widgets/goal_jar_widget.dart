import 'dart:math';
import 'package:flutter/material.dart';

class GoalJarWidget extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final double width;
  final double height;

  const GoalJarWidget({
    super.key,
    required this.progress,
    this.width = 180,
    this.height = 230,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _JarPainter(progress: progress.clamp(0.0, 1.0)),
        size: Size(width, height),
      );
}

class _JarPainter extends CustomPainter {
  final double progress;

  const _JarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Geometry ──────────────────────────────────────────────
    final lidW = w * 0.52;
    final lidLeft = (w - lidW) / 2;
    const lidTop = 0.0;
    final lidBottom = h * 0.10;

    final neckW = w * 0.44;
    final neckLeft = (w - neckW) / 2;
    final neckTop = lidBottom - 2;
    final neckBottom = h * 0.20;

    final bodyW = w * 0.82;
    final bodyLeft = (w - bodyW) / 2;
    final bodyTop = neckBottom - 4.0;
    final bodyBottom = h * 0.94;
    final bodyH = bodyBottom - bodyTop;

    final bodyRRect = RRect.fromLTRBR(
      bodyLeft, bodyTop, bodyLeft + bodyW, bodyBottom,
      const Radius.circular(20),
    );

    // ── Jar drop shadow ───────────────────────────────────────
    canvas.drawRRect(
      bodyRRect.shift(const Offset(0, 10)),
      Paint()
        ..color = Colors.black.withOpacity(0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // ── Coin fill (clipped to body) ───────────────────────────
    if (progress > 0) {
      final fillH = bodyH * progress;
      final fillTop = bodyBottom - fillH;

      canvas.save();
      canvas.clipRRect(bodyRRect);

      // Warm fill gradient
      canvas.drawRect(
        Rect.fromLTRB(bodyLeft, fillTop, bodyLeft + bodyW, bodyBottom),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8A020).withOpacity(0.18),
              const Color(0xFFD4900A).withOpacity(0.38),
            ],
          ).createShader(
              Rect.fromLTRB(bodyLeft, fillTop, bodyLeft + bodyW, bodyBottom)),
      );

      // Coins
      _drawCoins(canvas, bodyLeft, fillTop, bodyW, bodyBottom - fillTop);

      canvas.restore();
    }

    // ── Glass body ────────────────────────────────────────────
    canvas.drawRRect(
      bodyRRect,
      Paint()..color = const Color(0xFFDCEFF8).withOpacity(0.45),
    );

    // Glass outline
    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..color = const Color(0xFFA8C8DC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // ── Neck ──────────────────────────────────────────────────
    final neckRRect = RRect.fromLTRBR(
      neckLeft, neckTop, neckLeft + neckW, neckBottom + 4,
      const Radius.circular(6),
    );
    canvas.drawRRect(
      neckRRect,
      Paint()..color = const Color(0xFFDCEFF8).withOpacity(0.45),
    );
    canvas.drawRRect(
      neckRRect,
      Paint()
        ..color = const Color(0xFFA8C8DC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ── Lid ───────────────────────────────────────────────────
    final lidRRect = RRect.fromLTRBR(
      lidLeft, lidTop, lidLeft + lidW, lidBottom + 4,
      const Radius.circular(8),
    );
    canvas.drawRRect(
      lidRRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD8C888), Color(0xFFA89848)],
        ).createShader(Rect.fromLTRB(lidLeft, lidTop, lidLeft + lidW, lidBottom)),
    );
    canvas.drawRRect(
      lidRRect,
      Paint()
        ..color = const Color(0xFF887828)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── Glass highlights ──────────────────────────────────────
    final hl1 = Paint()
      ..color = Colors.white.withOpacity(0.52)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(bodyLeft + 15, bodyTop + 18),
      Offset(bodyLeft + 15, bodyBottom - 28),
      hl1,
    );

    final hl2 = Paint()
      ..color = Colors.white.withOpacity(0.30)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(bodyLeft + 26, bodyTop + 18),
      Offset(bodyLeft + 26, bodyTop + 70),
      hl2,
    );
  }

  void _drawCoins(Canvas canvas, double left, double top, double w, double h) {
    final rng = Random(42);
    final count = (progress * 16).round().clamp(1, 16);

    for (var i = 0; i < count; i++) {
      final cx = left + 14 + rng.nextDouble() * (w - 28);
      final cy = top + 10 + rng.nextDouble() * (h - 20);
      final rx = 8.0 + rng.nextDouble() * 5;
      final ry = rx * 0.38;

      // Shadow
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + 2, cy + 3), width: rx * 2.3, height: ry * 1.1),
        Paint()..color = Colors.black.withOpacity(0.16),
      );
      // Coin bottom edge
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, cy + ry * 0.4),
            width: rx * 2,
            height: ry * 0.85),
        Paint()..color = const Color(0xFFA87820),
      );
      // Coin face
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry),
        Paint()..color = const Color(0xFFFFCC22),
      );
      // Shine
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx - rx * 0.22, cy - ry * 0.08),
            width: rx * 0.55,
            height: ry * 0.32),
        Paint()..color = Colors.white.withOpacity(0.52),
      );
    }
  }

  @override
  bool shouldRepaint(_JarPainter old) => old.progress != progress;
}
