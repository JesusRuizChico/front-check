import '../../core/network/api_client.dart';
import '../../domain/models/propiedad_model.dart';
import '../../domain/repositories/favorito_repository.dart';
import '../mappers/propiedad_mapper.dart';

class ApiFavoritoRepository implements IFavoritoRepository {
  final ApiClient _api;
  final PropiedadMapper _mapper;

  const ApiFavoritoRepository(this._api, this._mapper);

  @override
  Future<List<Propiedad>> obtenerFavoritos() async {
    final json = await _api.get('/favoritos') as List<dynamic>;
    return json.map((item) => _mapper.desdeJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> agregar(int idPropiedad) => _api.put('/favoritos/$idPropiedad');

  @override
  Future<void> quitar(int idPropiedad) => _api.delete('/favoritos/$idPropiedad');
}
