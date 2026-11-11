import '../../domain/models/propiedad_model.dart';
import '../../domain/models/servicio_model.dart';
import '../../domain/repositories/propiedad_repository.dart';
import '../mock_database.dart';

class MockPropiedadRepository implements IPropiedadRepository {
  final MockDatabase _db;

  MockPropiedadRepository([MockDatabase? db]) : _db = db ?? mockDatabase;

  @override
  Future<List<Propiedad>> getCatalogo({String? query, String? categoria, double? maxPrecio}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _db.getCatalogo(query: query, categoria: categoria, maxPrecio: maxPrecio);
  }

  @override
  Future<List<Propiedad>> getMisPropiedades(int arrendadorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.getMisPropiedades(arrendadorId);
  }

  @override
  Future<Propiedad?> getPropiedadPorId(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _db.getPropiedadPorId(id);
  }

  @override
  Future<Propiedad> crearPropiedad(Propiedad propiedad) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _db.agregarPropiedad(propiedad);
  }

  @override
  Future<void> actualizarEstado(int id, String nuevoEstado) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _db.cambiarEstadoPropiedad(id, nuevoEstado);
  }

  @override
  Future<void> eliminarPropiedad(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _db.eliminarPropiedad(id);
  }

  @override
  Future<bool> toggleFavorito(int id) async {
    return _db.toggleFavorito(id);
  }

  @override
  Future<List<Propiedad>> getFavoritos() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.getFavoritos();
  }

  @override
  Future<List<ServicioMantenimiento>> getServiciosMantenimiento() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.serviciosMantenimiento;
  }

  @override
  Future<List<Map<String, dynamic>>> getCatalogoServiciosDisponibles() async {
    return _db.serviciosDisponibles;
  }
}

final mockPropiedadRepository = MockPropiedadRepository();

