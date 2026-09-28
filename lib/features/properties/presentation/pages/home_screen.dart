import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:front_check/core/theme/app_colors.dart';
import 'package:front_check/features/properties/data/propiedad_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _catalogoFuture;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  void _cargarCatalogo() {
    _catalogoFuture = propiedadService.obtenerCatalogoDisponible();
  }

  Future<void> _logout() async {
    // TODO: Llamar al endpoint /api/auth/logout del backend
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            tooltip: 'Mensajes',
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () => context.push('/mensajes'),
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => context.push('/account'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo oscuro/claro
          Container(color: theme.colorScheme.background),

          // Desenfoque de acento superior
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.2)),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container()),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(context),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text('Propiedades Disponibles',
                        style: theme.textTheme.titleLarge),
                  ),
                  const SizedBox(height: 16),
                  _buildCatalogGrid(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.onSurfaceVariant),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Encuentra tu',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.textTheme.bodyMedium?.color)),
          const SizedBox(height: 4),
          Text('Lugar Ideal', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.onSurfaceVariant),
            ),
            child: TextField(
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Buscar por zona (ej. Vista Hermosa)',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
                prefixIcon:
                    Icon(Icons.search, color: theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogGrid(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _catalogoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'No se pudieron cargar las propiedades.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.danger,
                      ),
                ),
                TextButton(
                  onPressed: () => setState(_cargarCatalogo),
                  child: const Text('Volver a intentar'),
                ),
              ],
            ),
          );
        }

        final propiedades = snapshot.data ?? [];
        if (propiedades.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('Todavía no hay propiedades disponibles.'),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: propiedades.map((item) {
              final propiedad = Map<String, dynamic>.from(item as Map);
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildPremiumCard(context, propiedad),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPremiumCard(
    BuildContext context,
    Map<String, dynamic> propiedad,
  ) {
    final theme = Theme.of(context);
    final imagenes = propiedad['imagenes'] as List? ?? const [];
    final imageUrl = imagenes.isEmpty ? null : imagenes.first?.toString();
    final servicios = (propiedad['servicios'] as List? ?? const [])
        .map((servicio) => servicio.toString())
        .toList();
    final ubicacion = [
      propiedad['colonia'],
      propiedad['municipio'],
      propiedad['estadoUbicacion'],
    ]
        .where((parte) => parte != null && parte.toString().trim().isNotEmpty)
        .map((parte) => parte.toString())
        .join(', ');
    final precio = propiedad['precioMensual'];
    final precioTexto = precio is num
        ? '\$${precio.toStringAsFixed(2)}'
        : precio == null
            ? 'Precio por consultar'
            : '\$$precio';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.onSurfaceVariant),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl == null || imageUrl.isEmpty
                    ? Container(
                        height: 200,
                        color: theme.colorScheme.background,
                        child: Center(
                            child: Icon(Icons.image,
                                size: 50,
                                color: theme.colorScheme.onSurfaceVariant)),
                      )
                    : Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: theme.colorScheme.background,
                          child: Center(
                              child: Icon(Icons.broken_image,
                                  size: 50,
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ),
                      ),
              ),
              if (propiedad['verificada'] == true)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Verificada',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                            propiedad['titulo']?.toString() ?? 'Propiedad',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    Text(precioTexto,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: theme.textTheme.bodyMedium?.color),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(ubicacion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                                fontSize: 13))),
                  ],
                ),
                if ((propiedad['descripcion']?.toString() ?? '')
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    propiedad['descripcion'].toString(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        servicios.isEmpty
                            ? 'Sin servicios especificados'
                            : servicios.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: propiedad['idPropiedad'] == null
                          ? null
                          : () => context.push(
                                '/mensajes/propiedad/${propiedad['idPropiedad']}',
                              ),
                      child: const Text('Contactar'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
