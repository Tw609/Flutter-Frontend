import 'dart:math';

import 'package:flutter/material.dart';

// Brand colours, taken from the app icon.
const brandNavy = Color(0xFF0F1221);
const brandBlue = Color(0xFF8C98FE);
const brandViolet = Color(0xFFAB9BFE);
const brandGold = Color(0xFFFFC24D);

/// The Chitra AI logo: a crescent "C" with two sparkles.
///
/// With [animate] on, the crescent draws itself once, then the sparkles keep
/// twinkling. With it off, the finished logo is shown and nothing moves.
class ChitraLogo extends StatefulWidget {
  const ChitraLogo({super.key, this.size = 96, this.animate = true});

  final double size;
  final bool animate;

  @override
  State<ChitraLogo> createState() => _ChitraLogoState();
}

class _ChitraLogoState extends State<ChitraLogo> with TickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _draw.forward().whenComplete(() {
        if (mounted) _twinkle.repeat(reverse: true);
      });
    } else {
      _draw.value = 1;
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_draw, _twinkle]),
    builder: (context, child) => CustomPaint(
      size: Size.square(widget.size),
      painter: _LogoPainter(
        draw: Curves.easeOutCubic.transform(_draw.value),
        twinkle: Curves.easeInOut.transform(_twinkle.value),
      ),
    ),
  );
}

/// Everything is drawn in a 1 x 1 box and scaled to the widget size.
class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.draw, required this.twinkle});

  final double draw; // 0 to 1: how much of the crescent is drawn
  final double twinkle; // 0 to 1: sparkle pulse

  static const _center = Offset(0.405, 0.503);
  static const _radius = 0.29;
  static const _maxWidth = 0.15;
  static const _start = 42 * pi / 180; // round end of the crescent
  static const _sweep = 284 * pi / 180; // goes clockwise to the thin tip

  // Full width at the round end, then narrowing to a point at the tip.
  double _widthAt(double u) {
    if (u < 0.1) return _maxWidth;
    final t = (u - 0.1) / 0.9;
    return _maxWidth * pow(max(0.0, cos(pi / 2 * t)), 0.8);
  }

  Offset _onRing(double u, double offset) {
    final angle = _start + _sweep * u;
    final r = _radius + offset;
    return Offset(_center.dx + r * cos(angle), _center.dy + r * sin(angle));
  }

  Path _crescent() {
    const steps = 120;
    final last = (steps * draw).round();
    final outer = <Offset>[];
    final inner = <Offset>[];
    for (var i = 0; i <= last; i++) {
      final u = i / steps;
      outer.add(_onRing(u, _widthAt(u) / 2));
      inner.add(_onRing(u, -_widthAt(u) / 2));
    }
    final path = Path()..addPolygon([...outer, ...inner.reversed], true);
    // Rounded cap on the thick end.
    path.addOval(
      Rect.fromCircle(center: _onRing(0, 0), radius: _widthAt(0) / 2),
    );
    return path;
  }

  // A four-point sparkle with curved sides.
  Path _sparkle(Offset center, double radius) {
    const points = 64;
    const exponent = 2 / 0.75;
    double bend(double v) => v.sign * pow(v.abs(), exponent);
    final path = Path();
    for (var i = 0; i < points; i++) {
      final t = 2 * pi * i / points;
      final x = center.dx + radius * bend(cos(t));
      final y = center.dy + radius * bend(sin(t));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width, size.height);

    final crescentPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [brandBlue, brandViolet],
      ).createShader(const Rect.fromLTWH(0, 0, 1, 1));
    canvas.drawPath(_crescent(), crescentPaint);

    // The sparkles pop in at the end of the draw, then twinkle.
    final pop = ((draw - 0.7) / 0.3).clamp(0.0, 1.0);
    final popScale = Curves.easeOutBack.transform(pop);
    final bigScale = popScale * (1 + 0.10 * twinkle);
    final smallScale = popScale * (0.7 + 0.3 * (1 - twinkle));
    if (bigScale > 0) {
      canvas.drawPath(
        _sparkle(const Offset(0.800, 0.242), 0.110 * bigScale),
        Paint()..color = brandGold,
      );
      canvas.drawPath(
        _sparkle(const Offset(0.918, 0.371), 0.037 * smallScale),
        Paint()..color = const Color(0xFF9A9AFE),
      );
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.draw != draw || old.twinkle != twinkle;
}
