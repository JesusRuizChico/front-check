import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_client.dart';

class ApiClient {
  static const String _baseUrl = 'http://localhost:8080/api';
  String? _cookie;
  String? _csrfToken;
  String? _csrfHeaderName;

  final _client = getClient();

  /// Obtiene o actualiza el token CSRF y la cookie asociada
  Future<void> fetchCsrf() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/csrf'),
      headers: _cookie != null ? {'Cookie': _cookie!} : null,
    );

    _updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      _csrfToken = data['token'];
      _csrfHeaderName = data['headerName'] ?? 'X-XSRF-TOKEN';
    } else {
      throw Exception('Failed to fetch CSRF token');
    }
  }

  Future<dynamic> get(String path) async {
    if (_csrfToken == null) {
      await fetchCsrf();
    }

    final headers = <String, String>{
      'Accept': 'application/json',
    };
    
    if (_cookie != null) {
      headers['Cookie'] = _cookie!;
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
    );

    _updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['mensaje'] ?? 'Error desconocido');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    // Si no tenemos token CSRF, lo obtenemos primero
    if (_csrfToken == null) {
      await fetchCsrf();
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_cookie != null) {
      headers['Cookie'] = _cookie!;
    }
    
    if (_csrfToken != null && _csrfHeaderName != null) {
      headers[_csrfHeaderName!] = _csrfToken!;
    }

    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(data),
    );

    _updateCookie(response);

    // Si el login fue exitoso, la sesión rota y el CSRF anterior se invalida
    if (path == '/auth/login' && response.statusCode == 200) {
      await fetchCsrf();
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['mensaje'] ?? 'Error desconocido');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }



  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> data) async {
  if (_csrfToken == null) {
    await fetchCsrf();
  }

  final headers = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  if (_cookie != null) {
    headers['Cookie'] = _cookie!;
  }
  
  if (_csrfToken != null && _csrfHeaderName != null) {
    headers[_csrfHeaderName!] = _csrfToken!;
  }

  final response = await _client.put(
    Uri.parse('$_baseUrl$path'),
    headers: headers,
    body: jsonEncode(data),
  );

  _updateCookie(response);

  if (response.statusCode >= 200 && response.statusCode < 300) {
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  } else {
    try {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['mensaje'] ?? 'Error al actualizar');
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Error: ${response.statusCode}');
      }
      rethrow;
    }
  }
}


  Future<Map<String, dynamic>> postMultipart(
      String path, 
      Map<String, String> fields, 
      List<http.MultipartFile> files) async {
    
    if (_csrfToken == null) {
      await fetchCsrf();
    }

    final url = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', url);
    
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    
    if (_cookie != null) {
      headers['Cookie'] = _cookie!;
    }
    
    if (_csrfToken != null && _csrfHeaderName != null) {
      headers[_csrfHeaderName!] = _csrfToken!;
    }

    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    
    _updateCookie(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['mensaje'] ?? 'Error desconocido');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }

  void _updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      // Manejar múltiples cookies si vienen separadas por coma (ej. JSESSIONID y XSRF-TOKEN)
      // En Flutter web/desktop hay que extraer bien el JSESSIONID.
      // Por simplicidad en este cliente tomamos todo el string.
      _cookie = rawCookie;
    }
  }
}

final apiClient = ApiClient();
