import '../../../domain/models/propiedad_model.dart';

/// Criterios de búsqueda del catálogo, aplicados en el dispositivo.
class FiltroPropiedades {
  static const todas = 'Todos';

  final String texto;
  final String amenidad;

  const FiltroPropiedades({this.texto = '', this.amenidad = todas});

  bool get estaVacio => texto.trim().isEmpty && amenidad == todas;

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
        return propiedad.servicios.any((servicio) => _normalizar(servicio).contains(amenidadBuscada));
      }
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
