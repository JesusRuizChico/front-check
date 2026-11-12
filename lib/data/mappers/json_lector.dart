/// Lectura tolerante de valores JSON enviados por el backend.
class JsonLector {
  const JsonLector._();

  static int entero(Object? valor, {int porDefecto = 0}) {
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '') ?? porDefecto;
  }

  static double decimal(Object? valor, {double porDefecto = 0}) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? porDefecto;
  }

  static double? decimalOpcional(Object? valor) {
    if (valor == null) return null;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString());
  }

  static String texto(Object? valor, {String porDefecto = ''}) => valor?.toString() ?? porDefecto;

  static String? textoOpcional(Object? valor) {
    final texto = valor?.toString();
    return texto == null || texto.isEmpty ? null : texto;
  }

  static DateTime fecha(Object? valor) =>
      fechaOpcional(valor) ?? DateTime.fromMillisecondsSinceEpoch(0);

  static DateTime? fechaOpcional(Object? valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString())?.toLocal();
  }

  static Map<String, dynamic> mapa(Object? valor) =>
      valor is Map<String, dynamic> ? valor : const <String, dynamic>{};

  static List<dynamic> lista(Object? valor) => valor is List ? valor : const [];
}
