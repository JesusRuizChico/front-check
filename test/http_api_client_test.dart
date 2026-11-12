import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/core/network/api_exception.dart';
import 'package:front_check/core/network/http_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object cuerpo, int codigo, {Map<String, String> encabezados = const {}}) =>
    http.Response(jsonEncode(cuerpo), codigo, headers: {'content-type': 'application/json', ...encabezados});

void main() {
  test('Obtiene el token CSRF antes de una petición que modifica datos y envía la cookie de sesión', () async {
    final peticiones = <http.Request>[];
    final cliente = HttpApiClient(
      baseUrl: 'http://api',
      client: MockClient((request) async {
        peticiones.add(request);
        if (request.url.path == '/api/csrf') {
          return _json({'token': 'abc', 'headerName': 'X-XSRF-TOKEN'}, 200,
              encabezados: {'set-cookie': 'JSESSIONID=s1; Path=/; HttpOnly'});
        }
        return _json({'ok': true}, 200);
      }),
    );

    await cliente.put('/perfil', {'nombre': 'Ana'});

    expect(peticiones.map((r) => r.url.path), ['/api/csrf', '/api/perfil']);
    expect(peticiones.last.headers['X-XSRF-TOKEN'], 'abc');
    expect(peticiones.last.headers['Cookie'], 'JSESSIONID=s1');
    expect(jsonDecode(peticiones.last.body), {'nombre': 'Ana'});
  });

  test('Renueva el token y reintenta una vez cuando el servidor responde 403', () async {
    var tokens = 0;
    var intentos = 0;
    final cliente = HttpApiClient(
      baseUrl: 'http://api',
      client: MockClient((request) async {
        if (request.url.path == '/api/csrf') {
          tokens++;
          return _json({'token': 't$tokens', 'headerName': 'X-XSRF-TOKEN'}, 200);
        }
        intentos++;
        return request.headers['X-XSRF-TOKEN'] == 't2' ? _json({}, 200) : _json({}, 403);
      }),
    );

    await cliente.post('/conversaciones/1/mensajes', {'contenido': 'Hola'});

    expect(tokens, 2);
    expect(intentos, 2);
  });

  test('Un 401 fuera de autenticación notifica que la sesión expiró', () async {
    final cliente = HttpApiClient(
      baseUrl: 'http://api',
      client: MockClient((_) async => _json({'codigo': 'NO_AUTENTICADO', 'mensaje': 'Inicia sesión'}, 401)),
    );
    final expiraciones = <void>[];
    cliente.sesionExpirada.listen(expiraciones.add);

    await expectLater(
      cliente.get('/perfil'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
    );
    await Future<void>.delayed(Duration.zero);
    expect(expiraciones, hasLength(1));
  });

  test('Muestra el primer error de validación enviado por el backend', () async {
    final cliente = HttpApiClient(
      baseUrl: 'http://api',
      client: MockClient((request) async {
        if (request.url.path == '/api/csrf') return _json({'token': 'x'}, 200);
        return _json({
          'codigo': 'DATOS_INVALIDOS',
          'mensaje': 'Existen errores en los datos enviados.',
          'errores': {'telefono': 'El teléfono debe tener 10 dígitos'},
        }, 400);
      }),
    );

    await expectLater(
      cliente.put('/perfil', {'telefono': '12'}),
      throwsA(isA<ApiException>().having((e) => e.mensaje, 'mensaje', 'El teléfono debe tener 10 dígitos')),
    );
  });
}
