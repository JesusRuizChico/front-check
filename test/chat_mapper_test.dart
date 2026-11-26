import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/network/media_url_resolver.dart';
import 'package:front_check/data/mappers/chat_mapper.dart';

void main() {
  const mapper = ChatMapper(MediaUrlResolver('http://10.0.2.2:8080'));

  Map<String, dynamic> json({Object? eliminado}) => {
        'idMensaje': 5,
        'idEmisor': 2,
        'nombreEmisor': 'Ana',
        'contenido': 'Hola',
        'fechaEnvio': '2026-11-23T10:00:00Z',
        'fechaLectura': null,
        'eliminado': ?eliminado,
      };

  test('ChatMapper convierte un mensaje y lo marca como no eliminado por defecto', () {
    final mensaje = mapper.mensajeDesdeJson(json());
    expect(mensaje.id, 5);
    expect(mensaje.emisorId, 2);
    expect(mensaje.contenido, 'Hola');
    expect(mensaje.leido, isFalse);
    expect(mensaje.eliminado, isFalse);
  });

  test('ChatMapper reconoce los mensajes eliminados', () {
    final mensaje = mapper.mensajeDesdeJson({...json(eliminado: true), 'contenido': ''});
    expect(mensaje.eliminado, isTrue);
    expect(mensaje.contenido, isEmpty);
  });
}
