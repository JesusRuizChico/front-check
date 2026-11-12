import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/network/media_url_resolver.dart';
import 'package:front_check/data/mappers/chat_mapper.dart';
import 'package:front_check/data/mappers/propiedad_mapper.dart';
import 'package:front_check/data/mappers/usuario_mapper.dart';

void main() {
  const media = MediaUrlResolver('http://10.0.2.2:8080');

  test('PropiedadMapper convierte la respuesta del backend y resuelve las imágenes locales', () {
    final propiedad = const PropiedadMapper(media).desdeJson({
      'idPropiedad': 7,
      'titulo': 'Depa Centro',
      'descripcion': 'Bonito',
      'precioMensual': 12500.5,
      'calle': 'Hidalgo',
      'numeroExterior': '5',
      'numeroInterior': null,
      'colonia': 'Centro',
      'municipio': 'Querétaro',
      'estadoUbicacion': 'Querétaro',
      'codigoPostal': '76000',
      'habitaciones': 3,
      'banos': 2,
      'estacionamientos': 1,
      'metrosCuadrados': 90,
      'estado': 'pausada',
      'verificada': false,
      'fechaPublicacion': '2026-11-12T04:28:22.809Z',
      'imagenes': ['/uploads/propiedades/a.png'],
      'servicios': [
        {'idServicio': 3, 'nombre': 'Internet / Wi-Fi'},
      ],
      'arrendador': {'idUsuario': 2, 'nombre': 'Luis', 'telefono': '4421112233', 'fotoPerfil': null},
      'esFavorito': true,
    });

    expect(propiedad.id, 7);
    expect(propiedad.precioMensual, 12500.5);
    expect(propiedad.imagenes.single, 'http://10.0.2.2:8080/uploads/propiedades/a.png');
    expect(propiedad.servicios, ['Internet / Wi-Fi']);
    expect(propiedad.arrendadorNombre, 'Luis');
    expect(propiedad.arrendadorFoto, isNull);
    expect(propiedad.esActiva, isFalse);
    expect(propiedad.etiquetaEstado, 'Pausada');
    expect(propiedad.esFavorito, isTrue);
    expect(propiedad.metrosCuadrados, 90);
  });

  test('UsuarioMapper lee roles, biografía y foto', () {
    final usuario = const UsuarioMapper(media).desdeJson({
      'id': 4,
      'nombre': 'Ana Pérez',
      'correo': 'ana@example.com',
      'telefono': '4420000000',
      'fotoPerfil': '/uploads/perfiles/f.jpg',
      'biografia': 'Hola',
      'rolesActivos': ['arrendador'],
    });
    expect(usuario.esArrendador, isTrue);
    expect(usuario.rolContraparte, 'Inquilino');
    expect(usuario.fotoUrl, 'http://10.0.2.2:8080/uploads/perfiles/f.jpg');
    expect(usuario.primerNombre, 'Ana');
  });

  test('ChatMapper usa la fecha de creación cuando aún no hay mensajes', () {
    final conversacion = const ChatMapper(media).conversacionDesdeJson({
      'idConversacion': 9,
      'otroParticipante': {'idUsuario': 3, 'nombre': 'Luis', 'fotoPerfil': null},
      'ultimoMensaje': null,
      'fechaCreacion': '2026-11-12T10:00:00Z',
      'fechaUltimoMensaje': null,
      'mensajesNoLeidos': 2,
      'avisoRespuestaLenta': false,
    });
    expect(conversacion.id, 9);
    expect(conversacion.ultimoMensaje, isNull);
    expect(conversacion.mensajesNoLeidos, 2);
    expect(conversacion.fechaActividad, DateTime.parse('2026-11-12T10:00:00Z').toLocal());
  });

  test('MediaUrlResolver respeta URLs absolutas y vacías', () {
    expect(media.resolver('https://cdn.example.com/a.png'), 'https://cdn.example.com/a.png');
    expect(media.resolver(''), isNull);
    expect(media.resolver(null), isNull);
    expect(media.resolver('uploads/x.png'), 'http://10.0.2.2:8080/uploads/x.png');
  });
}
