import 'package:flutter/material.dart';

import '../../../../core/widgets/app_logo.dart';

/// Pantalla breve mientras se verifica si hay una sesión activa.
class CargaScreen extends StatelessWidget {
  const CargaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 88),
            SizedBox(height: 28),
            SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ),
      ),
    );
  }
}
