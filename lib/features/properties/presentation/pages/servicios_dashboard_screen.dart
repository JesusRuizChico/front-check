import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front_check/data/mock_database.dart';
import 'package:front_check/domain/models/servicio_model.dart';
import 'package:front_check/features/properties/presentation/widgets/theme_selector_sheet.dart';

class ServiciosDashboardScreen extends StatefulWidget {
  final bool esSubpantalla;

  const ServiciosDashboardScreen({
    super.key,
    this.esSubpantalla = false,
  });

  @override
  State<ServiciosDashboardScreen> createState() => _ServiciosDashboardScreenState();
}

class _ServiciosDashboardScreenState extends State<ServiciosDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _abrirChatConEspecialista(ServicioMantenimiento s) {
    final miId = mockDatabase.usuarioActual?.id ?? 2;
    final conv = mockDatabase.obtenerOIniciarConversacion(
      miUsuarioId: miId,
      otroUsuarioId: s.id + 10,
      otroUsuarioNombre: s.nombre,
      otroUsuarioFoto: s.fotoUrl,
      otroUsuarioRol: s.especialidad,
      propiedadTitulo: 'Servicio de ${s.especialidad}',
    );
    context.push('/chat-detail', extra: conv.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final especialistas = mockDatabase.serviciosMantenimiento.where((s) {
      if (_filtro.isNotEmpty) {
        final q = _filtro.toLowerCase();
        final matchNombre = s.nombre.toLowerCase().contains(q);
        final matchEsp = s.especialidad.toLowerCase().contains(q);
        final matchDesc = s.descripcion.toLowerCase().contains(q);
        if (!matchNombre && !matchEsp && !matchDesc) return false;
      }
      return true;
    }).toList();

    final bodyContent = CustomScrollView(
      slivers: [
        // Banner informativo
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.secondary,
                    theme.colorScheme.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Mantenimiento y Reparaciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Técnicos certificados para tu departamento o casa en renta.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.handyman_rounded, color: Colors.white, size: 44),
                ],
              ),
            ),
          ),
        ),

        // Buscador
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filtro = val),
              decoration: InputDecoration(
                hintText: 'Buscar por plomero, electricista, cerrajero...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _filtro.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filtro = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),

        // Título de sección
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Especialistas Certificados',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Lista de Técnicos
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final esp = especialistas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(esp.fotoUrl),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        esp.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: esp.disponible
                                              ? Colors.green.withOpacity(0.15)
                                              : Colors.grey.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 8,
                                              color: esp.disponible ? Colors.green : Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              esp.disponible ? 'Disponible' : 'Ocupado',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: esp.disponible ? Colors.green : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    esp.especialidad,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${esp.calificacion}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${esp.trabajosRealizados} servicios)',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          esp.descripcion,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                        const SizedBox(height: 12),

                        // Chips de servicios ofrecidos
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: esp.serviciosOfrecidos.map((so) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                              ),
                              child: Text(so, style: const TextStyle(fontSize: 11)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Tarifa y botones de contacto
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tarifa diagnóstico:', style: theme.textTheme.bodySmall),
                                Text(
                                  '\$${esp.tarifaBase.toInt()} MXN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton.outlined(
                                  icon: const Icon(Icons.phone_rounded, color: Colors.green),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Llamando a ${esp.nombre} (${esp.telefono})...'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _abrirChatConEspecialista(esp),
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                                  label: const Text('Contactar'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: especialistas.length,
            ),
          ),
        ),
      ],
    );

    if (widget.esSubpantalla) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Directorio de Servicios'),
          actions: [
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Cambiar Tema',
              onPressed: () => ThemeSelectorSheet.show(context),
            ),
          ],
        ),
        body: bodyContent,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Servicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar Tema',
            onPressed: () => ThemeSelectorSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: () => context.push('/perfil'),
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}
