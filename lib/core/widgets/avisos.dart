import 'package:flutter/material.dart';

/// Mensajes breves de resultado para el usuario.
class Avisos {
  const Avisos._();

  static void exito(BuildContext context, String mensaje) {
    _mostrar(context, mensaje, Icons.check_circle_rounded, Colors.green.shade700);
  }

  static void error(BuildContext context, Object error) {
    _mostrar(context, error.toString(), Icons.error_outline_rounded, Colors.red.shade700);
  }

  static void info(BuildContext context, String mensaje) {
    _mostrar(context, mensaje, Icons.info_outline_rounded, null);
  }

  static void _mostrar(BuildContext context, String mensaje, IconData icono, Color? color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icono, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(mensaje)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
