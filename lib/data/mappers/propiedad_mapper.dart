import '../../core/network/media_url_resolver.dart';
import '../../domain/models/amenidad_model.dart';
import '../../domain/models/propiedad_model.dart';
import 'json_lector.dart';

class PropiedadMapper {
  final MediaUrlResolver _media;

  const PropiedadMapper(this._media);

  Propiedad desdeJson(Map<String, dynamic> json) {
    final arrendador = JsonLector.mapa(json['arrendador']);
    return Propiedad(
      id: JsonLector.entero(json['idPropiedad']),
      titulo: JsonLector.texto(json['titulo']),
      descripcion: JsonLector.texto(json['descripcion']),
      precioMensual: JsonLector.decimal(json['precioMensual']),
      calle: JsonLector.texto(json['calle']),
      numeroExterior: JsonLector.texto(json['numeroExterior']),
      numeroInterior: JsonLector.textoOpcional(json['numeroInterior']),
      colonia: JsonLector.texto(json['colonia']),
      municipio: JsonLector.texto(json['municipio']),
      estadoUbicacion: JsonLector.texto(json['estadoUbicacion']),
      codigoPostal: JsonLector.texto(json['codigoPostal']),
      imagenes: JsonLector.lista(json['imagenes'])
          .map((ruta) => _media.resolver(ruta?.toString()))
          .whereType<String>()
          .toList(),
      servicios: JsonLector.lista(json['servicios'])
          .map((servicio) => JsonLector.texto(JsonLector.mapa(servicio)['nombre']))
          .where((nombre) => nombre.isNotEmpty)
          .toList(),
      estado: JsonLector.texto(json['estado'], porDefecto: Propiedad.estadoDisponible),
      verificada: json['verificada'] == true,
      arrendadorId: JsonLector.entero(arrendador['idUsuario']),
      arrendadorNombre: JsonLector.texto(arrendador['nombre']),
      arrendadorTelefono: JsonLector.textoOpcional(arrendador['telefono']),
      arrendadorFoto: _media.resolver(JsonLector.textoOpcional(arrendador['fotoPerfil'])),
      habitaciones: JsonLector.entero(json['habitaciones']),
      banos: JsonLector.entero(json['banos']),
      estacionamientos: JsonLector.entero(json['estacionamientos']),
      metrosCuadrados: JsonLector.decimalOpcional(json['metrosCuadrados']),
      esFavorito: json['esFavorito'] == true,
      fechaPublicacion: JsonLector.fecha(json['fechaPublicacion']),
    );
  }

  Amenidad amenidadDesdeJson(Map<String, dynamic> json) {
    return Amenidad(
      id: JsonLector.entero(json['idServicio']),
      nombre: JsonLector.texto(json['nombre']),
    );
  }
}
