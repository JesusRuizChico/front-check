import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/dependencias.dart';
import '../../../domain/models/chat_model.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'chat_controller.dart';

/// Chat al que se dirige al inquilino al contactar desde una propiedad.
class ChatDePropiedad {
  final DestinoChat destino;
  final Contacto arrendador;

  const ChatDePropiedad({required this.destino, required this.arrendador});
}

/// Caso de uso: reutiliza el chat existente con el arrendador o prepara uno nuevo.
class AbrirChatPropiedad {
  final IChatRepository _repositorio;

  const AbrirChatPropiedad(this._repositorio);

  Future<ChatDePropiedad> ejecutar(int idPropiedad) async {
    final contacto = await _repositorio.contactoDePropiedad(idPropiedad);
    final conversacionId = contacto.conversacionId;
    return ChatDePropiedad(
      destino: conversacionId != null
          ? DestinoChat.conversacion(conversacionId)
          : DestinoChat.propiedad(idPropiedad),
      arrendador: contacto.arrendador,
    );
  }
}

final abrirChatPropiedadProvider = Provider((ref) => AbrirChatPropiedad(ref.watch(chatRepositoryProvider)));
