import '../../core/network/api_client.dart';
import '../../domain/models/archivo_imagen.dart';
import '../../domain/models/nueva_propiedad.dart';
import '../../domain/models/propiedad_model.dart';
import '../../domain/repositories/propiedad_repository.dart';
import '../mappers/propiedad_mapper.dart';

class ApiPropiedadRepository implements ICatalogoRepository, IMisPropiedadesRepository {
  final ApiClient _api;
  final PropiedadMapper _mapper;

  const ApiPropiedadRepository(this._api, this._mapper);

  @override
  Future<List<Propiedad>> obtenerCatalogo() => _lista('/propiedades');

  @override
  Future<List<Propiedad>> obtenerMisPropiedades() => _lista('/propiedades/mis-propiedades');

  @override
  Future<Propiedad> publicar(NuevaPropiedad propiedad, List<ArchivoImagen> imagenes) async {
    final campos = <String, String>{
      'titulo': propiedad.titulo,
      'descripcion': propiedad.descripcion,
      'precioMensual': propiedad.precioMensual.toString(),
      'calle': propiedad.calle,
      'numeroExterior': propiedad.numeroExterior,
      'colonia': propiedad.colonia,
      'municipio': propiedad.municipio,
      'estadoUbicacion': propiedad.estadoUbicacion,
      'codigoPostal': propiedad.codigoPostal,
      'habitaciones': propiedad.habitaciones.toString(),
      'banos': propiedad.banos.toString(),
      'estacionamientos': propiedad.estacionamientos.toString(),
      if (propiedad.numeroInterior != null) 'numeroInterior': propiedad.numeroInterior!,
      if (propiedad.metrosCuadrados != null) 'metrosCuadrados': propiedad.metrosCuadrados.toString(),
      for (var i = 0; i < propiedad.amenidadesIds.length; i++)
        'serviciosIds[$i]': propiedad.amenidadesIds[i].toString(),
    };
    final json = await _api.postMultipart(
      '/propiedades',
      campos: campos,
      archivos: imagenes
          .map((imagen) => ArchivoMultipart(campo: 'imagenes', nombre: imagen.nombre, bytes: imagen.bytes))
          .toList(),
    );
    return _mapper.desdeJson(json as Map<String, dynamic>);
  }

  @override
  Future<Propiedad> cambiarEstado(int idPropiedad, String nuevoEstado) async {
    final json = await _api.patch('/propiedades/$idPropiedad/estado', {'estado': nuevoEstado});
    return _mapper.desdeJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> eliminar(int idPropiedad) => _api.delete('/propiedades/$idPropiedad');

  Future<List<Propiedad>> _lista(String ruta) async {
    final json = await _api.get(ruta) as List<dynamic>;
    return json.map((item) => _mapper.desdeJson(item as Map<String, dynamic>)).toList();
  }
}
