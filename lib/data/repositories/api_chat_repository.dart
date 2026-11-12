import '../../core/network/api_client.dart';
import '../../domain/models/chat_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../mappers/chat_mapper.dart';
import '../mappers/json_lector.dart';

class ApiChatRepository implements IChatRepository {
  static const _limiteMensajes = 100;

  final ApiClient _api;
  final ChatMapper _mapper;

  const ApiChatRepository(this._api, this._mapper);

  @override
  Future<List<Conversacion>> obtenerConversaciones() async {
    final json = await _api.get('/conversaciones') as List<dynamic>;
    return json.map((item) => _mapper.conversacionDesdeJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Mensaje>> obtenerMensajes(int conversacionId) async {
    final json = await _api.get('/conversaciones/$conversacionId/mensajes?limite=$_limiteMensajes')
        as Map<String, dynamic>;
    return JsonLector.lista(json['mensajes'])
        .map((item) => _mapper.mensajeDesdeJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MensajeEnviado> enviarMensaje(int conversacionId, String contenido) async {
    final json = await _api.post('/conversaciones/$conversacionId/mensajes', {'contenido': contenido});
    return _mapper.mensajeEnviadoDesdeJson(
      json as Map<String, dynamic>,
      conversacionId: conversacionId,
      campoMensaje: 'mensaje',
    );
  }

  @override
  Future<ContactoPropiedad> contactoDePropiedad(int idPropiedad) async {
    final json = await _api.get('/conversaciones/propiedad/$idPropiedad');
    return _mapper.contactoPropiedadDesdeJson(json as Map<String, dynamic>);
  }

  @override
  Future<MensajeEnviado> iniciarDesdePropiedad(int idPropiedad, String contenido) async {
    final json = await _api.post('/conversaciones/propiedad/$idPropiedad/mensajes', {'contenido': contenido})
        as Map<String, dynamic>;
    return _mapper.mensajeEnviadoDesdeJson(
      json,
      conversacionId: JsonLector.entero(json['idConversacion']),
      campoMensaje: 'mensajeInicial',
    );
  }

  @override
  Future<void> marcarComoLeidos(int conversacionId) => _api.put('/conversaciones/$conversacionId/lectura');
}
