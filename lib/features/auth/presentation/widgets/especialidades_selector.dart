import 'package:flutter/material.dart';
import 'package:front_check/core/constants/especialidades.dart';

/// Widget reutilizable para seleccionar especialidades de un Prestador de Servicios.
///
/// Principio SRP: Solo conoce cómo renderizar y gestionar la selección de chips.
/// Principio ISP: Expone únicamente la interfaz que el padre necesita (lista + callback).
/// Es completamente independiente de la pantalla de registro; puede usarse en edición de perfil.
class EspecialidadesSelector extends StatelessWidget {
  /// Especialidades actualmente seleccionadas
  final List<String> seleccionadas;

  /// Callback que notifica al padre cuando cambia la selección
  final ValueChanged<List<String>> onChanged;

  /// Si true, muestra el borde de error (Escenario 2: ninguna seleccionada)
  final bool mostrarError;

  const EspecialidadesSelector({
    super.key,
    required this.seleccionadas,
    required this.onChanged,
    this.mostrarError = false,
  });

  void _toggleEspecialidad(String clave) {
    final nuevas = List<String>.from(seleccionadas);
    if (nuevas.contains(clave)) {
      nuevas.remove(clave);
    } else {
      nuevas.add(clave);
    }
    onChanged(nuevas);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especialidad(es)',
          style: theme.textTheme.labelLarge?.copyWith(
            color: mostrarError ? theme.colorScheme.error : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: mostrarError
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              width: mostrarError ? 1.5 : 1.0,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Especialidades.catalogo.map((clave) {
              final estaSeleccionada = seleccionadas.contains(clave);
              final etiqueta = Especialidades.etiquetas[clave] ?? clave;
              final icono = Especialidades.iconos[clave] ?? '';

              return AnimatedScale(
                scale: estaSeleccionada ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: FilterChip(
                  label: Text('$icono $etiqueta'),
                  selected: estaSeleccionada,
                  onSelected: (_) => _toggleEspecialidad(clave),
                  selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: estaSeleccionada
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: estaSeleccionada ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: estaSeleccionada
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Mensaje de error — Escenario 2
        if (mostrarError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Selecciona al menos una especialidad.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
