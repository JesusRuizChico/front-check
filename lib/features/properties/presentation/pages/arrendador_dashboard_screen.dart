import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front_check/data/mock_database.dart';
import 'package:front_check/domain/models/propiedad_model.dart';
import 'package:front_check/features/properties/presentation/widgets/propiedad_card.dart';
import 'package:front_check/features/properties/presentation/widgets/propiedad_detalle_sheet.dart';
import 'package:front_check/features/properties/presentation/widgets/theme_selector_sheet.dart';

class ArrendadorDashboardScreen extends StatefulWidget {
  const ArrendadorDashboardScreen({super.key});

  @override
  State<ArrendadorDashboardScreen> createState() => _ArrendadorDashboardScreenState();
}

class _ArrendadorDashboardScreenState extends State<ArrendadorDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';
  String _filtroEstado = 'Todas';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmarEliminar(Propiedad p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Propiedad'),
        content: Text('¿Estás seguro de que deseas eliminar "${p.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              mockDatabase.eliminarPropiedad(p.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Propiedad eliminada correctamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
    final usuario = mockDatabase.usuarioActual;
    final arrendadorId = usuario?.id ?? 1;

    return AnimatedBuilder(
      animation: mockDatabase,
      builder: (context, _) {
        final misPropiedades = mockDatabase.getMisPropiedades(arrendadorId);

        final filtradas = misPropiedades.where((p) {
          if (_filtroTexto.isNotEmpty) {
            final query = _filtroTexto.toLowerCase();
            final matchTitulo = p.titulo.toLowerCase().contains(query);
            final matchColonia = p.colonia.toLowerCase().contains(query);
            if (!matchTitulo && !matchColonia) return false;
          }
          if (_filtroEstado == 'Activas') return p.esActiva;
          if (_filtroEstado == 'Pausadas') return !p.esActiva;
          return true;
        }).toList();

        final totalActivas = misPropiedades.where((p) => p.esActiva).length;
        final totalPausadas = misPropiedades.length - totalActivas;
        final totalMensajes = mockDatabase.conversaciones
            .where((c) => c.otroUsuarioRol.toLowerCase().contains('arrendatario') || c.propiedadId != null)
            .length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Panel de Arrendador'),
            actions: [
              // Botón para cambiar a modo Arrendatario
              IconButton(
                tooltip: 'Ver como Inquilino / Explorar',
                icon: const Icon(Icons.explore_outlined),
                onPressed: () {
                  mockDatabase.setUsuarioActual(mockDatabase.usuarios[1]); // Ulises
                  context.go('/home');
                },
              ),
              // Botón de Tema
              IconButton(
                tooltip: 'Cambiar Tema',
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => ThemeSelectorSheet.show(context),
              ),
              // Bandeja de chats
              IconButton(
                tooltip: 'Mensajes',
                icon: Badge(
                  label: Text('${mockDatabase.conversaciones.length}'),
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                ),
                onPressed: () => context.push('/chats'),
              ),
              // Perfil
              IconButton(
                tooltip: 'Mi Perfil',
                icon: const Icon(Icons.account_circle_outlined, size: 28),
                onPressed: () => context.push('/perfil'),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              // Métricas rápidas
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.apartment_rounded,
                          color: theme.colorScheme.primary,
                          valor: '${misPropiedades.length}',
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
                          valor: '$totalMensajes',
                          etiqueta: 'Consultas',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Buscador
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

              // Filtros de estado (Todas, Activas, Pausadas)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: ['Todas', 'Activas', 'Pausadas'].map((st) {
                      final isSelected = _filtroEstado == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(st),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _filtroEstado = st);
                          },
                          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
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

              // Lista de propiedades del Arrendador
              if (filtradas.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined, size: 72, color: Colors.grey.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'No hay propiedades registradas',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text('Publica tu primer departamento usando el botón inferior.'),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/publicar-propiedad'),
                          icon: const Icon(Icons.add_home_rounded),
                          label: const Text('Publicar Propiedad Ahora'),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
                          onCambiarEstado: (nuevo) {
                            mockDatabase.cambiarEstadoPropiedad(p.id, nuevo);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Estado cambiado a "$nuevo".'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onEliminar: () => _confirmarEliminar(p),
                        );
                      },
                      childCount: filtradas.length,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/publicar-propiedad'),
            icon: const Icon(Icons.add_home_rounded),
            label: const Text('Publicar Propiedad'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String valor;
  final String etiqueta;

  const _MetricCard({
    required this.icon,
    required this.color,
    required this.valor,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            etiqueta,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
