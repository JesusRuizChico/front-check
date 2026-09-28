import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/chat_socket_connector.dart';

class ChatRealtimeClient {
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  final _connected = Completer<void>();
  final String conversationId;
  StreamSubscription<dynamic>? _subscription;
  WebSocketChannel? _channel;
  String _buffer = '';
  bool _disposed = false;

  ChatRealtimeClient(this.conversationId);

  Stream<Map<String, dynamic>> get events => _events.stream;

  Future<void> connect() async {
    if (apiClient.csrfToken == null) await apiClient.fetchCsrf();
    final headers = <String, String>{};
    final cookies = apiClient.webSocketCookieHeader;
    if (cookies.isNotEmpty) headers['Cookie'] = cookies;

    _channel = connectChatSocket(apiClient.webSocketUri, headers);
    await _channel!.ready.timeout(const Duration(seconds: 8));
    _subscription = _channel!.stream.listen(
      _receive,
      onError: (Object error, StackTrace stackTrace) {
        if (!_connected.isCompleted) {
          _connected.completeError(error, stackTrace);
        }
        if (!_events.isClosed) _events.addError(error, stackTrace);
      },
      onDone: () {
        if (!_connected.isCompleted) {
          _connected
              .completeError(StateError('El servidor cerró la conexión.'));
        }
      },
    );

    _sendFrame('CONNECT', {
      'accept-version': '1.2',
      'heart-beat': '0,0',
      'X-XSRF-TOKEN': apiClient.csrfToken ?? '',
    });
    await _connected.future.timeout(const Duration(seconds: 8));
    _sendFrame('SUBSCRIBE', {
      'id': 'chat-$conversationId',
      'destination': '/topic/conversaciones/$conversationId',
      'ack': 'auto',
    });
    _sendFrame('SUBSCRIBE', {
      'id': 'errores-$conversationId',
      'destination': '/user/queue/errores',
      'ack': 'auto',
    });
  }

  void _receive(dynamic data) {
    _buffer += data.toString();
    while (true) {
      final end = _buffer.indexOf('\u0000');
      if (end < 0) return;
      final frame = _buffer.substring(0, end).trimLeft();
      _buffer = _buffer.substring(end + 1);
      if (frame.isEmpty) continue;
      _handleFrame(frame);
    }
  }

  void _handleFrame(String frame) {
    final separator = frame.indexOf('\n\n');
    final headerBlock = separator < 0 ? frame : frame.substring(0, separator);
    final body = separator < 0 ? '' : frame.substring(separator + 2);
    final lines = headerBlock.split('\n');
    if (lines.isEmpty) return;
    final command = lines.first.trim();

    if (command == 'CONNECTED') {
      if (!_connected.isCompleted) _connected.complete();
      return;
    }
    if (command == 'ERROR') {
      final message = body.isEmpty ? 'No se pudo conectar al chat.' : body;
      if (!_connected.isCompleted) {
        _connected.completeError(StateError(message));
      } else if (!_events.isClosed) {
        _events.addError(StateError(message));
      }
      return;
    }
    if (command != 'MESSAGE' || body.isEmpty || _events.isClosed) return;

    try {
      final payload = jsonDecode(body);
      if (payload is Map<String, dynamic>) _events.add(payload);
    } on FormatException {
      _events.addError(
          StateError('El servidor envió un evento de chat inválido.'));
    }
  }

  void _sendFrame(String command, Map<String, String> headers) {
    if (_disposed || _channel == null) return;
    final headerLines = headers.entries.map((header) {
      return '${header.key}:${_escapeHeader(header.value)}';
    }).join('\n');
    _channel!.sink.add('$command\n$headerLines\n\n\u0000');
  }

  String _escapeHeader(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll('\r', '\\r')
      .replaceAll('\n', '\\n')
      .replaceAll(':', '\\c');

  Future<void> dispose() async {
    _disposed = true;
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _events.close();
  }
}
