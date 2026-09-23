import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front_check/core/theme/app_colors.dart';
import 'package:front_check/features/properties/data/propiedad_service.dart';

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
  final _ubicacionController = TextEditingController();
  final _habitacionesController = TextEditingController(text: '1');
  final _serviciosController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<XFile> _imagenes = [];
  bool _isLoading = false;

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      
      if (pickedFiles.isNotEmpty) {
        setState(() {
          int availableSlots = 5 - _imagenes.length;
          if (pickedFiles.length > availableSlots) {
            _imagenes.addAll(pickedFiles.take(availableSlots));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Solo puedes subir un máximo de 5 fotografías. Se ignoraron las imágenes adicionales.'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            _imagenes.addAll(pickedFiles);
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagenes.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todos los campos obligatorios.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await propiedadService.publicarPropiedad(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precio: _precioController.text.trim(),
        ubicacion: _ubicacionController.text.trim(),
        habitaciones: _habitacionesController.text.trim(),
        servicios: _serviciosController.text.trim(),
        imagenes: _imagenes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Propiedad publicada exitosamente.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(); // Volver al panel
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _ubicacionController.dispose();
    _habitacionesController.dispose();
    _serviciosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Propiedad'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Detalles de la propiedad', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(labelText: 'Título *', hintText: 'Ej. Departamento en Vista Hermosa'),
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio (Mensual) *', prefixText: '\$'),
                    validator: (value) => value == null || value.isEmpty ? 'El precio es obligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _ubicacionController,
                    decoration: const InputDecoration(labelText: 'Ubicación *', hintText: 'Ej. Col. Vista Hermosa'),
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _habitacionesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Habitaciones *'),
                          validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _serviciosController,
                          decoration: const InputDecoration(labelText: 'Servicios', hintText: 'Ej. Agua Alta'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descripción detallada', hintText: 'Cuéntanos más sobre el lugar...'),
                  ),
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fotografías (${_imagenes.length}/5)', style: theme.textTheme.titleMedium),
                      TextButton.icon(
                        onPressed: _imagenes.length >= 5 ? null : _pickImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Añadir'),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_imagenes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline, style: BorderStyle.solid),
                      ),
                      child: Center(
                        child: Text('No has subido fotografías aún.', style: theme.textTheme.bodyMedium),
                      ),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imagenes.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                clipBehavior: Clip.antiAlias,
                                // Future builder or Network image if we want web support.
                                // For web, XFile.path cannot be used directly with File.
                                // Instead we use network image for web.
                                child: Image.network(
                                  _imagenes[index].path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.broken_image, color: Colors.white54),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 48),
                  
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Publicar Propiedad'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
