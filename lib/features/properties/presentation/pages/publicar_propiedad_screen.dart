import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/price_validator.dart';
import '../../../../core/widgets/avisos.dart';
import '../../../../di/dependencias.dart';
import '../../../../domain/models/archivo_imagen.dart';
import '../../../../domain/models/nueva_propiedad.dart';
import '../../application/catalogo_controller.dart';
import '../../application/mis_propiedades_controller.dart';
import '../widgets/theme_selector_sheet.dart';

class PublicarPropiedadScreen extends ConsumerStatefulWidget {
  const PublicarPropiedadScreen({super.key});

  @override
  ConsumerState<PublicarPropiedadScreen> createState() => _PublicarPropiedadScreenState();
}

class _PublicarPropiedadScreenState extends ConsumerState<PublicarPropiedadScreen> {
  static const _maximoImagenes = 5;

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
  final _metrosCuadradosController = TextEditingController();

  final List<ArchivoImagen> _imagenes = [];
  final Set<int> _amenidadesSeleccionadas = {};
  bool _isLoading = false;

  @override
  void dispose() {
    for (final controller in [
      _tituloController,
      _descripcionController,
      _precioController,
      _calleController,
      _numeroExteriorController,
      _numeroInteriorController,
      _coloniaController,
      _municipioController,
      _estadoController,
      _codigoPostalController,
      _habitacionesController,
      _banosController,
      _estacionamientosController,
      _metrosCuadradosController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final disponibles = _maximoImagenes - _imagenes.length;
    if (disponibles <= 0) {
      Avisos.info(context, 'Puedes subir hasta $_maximoImagenes fotografías.');
      return;
    }
    try {
      final elegidas = await ref.read(selectorImagenesProvider).elegirVarias(maximo: disponibles);
      if (elegidas.isNotEmpty && mounted) {
        setState(() => _imagenes.addAll(elegidas.take(disponibles)));
      }
    } catch (error) {
      if (mounted) Avisos.error(context, error);
    }
  }

  Future<void> _guardarPropiedad() async {
    if (!_formKey.currentState!.validate()) {
      Avisos.info(context, 'Por favor completa los campos requeridos.');
      return;
    }
    if (_imagenes.isEmpty) {
      Avisos.info(context, 'Agrega al menos una fotografía del inmueble.');
      return;
    }

    setState(() => _isLoading = true);
    final interior = _numeroInteriorController.text.trim();
    final metros = _metrosCuadradosController.text.trim();
    final nueva = NuevaPropiedad(
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      precioMensual: double.parse(_precioController.text.trim()),
      calle: _calleController.text.trim(),
      numeroExterior: _numeroExteriorController.text.trim(),
      numeroInterior: interior.isEmpty ? null : interior,
      colonia: _coloniaController.text.trim(),
      municipio: _municipioController.text.trim(),
      estadoUbicacion: _estadoController.text.trim(),
      codigoPostal: _codigoPostalController.text.trim(),
      habitaciones: int.parse(_habitacionesController.text.trim()),
      banos: int.parse(_banosController.text.trim()),
      estacionamientos: int.parse(_estacionamientosController.text.trim()),
      metrosCuadrados: metros.isEmpty ? null : double.parse(metros),
      amenidadesIds: _amenidadesSeleccionadas.toList()..sort(),
    );

    try {
      await ref.read(misPropiedadesProvider.notifier).publicar(nueva, List.of(_imagenes));
      if (!mounted) return;
      Avisos.exito(context, '¡Propiedad publicada exitosamente!');
      context.pop();
    } catch (error) {
      if (mounted) Avisos.error(context, error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _requerido(String? val) => val == null || val.trim().isEmpty ? 'Requerido' : null;

  String? _enteroValido(String? val) {
    final numero = int.tryParse(val?.trim() ?? '');
    return numero == null || numero < 0 || numero > 50 ? 'Entre 0 y 50' : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amenidades = ref.watch(amenidadesProvider);
    final soloNumeros = [FilteringTextInputFormatter.digitsOnly];

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
              _buildSectionTitle(theme, 'Fotografías del Inmueble'),
              const SizedBox(height: 8),
              Text(
                'Sube de 1 a $_maximoImagenes fotos reales y bien iluminadas (JPG, PNG o WEBP, máximo 5 MB cada una).',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    InkWell(
                      onTap: _isLoading ? null : _pickImages,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4), width: 1.5),
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
                            Text(
                              '${_imagenes.length}/$_maximoImagenes',
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ..._imagenes.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 12),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                            child: Image.memory(entry.value.bytes, fit: BoxFit.cover, height: 110),
                          ),
                          if (entry.key == 0)
                            Positioned(
                              left: 6,
                              bottom: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Portada', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            ),
                          Positioned(
                            top: 4,
                            right: 16,
                            child: InkWell(
                              onTap: _isLoading ? null : () => setState(() => _imagenes.removeAt(entry.key)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(theme, 'Datos Generales'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tituloController,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'Título de la publicación *',
                  hintText: 'Ej. Departamento amueblado en el Centro',
                  prefixIcon: Icon(Icons.title_rounded),
                  counterText: '',
                ),
                validator: _requerido,
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
                validator: _requerido,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Renta mensual (MXN) *',
                  hintText: 'Ej. 14500',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (val) => PriceValidator.isValid(val) ? null : 'Ingresa un precio mayor a 0',
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(theme, 'Características'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _habitacionesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: soloNumeros,
                      decoration: const InputDecoration(labelText: 'Recámaras', prefixIcon: Icon(Icons.bed_outlined)),
                      validator: _enteroValido,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _banosController,
                      keyboardType: TextInputType.number,
                      inputFormatters: soloNumeros,
                      decoration: const InputDecoration(labelText: 'Baños', prefixIcon: Icon(Icons.bathtub_outlined)),
                      validator: _enteroValido,
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
                      inputFormatters: soloNumeros,
                      decoration: const InputDecoration(
                        labelText: 'Estacionamientos',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                      ),
                      validator: _enteroValido,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _metrosCuadradosController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'm² Totales',
                        prefixIcon: Icon(Icons.square_foot_outlined),
                      ),
                      validator: (val) {
                        final texto = val?.trim() ?? '';
                        if (texto.isEmpty) return null;
                        final valor = double.tryParse(texto);
                        return valor == null || valor <= 0 ? 'Número mayor a 0' : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(theme, 'Ubicación y Dirección'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _calleController,
                decoration: const InputDecoration(
                  labelText: 'Calle *',
                  hintText: 'Ej. Av. Universidad',
                  prefixIcon: Icon(Icons.add_road_rounded),
                ),
                validator: _requerido,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numeroExteriorController,
                      decoration: const InputDecoration(labelText: 'Núm. Exterior *', prefixIcon: Icon(Icons.pin_outlined)),
                      validator: _requerido,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _numeroInteriorController,
                      decoration: const InputDecoration(labelText: 'Núm. Int. (Opcional)', prefixIcon: Icon(Icons.tag_rounded)),
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
                      validator: _requerido,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _codigoPostalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                      decoration: const InputDecoration(
                        labelText: 'Código Postal *',
                        hintText: 'Ej. 76000',
                        prefixIcon: Icon(Icons.local_post_office_outlined),
                      ),
                      validator: (val) =>
                          RegExp(r'^[0-9]{5}$').hasMatch(val?.trim() ?? '') ? null : '5 dígitos',
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
                      decoration: const InputDecoration(labelText: 'Municipio / Alcaldía *', prefixIcon: Icon(Icons.map_outlined)),
                      validator: _requerido,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _estadoController,
                      decoration: const InputDecoration(labelText: 'Estado *', prefixIcon: Icon(Icons.public_rounded)),
                      validator: _requerido,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(theme, 'Amenidades Incluidas'),
              const SizedBox(height: 8),
              amenidades.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Row(
                  children: [
                    Expanded(child: Text('No se pudieron cargar las amenidades: $error')),
                    TextButton(
                      onPressed: () => ref.invalidate(amenidadesProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
                data: (lista) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lista.map((amenidad) {
                    final isSelected = _amenidadesSeleccionadas.contains(amenidad.id);
                    return FilterChip(
                      label: Text(amenidad.nombre),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _amenidadesSeleccionadas.add(amenidad.id);
                          } else {
                            _amenidadesSeleccionadas.remove(amenidad.id);
                          }
                        });
                      },
                      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      checkmarkColor: theme.colorScheme.primary,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
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
    return Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }
}
