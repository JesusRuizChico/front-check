import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_exception.dart';
import 'http_client.dart';

/// Implementación HTTP del [ApiClient] con sesión por cookie y protección CSRF.
class HttpApiClient implements ApiClient {
  HttpApiClient({required String baseUrl, http.Client? client})
      : _apiUrl = '$baseUrl/api',
        _client = client ?? getClient();

  final String _apiUrl;
  final http.Client _client;
  final Map<String, String> _cookies = {};
  final _sesionExpirada = StreamController<void>.broadcast();

  String? _csrfToken;
  String _csrfHeader = 'X-XSRF-TOKEN';

  @override
  Stream<void> get sesionExpirada => _sesionExpirada.stream;

  @override
  Future<dynamic> get(String ruta) => _enviarJson('GET', ruta);

  @override
  Future<dynamic> post(String ruta, [Object? cuerpo]) => _enviarJson('POST', ruta, cuerpo);

  @override
  Future<dynamic> put(String ruta, [Object? cuerpo]) => _enviarJson('PUT', ruta, cuerpo);

  @override
  Future<dynamic> patch(String ruta, [Object? cuerpo]) => _enviarJson('PATCH', ruta, cuerpo);

  @override
  Future<dynamic> delete(String ruta) => _enviarJson('DELETE', ruta);

  @override
  Future<dynamic> postMultipart(
    String ruta, {
    Map<String, String> campos = const {},
    List<ArchivoMultipart> archivos = const [],
  }) {
    return _ejecutar(ruta, mutante: true, construir: () {
      final request = http.MultipartRequest('POST', _uri(ruta))
        ..fields.addAll(campos)
        ..files.addAll(archivos.map((archivo) => http.MultipartFile.fromBytes(
              archivo.campo,
              archivo.bytes,
              filename: archivo.nombre,
            )));
      request.headers.addAll(_encabezados(mutante: true));
      return request;
    });
  }

  @override
  void reiniciar() {
    _cookies.clear();
    _csrfToken = null;
  }

  Future<dynamic> _enviarJson(String metodo, String ruta, [Object? cuerpo]) {
    final mutante = metodo != 'GET';
    return _ejecutar(ruta, mutante: mutante, construir: () {
      final request = http.Request(metodo, _uri(ruta));
      request.headers.addAll(_encabezados(mutante: mutante));
      if (cuerpo != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(cuerpo);
      }
      return request;
    });
  }

  Future<dynamic> _ejecutar(
    String ruta, {
    required bool mutante,
    required http.BaseRequest Function() construir,
  }) async {
    if (mutante && _csrfToken == null) {
      await _obtenerCsrf();
    }
    var respuesta = await _enviar(construir());

    // El token CSRF rota al iniciar o cerrar sesión: se renueva y se reintenta una vez.
    if (mutante && respuesta.statusCode == 403) {
      await _obtenerCsrf();
      respuesta = await _enviar(construir());
    }
    if (ruta.startsWith('/auth/')) {
      _csrfToken = null;
    }
    return _procesar(ruta, respuesta);
  }

  Future<http.Response> _enviar(http.BaseRequest request) async {
    try {
      final respuesta = await http.Response.fromStream(await _client.send(request));
      _guardarCookies(respuesta);
      return respuesta;
    } on Exception {
      throw const ApiException(
        'No se pudo conectar con el servidor. Verifica tu conexión e inténtalo de nuevo.',
      );
    }
  }

  Future<void> _obtenerCsrf() async {
    final request = http.Request('GET', _uri('/csrf'))
      ..headers.addAll(_encabezados(mutante: false));
    final respuesta = await _enviar(request);
    if (respuesta.statusCode != 200) {
      throw ApiException('No se pudo iniciar la comunicación segura con el servidor.',
          statusCode: respuesta.statusCode);
    }
    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    _csrfToken = datos['token'] as String?;
    _csrfHeader = datos['headerName'] as String? ?? 'X-XSRF-TOKEN';
  }

  dynamic _procesar(String ruta, http.Response respuesta) {
    final codigo = respuesta.statusCode;
    if (codigo >= 200 && codigo < 300) {
      if (respuesta.body.isEmpty) return null;
      return jsonDecode(utf8.decode(respuesta.bodyBytes));
    }
    if (codigo == 401 && !ruta.startsWith('/auth/')) {
      _sesionExpirada.add(null);
    }
    throw ApiException(_mensajeDeError(respuesta), statusCode: codigo);
  }

  String _mensajeDeError(http.Response respuesta) {
    try {
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (datos is Map<String, dynamic>) {
        final errores = datos['errores'];
        if (errores is Map && errores.isNotEmpty) {
          return errores.values.first.toString();
        }
        final mensaje = datos['mensaje'];
        if (mensaje is String && mensaje.isNotEmpty) return mensaje;
      }
    } on FormatException {
      // El cuerpo no es JSON; se usa el mensaje genérico.
    }
    return switch (respuesta.statusCode) {
      401 => 'Tu sesión expiró. Inicia sesión de nuevo.',
      403 => 'No tienes permiso para realizar esta acción.',
      404 => 'El recurso solicitado no existe.',
      >= 500 => 'El servidor tuvo un problema. Inténtalo más tarde.',
      _ => 'No se pudo completar la solicitud.',
    };
  }

  Map<String, String> _encabezados({required bool mutante}) {
    final encabezados = <String, String>{'Accept': 'application/json'};
    if (_cookies.isNotEmpty) {
      encabezados['Cookie'] = _cookies.entries.map((c) => '${c.key}=${c.value}').join('; ');
    }
    if (mutante && _csrfToken != null) {
      encabezados[_csrfHeader] = _csrfToken!;
    }
    return encabezados;
  }

  Uri _uri(String ruta) => Uri.parse('$_apiUrl$ruta');

  /// En móvil las cookies se gestionan manualmente; en web las maneja el navegador.
  void _guardarCookies(http.Response respuesta) {
    final encabezado = respuesta.headers['set-cookie'];
    if (encabezado == null) return;
    final partes = encabezado.split(RegExp(r',(?=\s*[A-Za-z0-9_\-]+=)'));
    for (final parte in partes) {
      final par = parte.split(';').first.trim();
      final separador = par.indexOf('=');
      if (separador <= 0) continue;
      final nombre = par.substring(0, separador).trim();
      final valor = par.substring(separador + 1).trim();
      if (valor.isEmpty || valor == '""') {
        _cookies.remove(nombre);
      } else {
        _cookies[nombre] = valor;
      }
    }
  }
}
