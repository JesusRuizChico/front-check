import 'package:flutter/material.dart';

/// Mensaje centrado para listas vacías o errores de carga.
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? descripcion;
  final Widget? accion;

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.descripcion,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 72, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (descripcion != null) ...[
              const SizedBox(height: 6),
              Text(descripcion!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            ],
            if (accion != null) ...[const SizedBox(height: 20), accion!],
          ],
        ),
      ),
    );
  }
}
