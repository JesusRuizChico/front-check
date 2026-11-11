import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/mock_database.dart';
import '../../../../domain/models/propiedad_model.dart';

class PropiedadDetalleSheet extends StatefulWidget {
  final Propiedad propiedad;

  const PropiedadDetalleSheet({super.key, required this.propiedad});

  static void show(BuildContext context, Propiedad propiedad) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PropiedadDetalleSheet(propiedad: propiedad),
    );
  }

  @override
  State<PropiedadDetalleSheet> createState() => _PropiedadDetalleSheetState();
}

class _PropiedadDetalleSheetState extends State<PropiedadDetalleSheet> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.propiedad;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Galería de fotos con PageView
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 240,
                          width: double.infinity,
                          child: PageView.builder(
                            itemCount: p.imagenes.isNotEmpty ? p.imagenes.length : 1,
                            onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                            itemBuilder: (context, idx) {
                              final imgUrl = p.imagenes.isNotEmpty ? p.imagenes[idx] : p.imagenPrincipal;
                              return Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  child: const Center(child: Icon(Icons.apartment, size: 50)),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Contador de fotos
                      if (p.imagenes.length > 1)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1} / ${p.imagenes.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Precio y Título
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          p.titulo,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '\$${p.precioMensual.toStringAsFixed(0)} / mes',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Ubicación
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          p.direccionCompleta,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Especificaciones en Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SpecItem(icon: Icons.bed_outlined, title: '${p.habitaciones}', subtitle: 'Recámaras'),
                        _SpecItem(icon: Icons.bathtub_outlined, title: '${p.banos}', subtitle: 'Baños'),
                        _SpecItem(icon: Icons.directions_car_outlined, title: '${p.estacionamientos}', subtitle: 'Cajones'),
                        _SpecItem(icon: Icons.square_foot_outlined, title: '${p.metrosCuadrados.toInt()}', subtitle: 'm² Totales'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Descripción
                  Text(
                    'Descripción de la propiedad',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.descripcion,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 22),

                  // Servicios / Amenidades
                  Text(
                    'Servicios y Amenidades',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.servicios.map((s) {
                      return Chip(
                        avatar: Icon(Icons.check_circle_outline, size: 16, color: theme.colorScheme.primary),
                        label: Text(s),
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Tarjeta del Arrendador
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                          child: Text(
                            p.arrendadorNombre.isNotEmpty ? p.arrendadorNombre[0] : 'A',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.arrendadorNombre,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              const Row(
                                children: [
                                  Icon(Icons.verified_user_rounded, size: 14, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Text(
                                    'Arrendador Verificado',
                                    style: TextStyle(fontSize: 12, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone_rounded, color: Colors.green),
                          tooltip: 'Llamar',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Llamando a ${p.arrendadorNombre}...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Botón inferior fijo de contacto / chat
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        final miId = mockDatabase.usuarioActual?.id ?? 2;
                        final conv = mockDatabase.obtenerOIniciarConversacion(
                          miUsuarioId: miId,
                          otroUsuarioId: p.arrendadorId,
                          otroUsuarioNombre: p.arrendadorNombre,
                          propiedadId: p.id,
                          propiedadTitulo: p.titulo,
                        );
                        context.push('/chat-detail', extra: conv.id);
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text('Contactar por Chat'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SpecItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

