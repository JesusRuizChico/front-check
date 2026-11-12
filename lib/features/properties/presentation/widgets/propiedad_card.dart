import 'package:flutter/material.dart';

import '../../../../core/utils/formato.dart';
import '../../../../core/widgets/imagen_red.dart';
import '../../../../domain/models/propiedad_model.dart';

/// Tarjeta de una propiedad. Solo presenta datos: las acciones llegan por callbacks.
class PropiedadCard extends StatelessWidget {
  final Propiedad propiedad;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onChat;
  final bool esModoArrendador;
  final ValueChanged<String>? onCambiarEstado;
  final VoidCallback? onEliminar;

  const PropiedadCard({
    super.key,
    required this.propiedad,
    required this.onTap,
    this.onFavoriteToggle,
    this.onChat,
    this.esModoArrendador = false,
    this.onCambiarEstado,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'prop_img_${propiedad.id}_${esModoArrendador ? 'a' : 'i'}',
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ImagenRed(url: propiedad.imagenPrincipal),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(top: 12, left: 12, child: _EstadoBadge(propiedad: propiedad)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: esModoArrendador ? _menuArrendador(theme) : _botonFavorito(),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${Formato.moneda(propiedad.precioMensual)} / mes',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                if (propiedad.imagenes.length > 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${propiedad.imagenes.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    propiedad.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${propiedad.colonia}, ${propiedad.municipio}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _FeaturePill(icon: Icons.bed_outlined, label: '${propiedad.habitaciones} Hab'),
                      _FeaturePill(
                        icon: Icons.bathtub_outlined,
                        label: '${propiedad.banos} Baño${propiedad.banos == 1 ? '' : 's'}',
                      ),
                      _FeaturePill(
                        icon: Icons.directions_car_outlined,
                        label: '${propiedad.estacionamientos} Est',
                      ),
                      if (propiedad.metrosCuadrados != null)
                        _FeaturePill(
                          icon: Icons.square_foot_outlined,
                          label: '${propiedad.metrosCuadrados!.toStringAsFixed(0)} m²',
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.info_outline_rounded, size: 18),
                          label: const Text('Ver Detalles'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      if (!esModoArrendador && onChat != null) ...[
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: onChat,
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: const Text('Chat'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonFavorito() {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
      child: IconButton(
        tooltip: propiedad.esFavorito ? 'Quitar de favoritos' : 'Guardar en favoritos',
        icon: Icon(
          propiedad.esFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: propiedad.esFavorito ? Colors.redAccent : Colors.white,
        ),
        onPressed: onFavoriteToggle,
      ),
    );
  }

  Widget _menuArrendador(ThemeData theme) {
    final esActiva = propiedad.esActiva;
    return PopupMenuButton<String>(
      tooltip: 'Opciones',
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
      ),
      onSelected: (valor) {
        if (valor == 'eliminar') {
          onEliminar?.call();
        } else {
          onCambiarEstado?.call(valor);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: esActiva ? Propiedad.estadoPausada : Propiedad.estadoDisponible,
          child: Row(
            children: [
              Icon(esActiva ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(esActiva ? 'Pausar publicación' : 'Activar publicación'),
            ],
          ),
        ),
        if (propiedad.estado != Propiedad.estadoRentada)
          PopupMenuItem(
            value: Propiedad.estadoRentada,
            child: Row(
              children: [
                Icon(Icons.key_rounded, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                const Text('Marcar como rentada'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'eliminar',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Eliminar propiedad', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final Propiedad propiedad;

  const _EstadoBadge({required this.propiedad});

  @override
  Widget build(BuildContext context) {
    final color = switch (propiedad.estado) {
      Propiedad.estadoDisponible => const Color(0xFF059669),
      Propiedad.estadoRentada => const Color(0xFF2563EB),
      _ => Colors.amber.shade700,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            propiedad.etiquetaEstado.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
