import 'package:flutter/material.dart';

/// Local illustration used until an image-generation API is connected.
class SampleArtwork extends StatelessWidget {
  const SampleArtwork({super.key, required this.seed, this.radius = 22});
  final int seed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palettes = [
      const [Color(0xFFB8D4FF), Color(0xFFE7F0FF), Color(0xFF315BFF)],
      const [Color(0xFFFFD5B5), Color(0xFFFFF0DB), Color(0xFFE8844A)],
      const [Color(0xFFC4E8D8), Color(0xFFE9F7F0), Color(0xFF4C9A78)],
      const [Color(0xFFE0D2FA), Color(0xFFF5EEFF), Color(0xFF8465C9)],
    ][seed.abs() % 4];
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: palettes.take(2).toList(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 36,
              child: Icon(
                Icons.wb_sunny_rounded,
                color: Colors.white.withValues(alpha: .85),
                size: 34,
              ),
            ),
            Positioned(
              bottom: -8,
              left: -14,
              right: -12,
              child: Icon(
                Icons.landscape_rounded,
                size: 220,
                color: palettes[2],
              ),
            ),
            Positioned(
              bottom: 12,
              left: 40,
              right: 38,
              child: Icon(
                Icons.landscape_rounded,
                size: 135,
                color: palettes[2].withValues(alpha: .7),
              ),
            ),
            const Positioned(
              right: 28,
              top: 28,
              child: Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
