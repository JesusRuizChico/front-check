import 'package:web_socket_channel/web_socket_channel.dart';

import 'chat_socket_connector_stub.dart'
    if (dart.library.io) 'chat_socket_connector_io.dart'
    if (dart.library.js_interop) 'chat_socket_connector_web.dart' as platform;

WebSocketChannel connectChatSocket(Uri uri, Map<String, String> headers) =>
    platform.connectChatSocket(uri, headers);
