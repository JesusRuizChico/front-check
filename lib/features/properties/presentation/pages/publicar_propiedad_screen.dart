import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front_check/data/mock_database.dart';
import 'package:front_check/domain/models/propiedad_model.dart';
import 'package:front_check/features/properties/presentation/widgets/theme_selector_sheet.dart';

class PublicarPropiedadScreen extends StatefulWidget {
  const PublicarPropiedadScreen({super.key});

  @override
  State<PublicarPropiedadScreen> createState() => _PublicarPropiedadScreenState();
}

class _PublicarPropiedadScreenState extends State<PublicarPropiedadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();

  final _calleController = TextEditingController();
  final _numeroExteriorController = TextEditingController();
  final _numeroInteriorController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _municipioController = TextEditingController(text: 'Querétaro');
  final _estadoController = TextEditingController(text: 'Querétaro');
  final _codigoPostalController = TextEditingController();
  final _habitacionesController = TextEditingController(text: '2');
  final _banosController = TextEditingController(text: '1');
  final _estacionamientosController = TextEditingController(text: '1');
  final _metrosCuadradosController = TextEditingController(text: '85');

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _imagenesLocales = [];
  final List<String> _imagenesUrls = [
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
  ];
  bool _isLoading = false;

  final Set<String> _serviciosSeleccionados = {
    'Agua potable',
    'Electricidad',
    'Internet / Wi-Fi',
  };

  final List<String> _fotosMuestra = [
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _calleController.dispose();
    _numeroExteriorController.dispose();
    _numeroInteriorController.dispose();
    _coloniaController.dispose();
    _municipioController.dispose();
    _estadoController.dispose();
    _codigoPostalController.dispose();
    _habitacionesController.dispose();
    _banosController.dispose();
    _estacionamientosController.dispose();
    _metrosCuadradosController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _imagenesLocales.addAll(pickedFiles);
        });
      }
    } catch (_) {
      // Si el picker no responde en emulador, agregar fotos de muestra de arquitectura
      _agregarFotoMuestra();
    }
  }

  void _agregarFotoMuestra() {
    setState(() {
      final nextImg = _fotosMuestra[(_imagenesUrls.length) % _fotosMuestra.length];
      if (!_imagenesUrls.contains(nextImg)) {
        _imagenesUrls.add(nextImg);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto de muestra HD agregada.'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _guardarPropiedad() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los campos requeridos.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 400));

    final usuario = mockDatabase.usuarioActual ?? mockDatabase.usuarios[0];

    final nueva = Propiedad(
      id: 0,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precioMensual: double.tryParse(_precioController.text.trim()) ?? 12000.0,
      calle: _calleController.text.trim(),
      numeroExterior: _numeroExteriorController.text.trim(),
      numeroInterior: _numeroInteriorController.text.trim().isNotEmpty
          ? _numeroInteriorController.text.trim()
          : null,
      colonia: _coloniaController.text.trim(),
      municipio: _municipioController.text.trim(),
      estadoUbicacion: _estadoController.text.trim(),
      codigoPostal: _codigoPostalController.text.trim(),
      imagenes: List.from(_imagenesUrls),
      servicios: _serviciosSeleccionados.toList(),
      estado: 'activa',
      arrendadorId: usuario.id,
      arrendadorNombre: usuario.nombre,
      arrendadorTelefono: usuario.telefono,
      habitaciones: int.tryParse(_habitacionesController.text) ?? 2,
      banos: int.tryParse(_banosController.text) ?? 1,
      estacionamientos: int.tryParse(_estacionamientosController.text) ?? 1,
      metrosCuadrados: double.tryParse(_metrosCuadradosController.text) ?? 85.0,
      fechaPublicacion: DateTime.now(),
    );

    mockDatabase.agregarPropiedad(nueva);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('¡Propiedad publicada exitosamente!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Propiedad'),
        actions: [
          IconButton(
            tooltip: 'Cambiar Tema',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => ThemeSelectorSheet.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Fotos
              _buildSectionTitle(theme, 'Fotografías del Inmueble'),
              const SizedBox(height: 8),
              Text(
                'Sube fotos reales y bien iluminadas para atraer más inquilinos.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Botón para agregar foto
                    InkWell(
                      onTap: _pickImages,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, color: theme.colorScheme.primary, size: 28),
                            const SizedBox(height: 6),
                            Text(
                              'Subir Foto',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Botón para foto de muestra HD
                    InkWell(
                      onTap: _agregarFotoMuestra,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library_rounded, color: Colors.amber, size: 28),
                            SizedBox(height: 6),
                            Text(
                              '+ Muestra HD',
                              style: TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Lista de fotos actuales
                    ..._imagenesUrls.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final url = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 16,
                            child: InkWell(
                              onTap: () {
                                setState(() => _imagenesUrls.removeAt(idx));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Información Básica
              _buildSectionTitle(theme, 'Datos Generales'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título de la publicación *',
                  hintText: 'Ej. Departamento amueblado en Condesa',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada *',
                  hintText: 'Describe el inmueble, distribución, reglas y entorno...',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Renta mensual (MXN) *',
                  hintText: 'Ej. 14500',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 24),

              // Características / Habitaciones
              _buildSectionTitle(theme, 'Características'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _habitacionesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Recámaras',
                        prefixIcon: Icon(Icons.bed_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _banosController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Baños',
                        prefixIcon: Icon(Icons.bathtub_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _estacionamientosController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estacionamientos',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _metrosCuadradosController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'm² Totales',
                        prefixIcon: Icon(Icons.square_foot_outlined),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Ubicación
              _buildSectionTitle(theme, 'Ubicación y Dirección'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _calleController,
                decoration: const InputDecoration(
                  labelText: 'Calle *',
                  hintText: 'Ej. Av. Universidad',
                  prefixIcon: Icon(Icons.add_road_rounded),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numeroExteriorController,
                      decoration: const InputDecoration(
                        labelText: 'Núm. Exterior *',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _numeroInteriorController,
                      decoration: const InputDecoration(
                        labelText: 'Núm. Int. (Opcional)',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _coloniaController,
                      decoration: const InputDecoration(
                        labelText: 'Colonia *',
                        hintText: 'Ej. Centro',
                        prefixIcon: Icon(Icons.location_city_rounded),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _codigoPostalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Código Postal *',
                        hintText: 'Ej. 76000',
                        prefixIcon: Icon(Icons.local_post_office_outlined),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _municipioController,
                      decoration: const InputDecoration(
                        labelText: 'Municipio / Alcaldía',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _estadoController,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.public_rounded),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Servicios y Amenidades
              _buildSectionTitle(theme, 'Servicios Incluidos y Amenidades'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mockDatabase.serviciosDisponibles.map((s) {
                  final nombre = s['nombre'] as String;
                  final isSelected = _serviciosSeleccionados.contains(nombre);
                  return FilterChip(
                    label: Text(nombre),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _serviciosSeleccionados.add(nombre);
                        } else {
                          _serviciosSeleccionados.remove(nombre);
                        }
                      });
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: theme.colorScheme.primary,
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Botón Guardar / Publicar
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _guardarPropiedad,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(_isLoading ? 'Publicando...' : 'Publicar Inmueble'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
