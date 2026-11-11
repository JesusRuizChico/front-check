import '../models/propiedad_model.dart';
import '../models/servicio_model.dart';

abstract class IPropiedadRepository {
  Future<List<Propiedad>> getCatalogo({String? query, String? categoria, double? maxPrecio});
  Future<List<Propiedad>> getMisPropiedades(int arrendadorId);
  Future<Propiedad?> getPropiedadPorId(int id);
  Future<Propiedad> crearPropiedad(Propiedad propiedad);
  Future<void> actualizarEstado(int id, String nuevoEstado);
  Future<void> eliminarPropiedad(int id);
  Future<bool> toggleFavorito(int id);
  Future<List<Propiedad>> getFavoritos();
  Future<List<ServicioMantenimiento>> getServiciosMantenimiento();
  Future<List<Map<String, dynamic>>> getCatalogoServiciosDisponibles();
}

