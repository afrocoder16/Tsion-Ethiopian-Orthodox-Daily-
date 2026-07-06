part of 'mezmur_screen.dart';

class _TrackArtPainter extends CustomPainter {
  const _TrackArtPainter({required this.seed, required this.size});
  final String seed;
  final double size;

  @override
  void paint(Canvas canvas, Size sz) {
    final v = _artVariant(seed);
    final bgPaint = Paint()
      ..color = v == 0
          ? const Color(0xFFECDFBB)
          : v == 1
          ? const Color(0xFFE4D5A8)
          : v == 2
          ? const Color(0xFFDDD0A0)
          : v == 3
          ? const Color(0xFFEAD9B0)
          : const Color(0xFFE7D4A5);
    canvas.drawRect(Rect.fromLTWH(0, 0, sz.width, sz.height), bgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF8A6A2E).withValues(alpha: 0.55)
      ..strokeWidth = sz.width * 0.018
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = sz.width / 2;
    final cy = sz.height / 2;
    final r = sz.width * 0.32;

    if (v == 0 || v == 3) {
      // Meskel cross with diamond
      final pts = [
        Offset(cx, cy - r * 1.1),
        Offset(cx + r * 0.35, cy - r * 0.55),
        Offset(cx + r * 1.1, cy),
        Offset(cx + r * 0.35, cy + r * 0.55),
        Offset(cx, cy + r * 1.1),
        Offset(cx - r * 0.35, cy + r * 0.55),
        Offset(cx - r * 1.1, cy),
        Offset(cx - r * 0.35, cy - r * 0.55),
      ];
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, linePaint);
      canvas.drawLine(
        Offset(cx, cy - r * 0.6),
        Offset(cx, cy + r * 0.6),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx - r * 0.6, cy),
        Offset(cx + r * 0.6, cy),
        linePaint,
      );
      canvas.drawCircle(
        Offset(cx, cy),
        sz.width * 0.04,
        Paint()..color = const Color(0xFF8A6A2E).withValues(alpha: 0.7),
      );
    } else if (v == 1) {
      // Arch / tabot form
      final archPath = Path()
        ..moveTo(cx - r, cy + r * 0.6)
        ..lineTo(cx - r, cy - r * 0.2)
        ..arcToPoint(
          Offset(cx + r, cy - r * 0.2),
          radius: Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(cx + r, cy + r * 0.6)
        ..close();
      canvas.drawPath(archPath, linePaint);
      canvas.drawLine(
        Offset(cx, cy - r * 0.6),
        Offset(cx, cy + r * 0.5),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx - r * 0.45, cy),
        Offset(cx + r * 0.45, cy),
        linePaint,
      );
    } else if (v == 2) {
      // Interlace grid
      final step = sz.width / 5;
      for (var i = 1; i < 5; i++) {
        canvas.drawLine(
          Offset(step * i, 0),
          Offset(step * i, sz.height),
          linePaint,
        );
        canvas.drawLine(
          Offset(0, step * i),
          Offset(sz.width, step * i),
          linePaint,
        );
      }
      canvas.drawLine(Offset(0, 0), Offset(sz.width, sz.height), linePaint);
      canvas.drawLine(Offset(sz.width, 0), Offset(0, sz.height), linePaint);
    } else {
      // Margin grid with central cross
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: r * 1.8,
          height: r * 1.8,
        ),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx, cy - r * 0.7),
        Offset(cx, cy + r * 0.7),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx - r * 0.7, cy),
        Offset(cx + r * 0.7, cy),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TrackArtPainter old) => old.seed != seed;
}

// Deterministic track artwork widget
class _TrackArt extends StatelessWidget {
  const _TrackArt({required this.seed, required this.size, this.radius = 10});
  final String seed;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _TrackArtPainter(seed: seed, size: size),
        size: Size(size, size),
      ),
    );
  }
}

// Artist avatar — illuminated initial with dotted coin border
class _ArtistAvatar extends StatelessWidget {
  const _ArtistAvatar({required this.name, required this.size});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AvatarCoinPainter(),
        child: Container(
          margin: EdgeInsets.all(size * 0.07),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFECDFBB), Color(0xFFD4BF88)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              color: _oxbloodDeep,
              fontSize: size * 0.38,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              fontFamily: 'Georgia',
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    final r = s.width / 2 - 1;
    final p = Paint()
      ..color = _gold.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    // outer ring
    canvas.drawCircle(Offset(cx, cy), r, p);
    // dot border
    const dots = 24;
    final dotPaint = Paint()
      ..color = _gold.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < dots; i++) {
      final angle = (i / dots) * 2 * pi;
      final dx = cx + (r - 3) * cos(angle);
      final dy = cy + (r - 3) * sin(angle);
      canvas.drawCircle(Offset(dx, dy), 1.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_AvatarCoinPainter old) => false;
}

// Small inline meskel cross (SVG-like via CustomPaint)
class _MeskelCrossIcon extends StatelessWidget {
  const _MeskelCrossIcon({this.size = 12, this.color = _gold});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CrossPainter(color: color)),
    );
  }
}

class _CrossPainter extends CustomPainter {
  const _CrossPainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = s.width * 0.14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s.width / 2, 0), Offset(s.width / 2, s.height), p);
    canvas.drawLine(Offset(0, s.height / 2), Offset(s.width, s.height / 2), p);
    canvas.drawCircle(
      Offset(s.width / 2, s.height / 2),
      s.width * 0.09,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CrossPainter old) => old.color != color;
}

// 8-pointed Meskel star — used as large watermark in hero card
class _StarCrossPainter extends CustomPainter {
  const _StarCrossPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    final r = s.width * 0.44;
    final p = Paint()
      ..color = color
      ..strokeWidth = s.width * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // 8 spokes at 45° intervals
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi - pi / 2;
      final innerR = r * 0.28;
      canvas.drawLine(
        Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
        Offset(cx + r * cos(angle), cy + r * sin(angle)),
        p,
      );
    }
    // outer circle
    canvas.drawCircle(Offset(cx, cy), r, p..strokeWidth = s.width * 0.018);
    // inner circle
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.28,
      p..strokeWidth = s.width * 0.018,
    );
    // cross overlay
    final cp = Paint()
      ..color = color
      ..strokeWidth = s.width * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - r * 0.22), Offset(cx, cy + r * 0.22), cp);
    canvas.drawLine(Offset(cx - r * 0.22, cy), Offset(cx + r * 0.22, cy), cp);
    canvas.drawCircle(Offset(cx, cy), s.width * 0.03, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StarCrossPainter old) => old.color != color;
}

// Instrument backdrop (subtle watermark for hero sections)
class _InstrumentBackdrop extends StatelessWidget {
  const _InstrumentBackdrop();
  static const double opacity = 0.07;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(painter: _BackdropPainter(), size: Size.infinite),
    );
  }
}

class _ParchmentThumbShape extends SliderComponentShape {
  const _ParchmentThumbShape({this.radius = 7});
  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(radius * 2, radius * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, radius, Paint()..color = _oxblood);
    canvas.drawCircle(center, radius - 2.5, Paint()..color = _screenBackground);
    canvas.drawCircle(
      center,
      radius - 2.5,
      Paint()
        ..color = _oxblood
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = _gold
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Begena (lyre) — top left rotated
    canvas.save();
    canvas.translate(s.width * 0.08, s.height * 0.1);
    canvas.rotate(-0.21);
    final lyreSz = s.width * 0.28;
    // box
    canvas.drawRect(
      Rect.fromLTWH(0, lyreSz * 0.55, lyreSz * 0.68, lyreSz * 0.35),
      p,
    );
    // arms
    canvas.drawLine(Offset(lyreSz * 0.06, lyreSz * 0.55), Offset(0, 0), p);
    canvas.drawLine(
      Offset(lyreSz * 0.62, lyreSz * 0.55),
      Offset(lyreSz * 0.68, 0),
      p,
    );
    canvas.drawLine(Offset(0, 0), Offset(lyreSz * 0.68, 0), p);
    for (var i = 1; i <= 5; i++) {
      canvas.drawLine(
        Offset(lyreSz * i / 6.5, 0),
        Offset(lyreSz * i / 6.5, lyreSz * 0.55),
        p,
      );
    }
    canvas.restore();

    // Kebero drum — bottom right rotated
    canvas.save();
    canvas.translate(s.width * 0.68, s.height * 0.6);
    canvas.rotate(0.26);
    final kSz = s.width * 0.22;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(kSz / 2, kSz * 0.15),
        width: kSz,
        height: kSz * 0.22,
      ),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(kSz / 2, kSz * 0.85),
        width: kSz * 0.7,
        height: kSz * 0.16,
      ),
      p,
    );
    canvas.drawLine(Offset(0, kSz * 0.15), Offset(kSz * 0.15, kSz * 0.85), p);
    canvas.drawLine(Offset(kSz, kSz * 0.15), Offset(kSz * 0.85, kSz * 0.85), p);
    canvas.restore();

    // Tsenatsel (sistrum) — center right
    canvas.save();
    canvas.translate(s.width * 0.62, s.height * 0.12);
    canvas.rotate(0.14);
    final tSz = s.width * 0.14;
    final uPath = Path()
      ..moveTo(0, tSz * 0.4)
      ..lineTo(0, tSz * 1.0)
      ..arcToPoint(
        Offset(tSz, tSz * 1.0),
        radius: Radius.circular(tSz / 2),
        clockwise: false,
      )
      ..lineTo(tSz, tSz * 0.4);
    canvas.drawPath(uPath, p);
    for (var i = 1; i <= 3; i++) {
      canvas.drawLine(
        Offset(-tSz * 0.1, tSz * i * 0.28),
        Offset(tSz * 1.1, tSz * i * 0.28),
        p,
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(tSz * 0.4, tSz * 1.0, tSz * 0.2, tSz * 0.6),
      p,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => false;
}

