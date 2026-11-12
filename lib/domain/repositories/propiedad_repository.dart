import '../models/archivo_imagen.dart';
import '../models/nueva_propiedad.dart';
import '../models/propiedad_model.dart';

/// Consulta del catálogo público de propiedades.
abstract interface class ICatalogoRepository {
  Future<List<Propiedad>> obtenerCatalogo();
}

/// Gestión de las publicaciones del arrendador.
abstract interface class IMisPropiedadesRepository {
  Future<List<Propiedad>> obtenerMisPropiedades();

  Future<Propiedad> publicar(NuevaPropiedad propiedad, List<ArchivoImagen> imagenes);

  Future<Propiedad> cambiarEstado(int idPropiedad, String nuevoEstado);

  Future<void> eliminar(int idPropiedad);
}
