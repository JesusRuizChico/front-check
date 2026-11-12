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
