/// Formatos de presentación reutilizables.
class Formato {
  const Formato._();

  /// Precio en pesos con separador de miles, por ejemplo `$12,500`.
  static String moneda(double valor) {
    final entero = valor.round().toString();
    final conSeparadores = entero.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '\$$conSeparadores';
  }

  static String hora(DateTime fecha) =>
      '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

  /// Indica si ambas fechas caen en el mismo día calendario.
  static bool mismoDia(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  /// Etiqueta del separador de día en un chat: "Hoy", "Ayer" o "5 de marzo de 2026".
  static String etiquetaDia(DateTime fecha, {DateTime? ahora}) {
    final hoy = ahora ?? DateTime.now();
    if (mismoDia(fecha, hoy)) return 'Hoy';
    if (mismoDia(fecha, DateTime(hoy.year, hoy.month, hoy.day - 1))) return 'Ayer';
    return '${fecha.day} de ${_meses[fecha.month - 1]} de ${fecha.year}';
  }

  /// Tiempo relativo corto para listas de chats.
  static String haceCuanto(DateTime fecha, {DateTime? ahora}) {
    final diferencia = (ahora ?? DateTime.now()).difference(fecha);
    if (diferencia.inMinutes < 1) return 'ahora';
    if (diferencia.inMinutes < 60) return '${diferencia.inMinutes} min';
    if (diferencia.inHours < 24) return hora(fecha);
    if (diferencia.inDays < 7) return '${diferencia.inDays} d';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
