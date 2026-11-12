import '../../../domain/models/propiedad_model.dart';

/// Criterios de búsqueda del catálogo, aplicados en el dispositivo.
class FiltroPropiedades {
  static const todas = 'Todos';

  final String texto;
  final String amenidad;
  final double? precioMinimo;
  final double? precioMaximo;
  final int? habitacionesMinimas;
  final int? banosMinimos;
  final int? estacionamientosMinimos;
  final bool soloVerificadas;

  const FiltroPropiedades({
    this.texto = '',
    this.amenidad = todas,
    this.precioMinimo,
    this.precioMaximo,
    this.habitacionesMinimas,
    this.banosMinimos,
    this.estacionamientosMinimos,
    this.soloVerificadas = false,
  });

  bool get estaVacio =>
      texto.trim().isEmpty &&
      amenidad == todas &&
      precioMinimo == null &&
      precioMaximo == null &&
      habitacionesMinimas == null &&
      banosMinimos == null &&
      estacionamientosMinimos == null &&
      !soloVerificadas;

  int get cantidadCriteriosActivos => [
        texto.trim().isNotEmpty,
        amenidad != todas,
        precioMinimo != null,
        precioMaximo != null,
        habitacionesMinimas != null,
        banosMinimos != null,
        estacionamientosMinimos != null,
        soloVerificadas,
      ].where((activo) => activo).length;

  List<Propiedad> aplicar(List<Propiedad> propiedades) {
    final consulta = _normalizar(texto);
    final amenidadBuscada = _normalizar(amenidad);
    return propiedades.where((propiedad) {
      if (consulta.isNotEmpty) {
        final campos = [
          propiedad.titulo,
          propiedad.colonia,
          propiedad.municipio,
          propiedad.estadoUbicacion,
          ...propiedad.servicios,
        ].map(_normalizar);
        if (!campos.any((campo) => campo.contains(consulta))) return false;
      }
      if (amenidad != todas) {
        if (!propiedad.servicios.any(
            (servicio) => _normalizar(servicio).contains(amenidadBuscada))) {
          return false;
        }
      }
      if (precioMinimo != null && propiedad.precioMensual < precioMinimo!)
        return false;
      if (precioMaximo != null && propiedad.precioMensual > precioMaximo!)
        return false;
      if (habitacionesMinimas != null &&
          propiedad.habitaciones < habitacionesMinimas!) return false;
      if (banosMinimos != null && propiedad.banos < banosMinimos!) return false;
      if (estacionamientosMinimos != null &&
          propiedad.estacionamientos < estacionamientosMinimos!) return false;
      if (soloVerificadas && !propiedad.verificada) return false;
      return true;
    }).toList();
  }

  static String _normalizar(String valor) {
    const conAcento = 'áéíóúüñ';
    const sinAcento = 'aeiouun';
    var resultado = valor.toLowerCase().trim();
    for (var i = 0; i < conAcento.length; i++) {
      resultado = resultado.replaceAll(conAcento[i], sinAcento[i]);
    }
    return resultado;
  }
}
