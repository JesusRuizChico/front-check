import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'http_client.dart';

class ApiClient {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  final Map<String, String> _cookies = {};
  String? _csrfToken;
  String? _csrfHeaderName;

  final _client = getClient();

  String? get cookieHeader {
    if (_cookies.isEmpty) return null;
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  /// Obtiene o actualiza el token CSRF y la cookie asociada
  Future<void> fetchCsrf() async {
    final headers = <String, String>{};
    final cookie = cookieHeader;
    if (cookie != null) {
      headers['Cookie'] = cookie;
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl/csrf'),
      headers: headers.isNotEmpty ? headers : null,
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

    final cookie = cookieHeader;
    if (cookie != null) {
      headers['Cookie'] = cookie;
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

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> data) async {
    if (_csrfToken == null) {
      await fetchCsrf();
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final cookie = cookieHeader;
    if (cookie != null) {
      headers['Cookie'] = cookie;
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
          throw Exception('Failed to process request: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> put(
      String path, Map<String, dynamic> data) async {
    if (_csrfToken == null) {
      await fetchCsrf();
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final cookie = cookieHeader;
    if (cookie != null) {
      headers['Cookie'] = cookie;
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
        throw Exception(errorData['mensaje'] ?? 'Error desconocido');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Failed to update data: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> patch(
      String path, Map<String, dynamic> data) async {
    if (_csrfToken == null) {
      await fetchCsrf();
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final cookie = cookieHeader;
    if (cookie != null) {
      headers['Cookie'] = cookie;
    }

    if (_csrfToken != null && _csrfHeaderName != null) {
      headers[_csrfHeaderName!] = _csrfToken!;
    }

    final response = await _client.patch(
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
        throw Exception(errorData['mensaje'] ?? 'Error desconocido');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Failed to patch data: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }

  Future<dynamic> delete(String path) async {
    if (_csrfToken == null) {
      await fetchCsrf();
    }

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    final cookie = cookieHeader;
    if (cookie != null) {
      headers['Cookie'] = cookie;
    }

    if (_csrfToken != null && _csrfHeaderName != null) {
      headers[_csrfHeaderName!] = _csrfToken!;
    }

    final response = await _client.delete(
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
          throw Exception('Failed to delete: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> postMultipart(String path,
      Map<String, String> fields, List<http.MultipartFile> files) async {
    if (_csrfToken == null) {
      await fetchCsrf();
    }

    final url = Uri.parse('$_baseUrl$path');
    final request = http.MultipartRequest('POST', url);

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    final cookie = cookieHeader;
    if (cookie != null) {
      headers['Cookie'] = cookie;
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
          throw Exception('Failed to submit form: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    try {
      await post('/auth/logout', {});
    } catch (_) {}
    _cookies.clear();
    _csrfToken = null;
  }

  void _updateCookie(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      // Manejar múltiples cookies separadas por comas que no forman parte de fechas GMT
      final parts = rawCookie.split(RegExp(r',(?=\s*[A-Za-z0-9_\-]+=[^;]+)'));
      for (final part in parts) {
        final cookiePair = part.split(';')[0].trim();
        final equalsIdx = cookiePair.indexOf('=');
        if (equalsIdx != -1) {
          final name = cookiePair.substring(0, equalsIdx).trim();
          final val = cookiePair.substring(equalsIdx + 1).trim();
          if (val.isNotEmpty && val != '""') {
            _cookies[name] = val;
          }
        }
      }
    }
  }
}

final apiClient = ApiClient();
