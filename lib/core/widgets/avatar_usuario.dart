import 'package:flutter/material.dart';

/// Foto de perfil o, si no existe, la inicial del nombre.
class AvatarUsuario extends StatelessWidget {
  final String nombre;
  final String? fotoUrl;
  final double radio;

  const AvatarUsuario({super.key, required this.nombre, this.fotoUrl, this.radio = 24});

  @override
  Widget build(BuildContext context) {
    final primario = Theme.of(context).colorScheme.primary;
    final inicial = nombre.trim().isNotEmpty ? nombre.trim()[0].toUpperCase() : '?';
    final foto = fotoUrl;
    return CircleAvatar(
      radius: radio,
      backgroundColor: primario.withValues(alpha: 0.2),
      foregroundImage: foto != null ? NetworkImage(foto) : null,
      onForegroundImageError: foto != null ? (_, _) {} : null,
      child: Text(
        inicial,
        style: TextStyle(fontSize: radio * 0.8, fontWeight: FontWeight.bold, color: primario),
      ),
    );
  }
}
