import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/rutas.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/avisos.dart';
import '../../../../core/widgets/estado_vacio.dart';
import '../../../../domain/models/propiedad_model.dart';
import '../../../auth/application/sesion_controller.dart';
import '../../../auth/presentation/widgets/boton_cerrar_sesion.dart';
import '../../../chat/application/abrir_chat_propiedad.dart';
import '../../../chat/application/conversaciones_controller.dart';
import '../../../chat/presentation/pages/chat_detail_screen.dart';
import '../../../chat/presentation/pages/chat_list_screen.dart';
import '../../application/catalogo_controller.dart';
import '../../application/favoritos_controller.dart';
import '../../application/filtro_propiedades.dart';
import '../widgets/filtros_propiedades_sheet.dart';
import '../widgets/propiedad_card.dart';
import '../widgets/propiedad_detalle_sheet.dart';
import '../widgets/theme_selector_sheet.dart';

/// Panel del inquilino: catálogo, favoritos y chats.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _categorias = [
    FiltroPropiedades.todas,
    'Wi-Fi',
    'Pet Friendly',
    'Alberca',
    'Seguridad 24/7',
    'Amueblado',
    'Gimnasio',
  ];

  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  FiltroPropiedades _filtros = const FiltroPropiedades();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _alternarFavorito(Propiedad propiedad) async {
    try {
      await ref.read(favoritosProvider.notifier).alternar(propiedad);
    } catch (error) {
      if (mounted) Avisos.error(context, error);
    }
  }

  Future<void> _contactar(Propiedad propiedad) async {
    try {
      final chat = await ref.read(abrirChatPropiedadProvider).ejecutar(propiedad.id);
      if (!mounted) return;
      context.push(
        Rutas.chat,
        extra: ChatArgs(
          destino: chat.destino,
          nombre: chat.arrendador.nombre,
          fotoUrl: chat.arrendador.fotoUrl,
          rol: 'Arrendador',
          propiedadTitulo: propiedad.titulo,
        ),
      );
    } catch (error) {
      if (mounted) Avisos.error(context, error);
    }
  }

  void _verDetalle(Propiedad propiedad) {
    PropiedadDetalleSheet.show(context, propiedad, onContactar: () => _contactar(propiedad));
  }

  Future<void> _abrirFiltros() async {
    final resultado =
        await FiltrosPropiedadesSheet.show(context, inicial: _filtros);
    if (!mounted || resultado == null) return;
    setState(() => _filtros = resultado);
  }

  void _actualizarFiltro({String? texto, String? amenidad}) {
    _filtros = FiltroPropiedades(
      texto: texto ?? _filtros.texto,
      amenidad: amenidad ?? _filtros.amenidad,
      precioMinimo: _filtros.precioMinimo,
      precioMaximo: _filtros.precioMaximo,
      habitacionesMinimas: _filtros.habitacionesMinimas,
      banosMinimos: _filtros.banosMinimos,
      estacionamientosMinimos: _filtros.estacionamientosMinimos,
      soloVerificadas: _filtros.soloVerificadas,
    );
  }

  Widget _tarjeta(Propiedad propiedad) {
    return PropiedadCard(
      propiedad: propiedad,
      onTap: () => _verDetalle(propiedad),
      onFavoriteToggle: () => _alternarFavorito(propiedad),
      onChat: () => _contactar(propiedad),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalFavoritos = ref.watch(favoritosProvider).value?.length ?? 0;
    final totalNoLeidos = ref.watch(mensajesNoLeidosProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildExplorarView(theme),
          _buildFavoritosView(theme),
          const ChatListScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$totalFavoritos'),
              isLabelVisible: totalFavoritos > 0,
              child: const Icon(Icons.favorite_outline_rounded),
            ),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('$totalNoLeidos'),
              isLabelVisible: totalNoLeidos > 0,
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            selectedIcon: const Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
        ],
      ),
    );
  }

  Widget _buildExplorarView(ThemeData theme) {
    final usuario = ref.watch(sesionProvider).usuario;
    final catalogo = ref.watch(catalogoProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            const AppLogo(size: 38),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HabitaCheck', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  'Hola, ${usuario?.primerNombre ?? 'Bienvenido'}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cambiar Tema de Color',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => ThemeSelectorSheet.show(context),
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
        onRefresh: () => ref.read(catalogoProvider.notifier).refrescar(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
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
                        children: [
                          const Text(
                            'Encuentra tu próximo hogar seguro',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Contacto directo con los arrendadores.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.verified_user_rounded, color: Colors.white, size: 48),
                  ],
                ),
              ),
            ),
            SliverToBoxPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) =>
                    setState(() => _actualizarFiltro(texto: val)),
                decoration: InputDecoration(
                  hintText: 'Buscar por colonia, ciudad o amenidad...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _filtros.texto.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _actualizarFiltro(texto: ''));
                          },
                        )
                      : null,
                ),
              ),
            ),
            SliverToBoxPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _abrirFiltros,
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(
                    _filtros.cantidadCriteriosActivos == 0
                        ? 'Filtros'
                        : 'Filtros (${_filtros.cantidadCriteriosActivos})',
                  ),
                ),
              ),
            ),
            SliverToBoxPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categorias.map((cat) {
                    final isSelected = _filtros.amenidad == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val)
                            setState(() => _actualizarFiltro(amenidad: cat));
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
            ...catalogo.when(
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
                    titulo: 'No se pudo cargar el catálogo',
                    descripcion: error.toString(),
                    accion: OutlinedButton(
                      onPressed: () => ref.read(catalogoProvider.notifier).refrescar(),
                      child: const Text('Reintentar'),
                    ),
                  ),
                ),
              ],
              data: (todas) => _seccionCatalogo(theme, todas, _filtros),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _seccionCatalogo(ThemeData theme, List<Propiedad> todas, FiltroPropiedades filtro) {
    final propiedades = filtro.aplicar(todas);
    return [
      SliverToBoxPadding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Propiedades Disponibles',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text('${propiedades.length} resultados', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
      if (propiedades.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: todas.isEmpty
              ? const EstadoVacio(
                  icono: Icons.holiday_village_outlined,
                  titulo: 'Aún no hay propiedades publicadas',
                  descripcion: 'Cuando un arrendador publique un inmueble aparecerá aquí.',
                )
              : const EstadoVacio(
                  icono: Icons.search_off_rounded,
                  titulo: 'No se encontraron propiedades con ese filtro',
                ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _tarjeta(propiedades[index]),
              childCount: propiedades.length,
            ),
          ),
        ),
    ];
  }

  Widget _buildFavoritosView(ThemeData theme) {
    final favoritos = ref.watch(favoritosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        actions: [
          IconButton(
            tooltip: 'Cambiar Tema',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => ThemeSelectorSheet.show(context),
          ),
          const BotonCerrarSesion(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(favoritosProvider.notifier).refrescar(),
        child: favoritos.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EstadoVacio(
            icono: Icons.cloud_off_rounded,
            titulo: 'No se pudieron cargar tus favoritos',
            descripcion: error.toString(),
            accion: OutlinedButton(
              onPressed: () => ref.read(favoritosProvider.notifier).refrescar(),
              child: const Text('Reintentar'),
            ),
          ),
          data: (lista) => lista.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    EstadoVacio(
                      icono: Icons.favorite_border_rounded,
                      titulo: 'No tienes favoritos guardados',
                      descripcion: 'Presiona el corazón en las propiedades que te interesen.',
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  itemBuilder: (context, index) => _tarjeta(lista[index]),
                ),
        ),
      ),
    );
  }
}

class SliverToBoxPadding extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const SliverToBoxPadding({super.key, required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Padding(padding: padding, child: child));
  }
}
