import 'package:flutter/material.dart';

/// Isotipo de HabitaCheck: una casa con la marca de verificación.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colores.primary, colores.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colores.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.cottage_rounded, color: Colors.white, size: size * 0.62),
          Positioned(
            right: size * 0.1,
            bottom: size * 0.1,
            child: Container(
              padding: EdgeInsets.all(size * 0.025),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.check_circle_rounded, color: colores.primary, size: size * 0.26),
            ),
          ),
        ],
      ),
    );
  }
}
