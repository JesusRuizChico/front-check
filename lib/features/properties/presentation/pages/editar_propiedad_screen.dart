import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front_check/core/theme/app_colors.dart';
import 'package:front_check/features/properties/data/propiedad_service.dart';

/// Pantalla de Edición de Propiedad
/// Solo permite editar propiedades en estado "disponible" o "pausada".
/// El backend rechazará la petición si la propiedad está "rentada" o "eliminada".
class EditarPropiedadScreen extends StatefulWidget {
  /// Mapa con los datos actuales de la propiedad que viene del dashboard.
  final Map<String, dynamic> propiedad;

  const EditarPropiedadScreen({super.key, required this.propiedad});

  @override
  State<EditarPropiedadScreen> createState() => _EditarPropiedadScreenState();
}

class _EditarPropiedadScreenState extends State<EditarPropiedadScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores pre-cargados con los datos actuales de la propiedad
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _precioController;
  late final TextEditingController _calleController;
  late final TextEditingController _numeroExtController;
  late final TextEditingController _numeroIntController;
  late final TextEditingController _coloniaController;
  late final TextEditingController _municipioController;
  late final TextEditingController _estadoUbController;
  late final TextEditingController _codigoPostalController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-cargar todos los campos con los datos existentes de la propiedad
    _tituloController      = TextEditingController(text: widget.propiedad['titulo']?.toString() ?? '');
    _descripcionController = TextEditingController(text: widget.propiedad['descripcion']?.toString() ?? '');
    _precioController      = TextEditingController(text: widget.propiedad['precioMensual']?.toString() ?? '');
    _calleController       = TextEditingController(text: widget.propiedad['calle']?.toString() ?? '');
    _numeroExtController   = TextEditingController(text: widget.propiedad['numeroExterior']?.toString() ?? '');
    _numeroIntController   = TextEditingController(text: widget.propiedad['numeroInterior']?.toString() ?? '');
    _coloniaController     = TextEditingController(text: widget.propiedad['colonia']?.toString() ?? '');
    _municipioController   = TextEditingController(text: widget.propiedad['municipio']?.toString() ?? '');
    _estadoUbController    = TextEditingController(text: widget.propiedad['estadoUbicacion']?.toString() ?? '');
    _codigoPostalController= TextEditingController(text: widget.propiedad['codigoPostal']?.toString() ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _calleController.dispose();
    _numeroExtController.dispose();
    _numeroIntController.dispose();
    _coloniaController.dispose();
    _municipioController.dispose();
    _estadoUbController.dispose();
    _codigoPostalController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todos los campos obligatorios.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await propiedadService.editarPropiedad(
        idPropiedad: widget.propiedad['idPropiedad'] as int,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precioMensual: _precioController.text.trim(),
        calle: _calleController.text.trim(),
        numeroExterior: _numeroExtController.text.trim(),
        numeroInterior: _numeroIntController.text.trim(),
        colonia: _coloniaController.text.trim(),
        municipio: _municipioController.text.trim(),
        estadoUbicacion: _estadoUbController.text.trim(),
        codigoPostal: _codigoPostalController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Propiedad actualizada exitosamente.'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.pop(true); // Regresa al dashboard con resultado: true (hay que recargar)
      }
    } catch (e) {
      if (mounted) {
        final mensaje = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(mensaje)),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = widget.propiedad['estado']?.toString() ?? 'disponible';
    final estaRentada = estado == 'rentada' || estado == 'eliminada';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Propiedad'),
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

                    // Banner de advertencia si la propiedad no es editable
                    if (estaRentada)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded, color: AppColors.danger),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Esta propiedad está "$estado" y no puede ser editada.',
                                style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Badge de estado actual
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _colorEstado(estado).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _colorEstado(estado).withOpacity(0.4)),
                          ),
                          child: Text(
                            'Estado: ${estado.toUpperCase()}',
                            style: TextStyle(
                              color: _colorEstado(estado),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── SECCIÓN: Detalles ────────────────────────────
                    Text('Detalles de la propiedad', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _tituloController,
                      enabled: !estaRentada,
                      decoration: const InputDecoration(
                        labelText: 'Título *',
                        hintText: 'Ej. Departamento en Vista Hermosa',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _precioController,
                      enabled: !estaRentada,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Precio mensual *',
                        prefixText: '\$',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'El precio es obligatorio' : null,
                    ),
                    const SizedBox(height: 32),

                    // ── SECCIÓN: Dirección ───────────────────────────
                    Text('Dirección', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _calleController,
                      enabled: !estaRentada,
                      decoration: const InputDecoration(labelText: 'Calle *'),
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _numeroExtController,
                            enabled: !estaRentada,
                            decoration: const InputDecoration(labelText: 'Núm. Ext *'),
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _numeroIntController,
                            enabled: !estaRentada,
                            decoration: const InputDecoration(labelText: 'Núm. Int (Opcional)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _coloniaController,
                            enabled: !estaRentada,
                            decoration: const InputDecoration(labelText: 'Colonia *'),
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _codigoPostalController,
                            enabled: !estaRentada,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Código Postal *'),
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _municipioController,
                            enabled: !estaRentada,
                            decoration: const InputDecoration(labelText: 'Municipio *'),
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _estadoUbController,
                            enabled: !estaRentada,
                            decoration: const InputDecoration(labelText: 'Estado *', hintText: 'Ej. Jalisco'),
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── SECCIÓN: Más detalles ────────────────────────
                    Text('Más detalles', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descripcionController,
                      enabled: !estaRentada,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción detallada',
                        hintText: 'Cuéntanos más sobre el lugar...',
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Botón guardar — deshabilitado si no es editable
                    ElevatedButton(
                      onPressed: estaRentada ? null : _guardarCambios,
                      child: const Text('Guardar Cambios'),
                    ),

                    if (estaRentada) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Volver'),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'disponible': return AppColors.success;
      case 'pausada':    return AppColors.accent;
      case 'rentada':    return AppColors.secondary;
      case 'eliminada':  return AppColors.danger;
      default:           return AppColors.accent;
    }
  }
}

