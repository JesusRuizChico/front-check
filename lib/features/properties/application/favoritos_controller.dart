import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/dependencias.dart';
import '../../../domain/models/propiedad_model.dart';
import '../../auth/application/sesion_controller.dart';
import 'catalogo_controller.dart';

/// Propiedades guardadas por el inquilino.
class FavoritosController extends AsyncNotifier<List<Propiedad>> {
  @override
  Future<List<Propiedad>> build() {
    ref.watch(usuarioActualIdProvider);
    return ref.watch(favoritoRepositoryProvider).obtenerFavoritos();
  }

  Future<void> refrescar() async {
    state = await AsyncValue.guard(() => ref.read(favoritoRepositoryProvider).obtenerFavoritos());
  }

  /// Agrega o quita la propiedad de favoritos y sincroniza el catálogo.
  Future<void> alternar(Propiedad propiedad) async {
    final nuevoValor = !propiedad.esFavorito;
    final repositorio = ref.read(favoritoRepositoryProvider);
    if (nuevoValor) {
      await repositorio.agregar(propiedad.id);
    } else {
      await repositorio.quitar(propiedad.id);
    }
    ref.read(catalogoProvider.notifier).marcarFavorito(propiedad.id, nuevoValor);
    await refrescar();
  }
}

final favoritosProvider = AsyncNotifierProvider<FavoritosController, List<Propiedad>>(FavoritosController.new);
