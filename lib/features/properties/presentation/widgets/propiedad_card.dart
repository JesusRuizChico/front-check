import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/mock_database.dart';
import '../../../../domain/models/propiedad_model.dart';

class PropiedadCard extends StatelessWidget {
  final Propiedad propiedad;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final bool esModoArrendador;
  final Function(String nuevoEstado)? onCambiarEstado;
  final VoidCallback? onEliminar;

  const PropiedadCard({
    super.key,
    required this.propiedad,
    required this.onTap,
    this.onFavoriteToggle,
    this.esModoArrendador = false,
    this.onCambiarEstado,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esActiva = propiedad.esActiva;

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
            // Imagen con badges y botón de favorito
            Stack(
              children: [
                Hero(
                  tag: 'prop_img_${propiedad.id}',
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      propiedad.imagenPrincipal,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        child: const Center(child: Icon(Icons.apartment_rounded, size: 64)),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: theme.cardColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Gradiente oscuro inferior para texto
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                ),

                // Badge de estado (Activa / Inactiva)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: esActiva
                          ? const Color(0xFF059669)
                          : Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          propiedad.estado.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botón de Favorito o Menú de Opciones
                Positioned(
                  top: 8,
                  right: 8,
                  child: esModoArrendador
                      ? PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                          ),
                          onSelected: (val) {
                            if (val == 'toggle') {
                              onCambiarEstado?.call(esActiva ? 'inactiva' : 'activa');
                            } else if (val == 'delete') {
                              onEliminar?.call();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(
                                    esActiva ? Icons.visibility_off : Icons.visibility,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(esActiva ? 'Pausar publicación' : 'Activar publicación'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Eliminar propiedad', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              propiedad.esFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: propiedad.esFavorito ? Colors.redAccent : Colors.white,
                            ),
                            onPressed: onFavoriteToggle ?? () => mockDatabase.toggleFavorito(propiedad.id),
                          ),
                        ),
                ),

                // Precio Badge en la parte inferior de la imagen
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
                      '\$${propiedad.precioMensual.toStringAsFixed(0)} / mes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Detalles y descripción
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    propiedad.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
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

                  // Fila de amenidades (Habitaciones, Baños, Estacionamiento, M2)
                  Row(
                    children: [
                      _FeaturePill(
                        icon: Icons.bed_outlined,
                        label: '${propiedad.habitaciones} Hab',
                      ),
                      const SizedBox(width: 8),
                      _FeaturePill(
                        icon: Icons.bathtub_outlined,
                        label: '${propiedad.banos} Baño${propiedad.banos > 1 ? 's' : ''}',
                      ),
                      const SizedBox(width: 8),
                      _FeaturePill(
                        icon: Icons.directions_car_outlined,
                        label: '${propiedad.estacionamientos} Est',
                      ),
                      const SizedBox(width: 8),
                      _FeaturePill(
                        icon: Icons.square_foot_outlined,
                        label: '${propiedad.metrosCuadrados.toInt()} m²',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Botones de acción inferiores
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
                      if (!esModoArrendador) ...[
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            final miId = mockDatabase.usuarioActual?.id ?? 2;
                            final conv = mockDatabase.obtenerOIniciarConversacion(
                              miUsuarioId: miId,
                              otroUsuarioId: propiedad.arrendadorId,
                              otroUsuarioNombre: propiedad.arrendadorNombre,
                              propiedadId: propiedad.id,
                              propiedadTitulo: propiedad.titulo,
                            );
                            context.push('/chat-detail', extra: conv.id);
                          },
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
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

