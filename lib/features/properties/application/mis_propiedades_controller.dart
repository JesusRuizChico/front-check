import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/dependencias.dart';
import '../../../domain/models/archivo_imagen.dart';
import '../../../domain/models/nueva_propiedad.dart';
import '../../../domain/models/propiedad_model.dart';
import '../../../domain/repositories/propiedad_repository.dart';
import '../../auth/application/sesion_controller.dart';

/// Publicaciones del arrendador autenticado.
class MisPropiedadesController extends AsyncNotifier<List<Propiedad>> {
  IMisPropiedadesRepository get _repositorio => ref.read(misPropiedadesRepositoryProvider);

  @override
  Future<List<Propiedad>> build() {
    ref.watch(usuarioActualIdProvider);
    return ref.watch(misPropiedadesRepositoryProvider).obtenerMisPropiedades();
  }

  Future<void> refrescar() async {
    state = await AsyncValue.guard(_repositorio.obtenerMisPropiedades);
  }

  Future<void> publicar(NuevaPropiedad propiedad, List<ArchivoImagen> imagenes) async {
    final publicada = await _repositorio.publicar(propiedad, imagenes);
    state = AsyncData([publicada, ...?state.value]);
  }

  Future<void> cambiarEstado(int idPropiedad, String nuevoEstado) async {
    final actualizada = await _repositorio.cambiarEstado(idPropiedad, nuevoEstado);
    state = AsyncData([
      for (final propiedad in state.value ?? const <Propiedad>[])
        propiedad.id == idPropiedad ? actualizada : propiedad,
    ]);
  }

  Future<void> eliminar(int idPropiedad) async {
    await _repositorio.eliminar(idPropiedad);
    state = AsyncData([
      for (final propiedad in state.value ?? const <Propiedad>[])
        if (propiedad.id != idPropiedad) propiedad,
    ]);
  }
}

final misPropiedadesProvider =
    AsyncNotifierProvider<MisPropiedadesController, List<Propiedad>>(MisPropiedadesController.new);
