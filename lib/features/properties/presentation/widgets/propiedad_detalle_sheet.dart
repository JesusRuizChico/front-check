import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/formato.dart';
import '../../../../core/widgets/avatar_usuario.dart';
import '../../../../core/widgets/avisos.dart';
import '../../../../core/widgets/imagen_red.dart';
import '../../../../domain/models/propiedad_model.dart';

/// Detalle completo de una propiedad. Si [onContactar] es nulo no se muestra el botón de chat.
class PropiedadDetalleSheet extends StatefulWidget {
  final Propiedad propiedad;
  final VoidCallback? onContactar;

  const PropiedadDetalleSheet({super.key, required this.propiedad, this.onContactar});

  static void show(BuildContext context, Propiedad propiedad, {VoidCallback? onContactar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PropiedadDetalleSheet(propiedad: propiedad, onContactar: onContactar),
    );
  }

  @override
  State<PropiedadDetalleSheet> createState() => _PropiedadDetalleSheetState();
}

class _PropiedadDetalleSheetState extends State<PropiedadDetalleSheet> {
  int _currentImageIndex = 0;

  Future<void> _copiarTelefono(String telefono) async {
    await Clipboard.setData(ClipboardData(text: telefono));
    if (mounted) Avisos.info(context, 'Teléfono copiado: $telefono');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.propiedad;
    final onContactar = widget.onContactar;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 240,
                          width: double.infinity,
                          child: p.imagenes.isEmpty
                              ? const ImagenRed(url: null)
                              : PageView.builder(
                                  itemCount: p.imagenes.length,
                                  onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                                  itemBuilder: (context, idx) => ImagenRed(url: p.imagenes[idx]),
                                ),
                        ),
                      ),
                      if (p.imagenes.length > 1)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
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
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${Formato.moneda(p.precioMensual)} / mes',
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
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(child: Text(p.direccionCompleta, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SpecItem(icon: Icons.bed_outlined, title: '${p.habitaciones}', subtitle: 'Recámaras'),
                        _SpecItem(icon: Icons.bathtub_outlined, title: '${p.banos}', subtitle: 'Baños'),
                        _SpecItem(
                          icon: Icons.directions_car_outlined,
                          title: '${p.estacionamientos}',
                          subtitle: 'Cajones',
                        ),
                        if (p.metrosCuadrados != null)
                          _SpecItem(
                            icon: Icons.square_foot_outlined,
                            title: p.metrosCuadrados!.toStringAsFixed(0),
                            subtitle: 'm² Totales',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Descripción de la propiedad',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(p.descripcion, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                  if (p.servicios.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    Text(
                      'Amenidades incluidas',
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
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        AvatarUsuario(nombre: p.arrendadorNombre, fotoUrl: p.arrendadorFoto, radio: 26),
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
                              Row(
                                children: [
                                  Icon(
                                    p.verificada ? Icons.verified_user_rounded : Icons.real_estate_agent_outlined,
                                    size: 14,
                                    color: p.verificada ? Colors.blue : theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    p.verificada ? 'Propiedad verificada' : 'Arrendador',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: p.verificada ? Colors.blue : theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              if (p.arrendadorTelefono != null) ...[
                                const SizedBox(height: 4),
                                Text(p.arrendadorTelefono!, style: theme.textTheme.bodySmall),
                              ],
                            ],
                          ),
                        ),
                        if (p.arrendadorTelefono != null)
                          IconButton(
                            icon: const Icon(Icons.copy_rounded),
                            tooltip: 'Copiar teléfono',
                            onPressed: () => _copiarTelefono(p.arrendadorTelefono!),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (onContactar != null)
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onContactar();
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Contactar por Chat'),
                  ),
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

  const _SpecItem({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
      ],
    );
  }
}
