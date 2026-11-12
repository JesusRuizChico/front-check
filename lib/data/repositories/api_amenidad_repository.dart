import '../../core/network/api_client.dart';
import '../../domain/models/amenidad_model.dart';
import '../../domain/repositories/amenidad_repository.dart';
import '../mappers/propiedad_mapper.dart';

class ApiAmenidadRepository implements IAmenidadRepository {
  final ApiClient _api;
  final PropiedadMapper _mapper;

  const ApiAmenidadRepository(this._api, this._mapper);

  @override
  Future<List<Amenidad>> obtenerAmenidades() async {
    final json = await _api.get('/servicios') as List<dynamic>;
    return json.map((item) => _mapper.amenidadDesdeJson(item as Map<String, dynamic>)).toList();
  }
}
