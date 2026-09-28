import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/welcome_action_button.dart';

const _ivory = Color(0xFFF7F5F1);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ivory,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep a portrait composition on desktop; short screens can scroll.
            final width = constraints.maxWidth > 600
                ? math.min(
                    480.0, math.max(320.0, constraints.maxHeight * 430 / 956))
                : constraints.maxWidth;
            final height = math.max(constraints.maxHeight, width * 956 / 430);
            final scale = width / 430;
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final buttonHeight =
                math.max(60.0, 74 * scale) * math.max(1.0, textScale);

            return SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: width,
                  height: height + math.max(0.0, textScale - 1) * 160,
                  child: ClipRect(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ExcludeSemantics(
                            child: CustomPaint(painter: _WelcomeBackground()),
                          ),
                        ),
                        Positioned(
                          left: width * .022,
                          top: height * .205,
                          width: width * .978,
                          height: height * .51,
                          child: ClipPath(
                            clipper: _VillaClipper(),
                            child: Image.asset(
                              'assets/images/welcome-villa.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              excludeFromSemantics: true,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        Positioned(
                          left: width * .705,
                          top: height * .187,
                          width: width * .21,
                          height: height * .112,
                          child: const ExcludeSemantics(
                            child: FittedBox(
                              child: Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFE9EFF5),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: width * .075,
                          right: width * .075,
                          top: height * .742,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              WelcomeActionButton(
                                label: 'comenzar ahora',
                                primary: true,
                                height: buttonHeight,
                                scale: scale,
                                onPressed: () => context.push('/register'),
                              ),
                              SizedBox(height: 20 * scale),
                              WelcomeActionButton(
                                label: 'ya tengo una cuenta',
                                height: math.max(52.0, 58 * scale) *
                                    math.max(1.0, textScale),
                                scale: scale,
                                onPressed: () => context.push('/login'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VillaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w, h * .10)
      ..cubicTo(w * .70, -h * .07, w * .38, -h * .03, w * .16, h * .18)
      ..cubicTo(-w * .05, h * .38, -w * .02, h * .61, w * .11, h * .77)
      ..cubicTo(w * .28, h * .96, w * .63, h * .96, w, h)
      ..close();
  }

  @override
  bool shouldReclip(_VillaClipper oldClipper) => false;
}

class _WelcomeBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 430, size.height / 956);

    final upperShape = Path()
      ..moveTo(430, 78)
      ..cubicTo(322, 57, 203, 116, 205, 219)
      ..cubicTo(216, 305, 348, 333, 430, 338)
      ..close();
    canvas.drawPath(
      upperShape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDE6ED), Color(0xFFCBDCE9)],
        ).createShader(const Rect.fromLTWH(205, 75, 225, 270)),
    );
    canvas.drawOval(
      const Rect.fromLTWH(270, 140, 147, 169),
      Paint()..color = const Color(0xFFAFC6DA),
    );
    canvas.drawPath(
      Path()
        ..moveTo(8, 434)
        ..cubicTo(4, 282, 91, 156, 245, 127),
      Paint()
        ..color = const Color(0xFFBDCFDF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9,
    );

    final bottomWave = Path()
      ..moveTo(0, 839)
      ..cubicTo(26, 905, 85, 888, 157, 916)
      ..cubicTo(196, 931, 226, 941, 250, 956)
      ..lineTo(0, 956)
      ..close();
    canvas.drawPath(
      bottomWave,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFD6E3EC), Color(0xFFC4D6E6)],
        ).createShader(const Rect.fromLTWH(0, 839, 250, 117)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WelcomeBackground oldDelegate) => false;
}
