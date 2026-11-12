import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/dependencias.dart';
import '../../../domain/models/chat_model.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../auth/application/sesion_controller.dart';
import 'conversaciones_controller.dart';

/// Identifica un chat existente o el chat que se abrirá desde una propiedad.
class DestinoChat {
  final int? conversacionId;
  final int? propiedadId;

  const DestinoChat.conversacion(int this.conversacionId) : propiedadId = null;

  const DestinoChat.propiedad(int this.propiedadId) : conversacionId = null;

  @override
  bool operator ==(Object other) =>
      other is DestinoChat && other.conversacionId == conversacionId && other.propiedadId == propiedadId;

  @override
  int get hashCode => Object.hash(conversacionId, propiedadId);
}

class ChatState {
  final int? conversacionId;
  final List<Mensaje> mensajes;
  final bool cargando;
  final bool enviando;
  final String? error;
  final bool avisoRespuestaLenta;

  const ChatState({
    this.conversacionId,
    this.mensajes = const [],
    this.cargando = false,
    this.enviando = false,
    this.error,
    this.avisoRespuestaLenta = false,
  });

  ChatState copyWith({
    int? conversacionId,
    List<Mensaje>? mensajes,
    bool? cargando,
    bool? enviando,
    String? error,
    bool limpiarError = false,
    bool? avisoRespuestaLenta,
  }) {
    return ChatState(
      conversacionId: conversacionId ?? this.conversacionId,
      mensajes: mensajes ?? this.mensajes,
      cargando: cargando ?? this.cargando,
      enviando: enviando ?? this.enviando,
      error: limpiarError ? null : (error ?? this.error),
      avisoRespuestaLenta: avisoRespuestaLenta ?? this.avisoRespuestaLenta,
    );
  }
}

/// Mensajes de un chat abierto. Consulta nuevos mensajes cada pocos segundos
/// y marca como leídos los recibidos.
class ChatController extends Notifier<ChatState> {
  static const intervaloActualizacion = Duration(seconds: 3);

  final DestinoChat destino;
  Timer? _temporizador;

  ChatController(this.destino);

  IChatRepository get _repositorio => ref.read(chatRepositoryProvider);

  @override
  ChatState build() {
    ref.onDispose(() => _temporizador?.cancel());
    final conversacionId = destino.conversacionId;
    if (conversacionId == null) return const ChatState();
    Future.microtask(() => _iniciarSincronizacion(conversacionId));
    return ChatState(conversacionId: conversacionId, cargando: true);
  }

  Future<void> enviar(String texto) async {
    final contenido = texto.trim();
    if (contenido.isEmpty || state.enviando) return;
    state = state.copyWith(enviando: true, limpiarError: true);
    try {
      final conversacionId = state.conversacionId;
      final enviado = conversacionId == null
          ? await _repositorio.iniciarDesdePropiedad(destino.propiedadId!, contenido)
          : await _repositorio.enviarMensaje(conversacionId, contenido);
      if (!ref.mounted) return;
      state = state.copyWith(
        conversacionId: enviado.conversacionId,
        mensajes: _agregar(state.mensajes, [enviado.mensaje]),
        enviando: false,
        avisoRespuestaLenta: enviado.avisoRespuestaLenta,
      );
      if (conversacionId == null) _programarActualizacion(enviado.conversacionId);
      ref.read(conversacionesProvider.notifier).refrescar();
    } catch (error) {
      if (ref.mounted) state = state.copyWith(enviando: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> _iniciarSincronizacion(int conversacionId) async {
    await _actualizar(conversacionId);
    _programarActualizacion(conversacionId);
  }

  void _programarActualizacion(int conversacionId) {
    _temporizador?.cancel();
    _temporizador = Timer.periodic(intervaloActualizacion, (_) => _actualizar(conversacionId));
  }

  Future<void> _actualizar(int conversacionId) async {
    try {
      final mensajes = await _repositorio.obtenerMensajes(conversacionId);
      if (!ref.mounted) return;
      final cambiaron = mensajes.length != state.mensajes.length ||
          mensajes.any((m) => m.leido) != state.mensajes.any((m) => m.leido) ||
          (mensajes.isNotEmpty && mensajes.last.id != state.mensajes.lastOrNull?.id);
      if (cambiaron || state.cargando || state.error != null) {
        state = state.copyWith(mensajes: mensajes, cargando: false, limpiarError: true);
      }
      await _marcarLeidosSiHaceFalta(conversacionId, mensajes);
    } catch (error) {
      if (ref.mounted && state.mensajes.isEmpty) {
        state = state.copyWith(cargando: false, error: error.toString());
      }
    }
  }

  Future<void> _marcarLeidosSiHaceFalta(int conversacionId, List<Mensaje> mensajes) async {
    final miId = _miUsuarioId();
    final pendientes = mensajes.any((m) => !m.leido && m.emisorId != miId);
    if (!pendientes) return;
    await _repositorio.marcarComoLeidos(conversacionId);
    if (ref.mounted) ref.read(conversacionesProvider.notifier).refrescar();
  }

  int? _miUsuarioId() => ref.read(usuarioActualIdProvider);

  List<Mensaje> _agregar(List<Mensaje> actuales, List<Mensaje> nuevos) {
    final ids = actuales.map((m) => m.id).toSet();
    return [...actuales, ...nuevos.where((m) => !ids.contains(m.id))];
  }
}

final chatProvider =
    NotifierProvider.autoDispose.family<ChatController, ChatState, DestinoChat>(ChatController.new);
