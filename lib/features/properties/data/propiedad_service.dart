import 'package:image_picker/image_picker.dart';
import 'package:front_check/domain/models/propiedad_model.dart';
import 'package:front_check/domain/repositories/propiedad_repository.dart';
import 'package:front_check/data/repositories/mock_propiedad_repository.dart';

class PropiedadService {
  final IPropiedadRepository _repository;

  PropiedadService([IPropiedadRepository? repository])
      : _repository = repository ?? mockPropiedadRepository;

  Future<void> publicarPropiedad({
    required String titulo,
    required String descripcion,
    required String precioMensual,
    required String calle,
    required String numeroExterior,
    String? numeroInterior,
    required String colonia,
    required String municipio,
    required String estadoUbicacion,
    required String codigoPostal,
    String? latitud,
    String? longitud,
    List<int>? serviciosIds,
    required List<XFile> imagenes,
  }) async {
    final nueva = Propiedad(
      id: 0,
      titulo: titulo,
      descripcion: descripcion,
      precioMensual: double.tryParse(precioMensual) ?? 10000.0,
      calle: calle,
      numeroExterior: numeroExterior,
      numeroInterior: numeroInterior,
      colonia: colonia,
      municipio: municipio,
      estadoUbicacion: estadoUbicacion,
      codigoPostal: codigoPostal,
      imagenes: [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
      ],
      servicios: ['Agua potable', 'Electricidad', 'Internet / Wi-Fi'],
      estado: 'activa',
      arrendadorId: 1,
      arrendadorNombre: 'Jesús Ruiz Chico',
      arrendadorTelefono: '4421234567',
      fechaPublicacion: DateTime.now(),
    );

    await _repository.crearPropiedad(nueva);
  }

  Future<List<dynamic>> obtenerCatalogo() async {
    final list = await _repository.getCatalogo();
    return list.map((p) => p.toJson()).toList();
  }

  Future<List<dynamic>> obtenerMisPropiedades() async {
    final list = await _repository.getMisPropiedades(1);
    return list.map((p) => p.toJson()).toList();
  }

  Future<Map<String, dynamic>> obtenerPorId(int id) async {
    final p = await _repository.getPropiedadPorId(id);
    if (p != null) return p.toJson();
    throw Exception('Propiedad no encontrada');
  }

  Future<void> cambiarEstado(int idPropiedad, String nuevoEstado) async {
    await _repository.actualizarEstado(idPropiedad, nuevoEstado);
  }

  Future<void> eliminarPropiedad(int idPropiedad) async {
    await _repository.eliminarPropiedad(idPropiedad);
  }

  Future<List<dynamic>> obtenerServicios() async {
    return await _repository.getCatalogoServiciosDisponibles();
  }
}

final propiedadService = PropiedadService();
