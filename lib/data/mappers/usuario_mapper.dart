import '../../core/network/media_url_resolver.dart';
import '../../domain/models/usuario_model.dart';
import 'json_lector.dart';

class UsuarioMapper {
  final MediaUrlResolver _media;

  const UsuarioMapper(this._media);

  Usuario desdeJson(Map<String, dynamic> json) {
    return Usuario(
      id: JsonLector.entero(json['id']),
      nombre: JsonLector.texto(json['nombre']),
      correo: JsonLector.texto(json['correo']),
      telefono: JsonLector.textoOpcional(json['telefono']),
      fotoUrl: _media.resolver(JsonLector.textoOpcional(json['fotoPerfil'])),
      bio: JsonLector.textoOpcional(json['biografia']),
      roles: JsonLector.lista(json['rolesActivos']).map((rol) => rol.toString()).toList(),
    );
  }
}
