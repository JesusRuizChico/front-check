/// Catálogo centralizado de especialidades para Prestadores de Servicios.
/// Principio OCP: Para agregar una nueva especialidad, solo se modifica este archivo.
/// Principio SRP: Una única fuente de verdad para los datos del catálogo.
class Especialidades {
  // Constructor privado: esta clase no debe instanciarse
  Especialidades._();

  /// Lista de claves válidas (deben coincidir exactamente con el backend)
  static const List<String> catalogo = [
    'albanileria',
    'pintura',
    'plomeria',
    'electricidad',
  ];

  /// Etiquetas legibles para mostrar en la UI
  static const Map<String, String> etiquetas = {
    'albanileria': 'Albañilería',
    'pintura': 'Pintura',
    'plomeria': 'Plomería',
    'electricidad': 'Electricidad',
  };

  /// Íconos representativos por especialidad
  static const Map<String, String> iconos = {
    'albanileria': '🧱',
    'pintura': '🎨',
    'plomeria': '🔧',
    'electricidad': '⚡',
  };
}
