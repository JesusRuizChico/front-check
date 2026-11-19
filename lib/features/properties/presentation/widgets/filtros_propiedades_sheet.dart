import 'package:flutter/material.dart';

import '../../application/filtro_propiedades.dart';

class FiltrosPropiedadesSheet extends StatefulWidget {
  final FiltroPropiedades inicial;

  const FiltrosPropiedadesSheet({super.key, required this.inicial});

  static Future<FiltroPropiedades?> show(
    BuildContext context, {
    required FiltroPropiedades inicial,
  }) {
    return showModalBottomSheet<FiltroPropiedades>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FiltrosPropiedadesSheet(inicial: inicial),
    );
  }

  @override
  State<FiltrosPropiedadesSheet> createState() =>
      _FiltrosPropiedadesSheetState();
}

class _FiltrosPropiedadesSheetState extends State<FiltrosPropiedadesSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _precioMinimoController;
  late final TextEditingController _precioMaximoController;
  late int _habitacionesMinimas;
  late int _banosMinimos;
  late int _estacionamientosMinimos;
  late bool _soloVerificadas;

  @override
  void initState() {
    super.initState();
    _precioMinimoController = TextEditingController(
        text: _formatearPrecio(widget.inicial.precioMinimo));
    _precioMaximoController = TextEditingController(
        text: _formatearPrecio(widget.inicial.precioMaximo));
    _habitacionesMinimas = widget.inicial.habitacionesMinimas ?? 0;
    _banosMinimos = widget.inicial.banosMinimos ?? 0;
    _estacionamientosMinimos = widget.inicial.estacionamientosMinimos ?? 0;
    _soloVerificadas = widget.inicial.soloVerificadas;
  }

  @override
  void dispose() {
    _precioMinimoController.dispose();
    _precioMaximoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teclado = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + teclado),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Filtrar propiedades',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text('Precio mensual (MXN)', style: theme.textTheme.titleSmall),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precioMinimoController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Mínimo', prefixText: '\$ '),
                        validator: _validarPrecioMinimo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _precioMaximoController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Máximo', prefixText: '\$ '),
                        validator: _validarPrecioMaximo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _selectorCantidad(
                  etiqueta: 'Habitaciones mínimo',
                  valor: _habitacionesMinimas,
                  onChanged: (valor) =>
                      setState(() => _habitacionesMinimas = valor),
                ),
                const SizedBox(height: 12),
                _selectorCantidad(
                  etiqueta: 'Baños mínimo',
                  valor: _banosMinimos,
                  onChanged: (valor) => setState(() => _banosMinimos = valor),
                ),
                const SizedBox(height: 12),
                _selectorCantidad(
                  etiqueta: 'Estacionamientos mínimo',
                  valor: _estacionamientosMinimos,
                  onChanged: (valor) =>
                      setState(() => _estacionamientosMinimos = valor),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Solo propiedades verificadas'),
                  value: _soloVerificadas,
                  onChanged: (valor) =>
                      setState(() => _soloVerificadas = valor),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _restablecer,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Restablecer'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _aplicar,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Ver resultados'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectorCantidad({
    required String etiqueta,
    required int valor,
    required ValueChanged<int> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: valor,
      decoration: InputDecoration(labelText: etiqueta),
      items: [
        const DropdownMenuItem(value: 0, child: Text('Cualquiera')),
        for (var cantidad = 1; cantidad <= 5; cantidad++)
          DropdownMenuItem(
            value: cantidad,
            child: Text(cantidad == 5 ? '5 o más' : '$cantidad'),
          ),
      ],
      onChanged: (nuevoValor) {
        if (nuevoValor != null) onChanged(nuevoValor);
      },
    );
  }

  String? _validarPrecioMinimo(String? texto) {
    final minimo = _leerPrecio(texto);
    if (texto != null &&
        texto.trim().isNotEmpty &&
        (minimo == null || minimo < 0)) {
      return 'Precio inválido';
    }
    final maximo = _leerPrecio(_precioMaximoController.text);
    if (minimo != null && maximo != null && minimo > maximo)
      return 'Supera el máximo';
    return null;
  }

  String? _validarPrecioMaximo(String? texto) {
    final maximo = _leerPrecio(texto);
    if (texto != null &&
        texto.trim().isNotEmpty &&
        (maximo == null || maximo < 0)) {
      return 'Precio inválido';
    }
    final minimo = _leerPrecio(_precioMinimoController.text);
    if (minimo != null && maximo != null && maximo < minimo)
      return 'Menor al mínimo';
    return null;
  }

  void _restablecer() {
    _precioMinimoController.clear();
    _precioMaximoController.clear();
    setState(() {
      _habitacionesMinimas = 0;
      _banosMinimos = 0;
      _estacionamientosMinimos = 0;
      _soloVerificadas = false;
    });
    _formKey.currentState?.validate();
  }

  void _aplicar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(FiltroPropiedades(
      texto: widget.inicial.texto,
      amenidad: widget.inicial.amenidad,
      precioMinimo: _leerPrecio(_precioMinimoController.text),
      precioMaximo: _leerPrecio(_precioMaximoController.text),
      habitacionesMinimas:
          _habitacionesMinimas == 0 ? null : _habitacionesMinimas,
      banosMinimos: _banosMinimos == 0 ? null : _banosMinimos,
      estacionamientosMinimos:
          _estacionamientosMinimos == 0 ? null : _estacionamientosMinimos,
      soloVerificadas: _soloVerificadas,
    ));
  }

  static double? _leerPrecio(String? texto) {
    if (texto == null || texto.trim().isEmpty) return null;
    return double.tryParse(texto.trim());
  }

  static String _formatearPrecio(double? precio) {
    if (precio == null) return '';
    return precio == precio.roundToDouble()
        ? precio.toStringAsFixed(0)
        : precio.toString();
  }
}
