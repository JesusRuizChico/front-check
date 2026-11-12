import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/rutas.dart';
import '../../../../core/widgets/avisos.dart';
import '../../../../core/widgets/estado_vacio.dart';
import '../../../../domain/models/propiedad_model.dart';
import '../../../auth/presentation/widgets/boton_cerrar_sesion.dart';
import '../../../chat/application/conversaciones_controller.dart';
import '../../application/mis_propiedades_controller.dart';
import '../widgets/propiedad_card.dart';
import '../widgets/propiedad_detalle_sheet.dart';
import '../widgets/theme_selector_sheet.dart';

/// Panel del arrendador con sus publicaciones.
class ArrendadorDashboardScreen extends ConsumerStatefulWidget {
  const ArrendadorDashboardScreen({super.key});

  @override
  ConsumerState<ArrendadorDashboardScreen> createState() => _ArrendadorDashboardScreenState();
}

class _ArrendadorDashboardScreenState extends ConsumerState<ArrendadorDashboardScreen> {
  static const _todas = 'Todas';
  static const _activas = 'Activas';
  static const _pausadas = 'Pausadas';

  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';
  String _filtroEstado = _todas;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Propiedad> _filtrar(List<Propiedad> propiedades) {
    final consulta = _filtroTexto.toLowerCase().trim();
    return propiedades.where((p) {
      if (consulta.isNotEmpty &&
          !p.titulo.toLowerCase().contains(consulta) &&
          !p.colonia.toLowerCase().contains(consulta)) {
        return false;
      }
      if (_filtroEstado == _activas) return p.esActiva;
      if (_filtroEstado == _pausadas) return !p.esActiva;
      return true;
    }).toList();
  }

  Future<void> _cambiarEstado(Propiedad propiedad, String nuevoEstado) async {
    try {
      await ref.read(misPropiedadesProvider.notifier).cambiarEstado(propiedad.id, nuevoEstado);
      if (mounted) Avisos.exito(context, 'Estado cambiado a "${propiedad.copyWith(estado: nuevoEstado).etiquetaEstado}".');
    } catch (error) {
      if (mounted) Avisos.error(context, error);
    }
  }

  void _confirmarEliminar(Propiedad p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Propiedad'),
        content: Text('¿Estás seguro de que deseas eliminar "${p.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(misPropiedadesProvider.notifier).eliminar(p.id);
                if (mounted) Avisos.exito(context, 'Propiedad eliminada correctamente');
              } catch (error) {
                if (mounted) Avisos.error(context, error);
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final misPropiedades = ref.watch(misPropiedadesProvider);
    final conversaciones = ref.watch(conversacionesProvider).value ?? const [];
    final totalNoLeidos = ref.watch(mensajesNoLeidosProvider);
    final lista = misPropiedades.value ?? const <Propiedad>[];
    final totalActivas = lista.where((p) => p.esActiva).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arrendador'),
        actions: [
          IconButton(
            tooltip: 'Cambiar Tema',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => ThemeSelectorSheet.show(context),
          ),
          IconButton(
            tooltip: 'Mensajes',
            icon: Badge(
              label: Text('$totalNoLeidos'),
              isLabelVisible: totalNoLeidos > 0,
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            onPressed: () => context.push(Rutas.chats),
          ),
          IconButton(
            tooltip: 'Mi Perfil',
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () => context.push(Rutas.perfil),
          ),
          const BotonCerrarSesion(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(misPropiedadesProvider.notifier).refrescar(),
            ref.read(conversacionesProvider.notifier).refrescar(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.apartment_rounded,
                        color: theme.colorScheme.primary,
                        valor: '${lista.length}',
                        etiqueta: 'Propiedades',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.check_circle_outline_rounded,
                        color: Colors.green,
                        valor: '$totalActivas',
                        etiqueta: 'Publicadas',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.chat_outlined,
                        color: Colors.orange,
                        valor: '${conversaciones.length}',
                        etiqueta: 'Consultas',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _filtroTexto = val),
                  decoration: InputDecoration(
                    hintText: 'Buscar en mis propiedades...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _filtroTexto.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _filtroTexto = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [_todas, _activas, _pausadas].map((st) {
                    final isSelected = _filtroEstado == st;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(st),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _filtroEstado = st);
                        },
                        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            ...misPropiedades.when(
              loading: () => [
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EstadoVacio(
                    icono: Icons.cloud_off_rounded,
                    titulo: 'No se pudieron cargar tus propiedades',
                    descripcion: error.toString(),
                    accion: OutlinedButton(
                      onPressed: () => ref.read(misPropiedadesProvider.notifier).refrescar(),
                      child: const Text('Reintentar'),
                    ),
                  ),
                ),
              ],
              data: (propiedades) => _seccionPropiedades(propiedades),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Rutas.publicarPropiedad),
        icon: const Icon(Icons.add_home_rounded),
        label: const Text('Publicar Propiedad'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  List<Widget> _seccionPropiedades(List<Propiedad> propiedades) {
    final filtradas = _filtrar(propiedades);
    if (filtradas.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EstadoVacio(
            icono: Icons.home_outlined,
            titulo: propiedades.isEmpty ? 'No hay propiedades registradas' : 'Sin resultados',
            descripcion: propiedades.isEmpty
                ? 'Publica tu primer departamento usando el botón inferior.'
                : 'Ninguna propiedad coincide con el filtro.',
            accion: propiedades.isEmpty
                ? ElevatedButton.icon(
                    onPressed: () => context.push(Rutas.publicarPropiedad),
                    icon: const Icon(Icons.add_home_rounded),
                    label: const Text('Publicar Propiedad Ahora'),
                  )
                : null,
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final p = filtradas[index];
              return PropiedadCard(
                propiedad: p,
                esModoArrendador: true,
                onTap: () => PropiedadDetalleSheet.show(context, p),
                onCambiarEstado: (nuevo) => _cambiarEstado(p, nuevo),
                onEliminar: () => _confirmarEliminar(p),
              );
            },
            childCount: filtradas.length,
          ),
        ),
      ),
    ];
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String valor;
  final String etiqueta;

  const _MetricCard({required this.icon, required this.color, required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(etiqueta, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
