import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front_check/data/mock_database.dart';
import 'package:front_check/domain/models/propiedad_model.dart';
import 'package:front_check/features/properties/presentation/widgets/propiedad_card.dart';
import 'package:front_check/features/properties/presentation/widgets/propiedad_detalle_sheet.dart';
import 'package:front_check/features/properties/presentation/widgets/theme_selector_sheet.dart';
import 'package:front_check/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:front_check/features/properties/presentation/pages/servicios_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';
  String _categoriaSeleccionada = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _mostrarSelectorDeRoles() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cambiar Rol de Usuario (Modo Demo)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Prueba la experiencia de cada tipo de usuario:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Icon(Icons.person, color: theme.colorScheme.primary),
                ),
                title: const Text('Arrendatario (Ulises López)'),
                subtitle: const Text('Explorar departamentos, rentar y chatear'),
                trailing: mockDatabase.usuarioActual?.id == 2
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  mockDatabase.setUsuarioActual(mockDatabase.usuarios[1]);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.2),
                  child: const Icon(Icons.real_estate_agent, color: Colors.purple),
                ),
                title: const Text('Arrendador (Jesús Ruiz Chico)'),
                subtitle: const Text('Gestionar y publicar propiedades'),
                trailing: mockDatabase.usuarioActual?.id == 1
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  mockDatabase.setUsuarioActual(mockDatabase.usuarios[0]);
                  Navigator.pop(ctx);
                  context.go('/dashboard-arrendador');
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber.withOpacity(0.2),
                  child: const Icon(Icons.build_rounded, color: Colors.amber),
                ),
                title: const Text('Prestador de Servicios (Abigail Hernández)'),
                subtitle: const Text('Atención de instalaciones y mantenimiento'),
                trailing: mockDatabase.usuarioActual?.id == 3
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  mockDatabase.setUsuarioActual(mockDatabase.usuarios[2]);
                  Navigator.pop(ctx);
                  context.go('/dashboard-servicios');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usuario = mockDatabase.usuarioActual;

    return AnimatedBuilder(
      animation: mockDatabase,
      builder: (context, _) {
        final totalChatsNoLeidos = mockDatabase.conversaciones
            .fold<int>(0, (sum, c) => sum + c.mensajesNoLeidos);

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildExplorarView(theme, usuario),
              _buildFavoritosView(theme),
              const ChatListScreen(),
              const ServiciosDashboardScreen(esSubpantalla: true),
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
                  label: Text('${mockDatabase.favoritosIds.length}'),
                  isLabelVisible: mockDatabase.favoritosIds.isNotEmpty,
                  child: const Icon(Icons.favorite_outline_rounded),
                ),
                selectedIcon: const Icon(Icons.favorite_rounded),
                label: 'Favoritos',
              ),
              NavigationDestination(
                icon: Badge(
                  label: Text('$totalChatsNoLeidos'),
                  isLabelVisible: totalChatsNoLeidos > 0,
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                ),
                selectedIcon: const Icon(Icons.chat_bubble_rounded),
                label: 'Chats',
              ),
              const NavigationDestination(
                icon: Icon(Icons.handyman_outlined),
                selectedIcon: Icon(Icons.handyman_rounded),
                label: 'Servicios',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExplorarView(ThemeData theme, dynamic usuario) {
    final propiedades = mockDatabase.getCatalogo(
      query: _filtroTexto,
      categoria: _categoriaSeleccionada,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.home_work_rounded, color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HabitaCheck', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  'Hola, ${(usuario?.nombre != null && usuario!.nombre.isNotEmpty) ? usuario.nombre.split(" ").first : "Bienvenido"}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Botón selector de roles demo
          TextButton.icon(
            onPressed: _mostrarSelectorDeRoles,
            icon: const Icon(Icons.switch_account_rounded, size: 18),
            label: Text(
              usuario?.rolPrincipal ?? 'Rol',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          ),
          // Botón para cambiar tema de color
          IconButton(
            tooltip: 'Cambiar Tema de Color',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => ThemeSelectorSheet.show(context),
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
          // Banner de bienvenida con gradiente
          SliverToBoxPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.35),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Contratos verificados y contacto directo.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
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

          // Buscador interactivo
          SliverToBoxPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filtroTexto = val),
              decoration: InputDecoration(
                hintText: 'Buscar por colonia, ciudad o amenidad...',
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

          // Categorías / Amenidades Chips
          SliverToBoxPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Todos',
                  'Wi-Fi',
                  'Pet Friendly',
                  'Alberca',
                  'Seguridad 24/7',
                  'Amueblado',
                  'Gimnasio',
                ].map((cat) {
                  final isSelected = _categoriaSeleccionada == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _categoriaSeleccionada = cat);
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

          // Título de sección y contador
          SliverToBoxPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Propiedades Disponibles',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${propiedades.length} resultados',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Lista de Tarjetas
          if (propiedades.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    const Text('No se encontraron propiedades con ese filtro'),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = propiedades[index];
                    return PropiedadCard(
                      propiedad: p,
                      onTap: () => PropiedadDetalleSheet.show(context, p),
                    );
                  },
                  childCount: propiedades.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritosView(ThemeData theme) {
    final favoritos = mockDatabase.getFavoritos();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        actions: [
          IconButton(
            tooltip: 'Cambiar Tema',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => ThemeSelectorSheet.show(context),
          ),
        ],
      ),
      body: favoritos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 72, color: Colors.redAccent.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes favoritos guardados',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text('Presiona el corazón en las propiedades que te interesen.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final p = favoritos[index];
                return PropiedadCard(
                  propiedad: p,
                  onTap: () => PropiedadDetalleSheet.show(context, p),
                );
              },
            ),
    );
  }
}

class SliverToBoxPadding extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const SliverToBoxPadding({
    super.key,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(padding: padding, child: child),
    );
  }
}
