import 'package:flutter/material.dart';

/// Imagen servida por el backend con indicador de carga y respaldo local.
class ImagenRed extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final IconData iconoRespaldo;

  const ImagenRed({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.iconoRespaldo = Icons.apartment_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final respaldo = _Respaldo(icono: iconoRespaldo);
    final direccion = url;
    if (direccion == null) return respaldo;
    return Image.network(
      direccion,
      fit: fit,
      errorBuilder: (_, _, _) => respaldo,
      loadingBuilder: (context, child, progreso) {
        if (progreso == null) return child;
        return Container(
          color: Theme.of(context).cardColor,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            value: progreso.expectedTotalBytes != null
                ? progreso.cumulativeBytesLoaded / progreso.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}

class _Respaldo extends StatelessWidget {
  final IconData icono;

  const _Respaldo({required this.icono});

  @override
  Widget build(BuildContext context) {
    final primario = Theme.of(context).colorScheme.primary;
    return Container(
      color: primario.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Icon(icono, size: 56, color: primario.withValues(alpha: 0.7)),
    );
  }
}
