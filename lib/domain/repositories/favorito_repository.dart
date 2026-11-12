import '../models/propiedad_model.dart';

abstract interface class IFavoritoRepository {
  Future<List<Propiedad>> obtenerFavoritos();

  Future<void> agregar(int idPropiedad);

  Future<void> quitar(int idPropiedad);
}
