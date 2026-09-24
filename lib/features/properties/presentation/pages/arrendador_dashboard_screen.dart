import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:front_check/features/properties/data/propiedad_service.dart';
import 'package:go_router/go_router.dart';

import 'package:front_check/core/theme/app_colors.dart';

class ArrendadorDashboardScreen extends StatefulWidget {
  const ArrendadorDashboardScreen({super.key});

  @override
  State<ArrendadorDashboardScreen> createState() => _ArrendadorDashboardScreenState();
}

class _ArrendadorDashboardScreenState extends State<ArrendadorDashboardScreen> {
  late Future<List<dynamic>> _propiedadesFuture;

  @override
  void initState() {
    super.initState();
    _cargarPropiedades();
  }

  void _cargarPropiedades() {
    _propiedadesFuture = propiedadService.obtenerMisPropiedades();
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
        title: const Text('Panel de Arrendador'),
        actions: [
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
            top: -100, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary.withOpacity(0.2)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container()),
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
                    child: Text('Tus Propiedades', style: theme.textTheme.titleLarge),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<dynamic>>(
                    future: _propiedadesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Error al cargar tus propiedades: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.danger),
                            ),
                          ),
                        );
                      }

                      final propiedades = snapshot.data ?? [];

                      if (propiedades.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Aún no tienes propiedades publicadas. ¡Toca el botón "+" para comenzar!',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: propiedades.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: _buildPremiumCard(
                              context: context,
                              title: p['titulo'] ?? 'Sin título',
                              price: '\$${p['precioMensual']}',
                              location: '${p['colonia']}, ${p['municipio']}, ${p['estadoUbicacion']}',
                              isVerified: p['verificada'] ?? false,
                              imageUrl: (p['imagenes'] != null && p['imagenes'].isNotEmpty) 
                                  ? p['imagenes'][0] 
                                  : '',
                              beds: p['habitaciones']?.toString() ?? '1',
                              water: (p['servicios'] != null && p['servicios'].isNotEmpty) 
                                  ? p['servicios'][0] 
                                  : 'No especificado',
                            ),
                          )).toList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/publicar-propiedad');
          if (mounted) {
            setState(() {
              _cargarPropiedades();
            });
          }
        },
        icon: const Icon(Icons.add_home_work_rounded),
        label: const Text('Publicar'),
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
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Encuentra tu', style: theme.textTheme.bodyLarge?.copyWith(color: theme.textTheme.bodyMedium?.color)),
          const SizedBox(height: 4),
          Text('Mis Propiedades', style: theme.textTheme.headlineMedium),
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
                hintText: 'Buscar mis propiedades...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({
    required BuildContext context,
    required String title,
    required String price,
    required String location,
    required bool isVerified,
    required String imageUrl,
    required String beds,
    required String water,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.onSurfaceVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl.isEmpty
                  ? Container(
                      height: 200,
                      color: theme.colorScheme.background,
                      child: Center(child: Icon(Icons.image, size: 50, color: theme.colorScheme.onSurfaceVariant)),
                    )
                  : Image.network(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: theme.colorScheme.background,
                        child: Center(child: Icon(Icons.broken_image, size: 50, color: theme.colorScheme.onSurfaceVariant)),
                      ),
                    ),
              ),
              if (isVerified)
                Positioned(
                  top: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Verificada', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                    Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(price, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: theme.textTheme.bodyMedium?.color),
                    const SizedBox(width: 4),
                    Text(location, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildFeatureIcon(context, Icons.bed, '$beds Hab'),
                        const SizedBox(width: 16),
                        _buildFeatureIcon(context, Icons.water_drop, water),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {},
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

  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: theme.colorScheme.background, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

