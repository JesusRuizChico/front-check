import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/dependencias.dart';
import '../../../domain/models/amenidad_model.dart';
import '../../../domain/models/propiedad_model.dart';
import '../../auth/application/sesion_controller.dart';

/// Propiedades disponibles que ve el inquilino.
class CatalogoController extends AsyncNotifier<List<Propiedad>> {
  @override
  Future<List<Propiedad>> build() {
    ref.watch(usuarioActualIdProvider);
    return ref.watch(catalogoRepositoryProvider).obtenerCatalogo();
  }

  Future<void> refrescar() async {
    state = await AsyncValue.guard(() => ref.read(catalogoRepositoryProvider).obtenerCatalogo());
  }

  void marcarFavorito(int idPropiedad, bool esFavorito) {
    final actuales = state.value;
    if (actuales == null) return;
    state = AsyncData([
      for (final propiedad in actuales)
        propiedad.id == idPropiedad ? propiedad.copyWith(esFavorito: esFavorito) : propiedad,
    ]);
  }
}

final catalogoProvider = AsyncNotifierProvider<CatalogoController, List<Propiedad>>(CatalogoController.new);

/// Catálogo de amenidades disponibles para publicar.
final amenidadesProvider = FutureProvider<List<Amenidad>>(
  (ref) => ref.watch(amenidadRepositoryProvider).obtenerAmenidades(),
);
