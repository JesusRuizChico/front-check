import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/dependencias.dart';
import '../../../domain/models/chat_model.dart';
import '../../auth/application/sesion_controller.dart';

/// Bandeja de chats del usuario; se actualiza periódicamente para mostrar mensajes nuevos.
class ConversacionesController extends AsyncNotifier<List<Conversacion>> {
  static const intervaloActualizacion = Duration(seconds: 8);

  @override
  Future<List<Conversacion>> build() {
    ref.watch(usuarioActualIdProvider);
    final temporizador = Timer.periodic(intervaloActualizacion, (_) => _actualizarEnSegundoPlano());
    ref.onDispose(temporizador.cancel);
    return ref.watch(chatRepositoryProvider).obtenerConversaciones();
  }

  Future<void> refrescar() async {
    state = await AsyncValue.guard(() => ref.read(chatRepositoryProvider).obtenerConversaciones());
  }

  Future<void> _actualizarEnSegundoPlano() async {
    if (!ref.mounted || ref.read(usuarioActualIdProvider) == null) return;
    try {
      final conversaciones = await ref.read(chatRepositoryProvider).obtenerConversaciones();
      if (ref.mounted) state = AsyncData(conversaciones);
    } catch (_) {
      // Se conserva la última lista conocida; el siguiente ciclo volverá a intentarlo.
    }
  }
}

final conversacionesProvider =
    AsyncNotifierProvider<ConversacionesController, List<Conversacion>>(ConversacionesController.new);

/// Total de mensajes recibidos sin leer en todos los chats.
final mensajesNoLeidosProvider = Provider<int>((ref) {
  final conversaciones = ref.watch(conversacionesProvider).value ?? const <Conversacion>[];
  return conversaciones.fold(0, (total, conversacion) => total + conversacion.mensajesNoLeidos);
});
