import '../models/amenidad_model.dart';

abstract interface class IAmenidadRepository {
  Future<List<Amenidad>> obtenerAmenidades();
}
