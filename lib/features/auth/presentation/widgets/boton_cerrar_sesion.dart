import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sesion_controller.dart';

/// Botón de cierre de sesión con confirmación, visible en las barras superiores.
/// Al cerrar sesión el router regresa a la pantalla de bienvenida.
class BotonCerrarSesion extends ConsumerWidget {
  const BotonCerrarSesion({super.key});

  Future<void> _confirmarYCerrar(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar == true) await ref.read(sesionProvider.notifier).cerrarSesion();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Cerrar Sesión',
      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
      onPressed: () => _confirmarYCerrar(context, ref),
    );
  }
}
