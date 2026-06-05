import 'package:flutter/material.dart';
import '../../theme.dart';
import 'app_icon.dart';

class AppThumb extends StatelessWidget {
  final String color;
  final String glyph;
  final double size;
  final double? radius;
  final double? glyphSize;
  const AppThumb({
    super.key,
    this.color = 'blue',
    this.glyph = 'store',
    this.size = 52,
    this.radius,
    this.glyphSize,
  });

  @override
  Widget build(BuildContext context) {
    final c = kThumb[color] ?? kThumb['blue']!;
    final r = radius ?? AppRadii.sm;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(r),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: .18,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r),
                  gradient: const RadialGradient(
                    center: Alignment(0.4, -0.5),
                    radius: 0.8,
                    colors: [Colors.white, Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: AppIcon(glyph, size: glyphSize ?? (size * 0.46), color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class AvatarInitials extends StatelessWidget {
  final String name;
  final double size;
  final String color;
  const AvatarInitials({super.key, required this.name, this.size = 40, this.color = 'blue'});

  @override
  Widget build(BuildContext context) {
    final c = kThumb[color] ?? kThumb['blue']!;
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: c.bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(color: Colors.white, fontSize: size * .38, fontWeight: FontWeight.w800),
      ),
    );
  }
}
