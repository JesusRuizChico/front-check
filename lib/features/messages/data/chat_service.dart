import '../../../core/network/api_client.dart';
import 'chat_realtime_client.dart';

class ChatUser {
  final int id;
  final String name;
  final String? photoUrl;

  const ChatUser({required this.id, required this.name, this.photoUrl});

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: (json['idUsuario'] as num).toInt(),
        name: json['nombre']?.toString() ?? 'Usuario',
        photoUrl: json['fotoPerfil']?.toString(),
      );
}

class ChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: (json['idMensaje'] as num).toInt(),
        senderId: (json['idEmisor'] as num).toInt(),
        senderName: json['nombreEmisor']?.toString() ?? 'Usuario',
        content: json['contenido']?.toString() ?? '',
        sentAt: DateTime.parse(json['fechaEnvio'].toString()).toLocal(),
        readAt: json['fechaLectura'] == null
            ? null
            : DateTime.parse(json['fechaLectura'].toString()).toLocal(),
      );

  ChatMessage copyWith({DateTime? readAt}) => ChatMessage(
        id: id,
        senderId: senderId,
        senderName: senderName,
        content: content,
        sentAt: sentAt,
        readAt: readAt ?? this.readAt,
      );
}

class ConversationSummary {
  final int id;
  final ChatUser otherParticipant;
  final ChatMessage? lastMessage;
  final DateTime lastActivity;
  final int unreadCount;
  final bool slowReplyWarning;

  const ConversationSummary({
    required this.id,
    required this.otherParticipant,
    required this.lastMessage,
    required this.lastActivity,
    required this.unreadCount,
    required this.slowReplyWarning,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    final lastMessageJson = json['ultimoMensaje'] as Map<String, dynamic>?;
    final activity = json['fechaUltimoMensaje'] ?? json['fechaCreacion'];
    return ConversationSummary(
      id: (json['idConversacion'] as num).toInt(),
      otherParticipant:
          ChatUser.fromJson(json['otroParticipante'] as Map<String, dynamic>),
      lastMessage: lastMessageJson == null
          ? null
          : ChatMessage.fromJson(lastMessageJson),
      lastActivity: DateTime.parse(activity.toString()).toLocal(),
      unreadCount: (json['mensajesNoLeidos'] as num?)?.toInt() ?? 0,
      slowReplyWarning: json['avisoRespuestaLenta'] == true,
    );
  }
}

class PropertyChatTarget {
  final int? conversationId;
  final ChatUser landlord;

  const PropertyChatTarget({
    required this.conversationId,
    required this.landlord,
  });

  factory PropertyChatTarget.fromJson(Map<String, dynamic> json) =>
      PropertyChatTarget(
        conversationId: (json['idConversacion'] as num?)?.toInt(),
        landlord: ChatUser.fromJson(json['arrendador'] as Map<String, dynamic>),
      );
}

class ChatPage {
  final List<ChatMessage> messages;
  final int? nextBeforeId;
  final bool hasMore;

  const ChatPage({
    required this.messages,
    required this.nextBeforeId,
    required this.hasMore,
  });

  factory ChatPage.fromJson(Map<String, dynamic> json) => ChatPage(
        messages: (json['mensajes'] as List<dynamic>? ?? const [])
            .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
            .toList(),
        nextBeforeId: (json['siguienteAntesDe'] as num?)?.toInt(),
        hasMore: json['hayMas'] == true,
      );
}

class SentChatMessage {
  final ChatMessage message;
  final int? conversationId;
  final bool slowReplyWarning;

  const SentChatMessage({
    required this.message,
    required this.conversationId,
    required this.slowReplyWarning,
  });
}

class ChatService {
  Future<List<ConversationSummary>> listConversations() async {
    final response = await apiClient.get('/conversaciones') as List<dynamic>;
    return response
        .map((item) =>
            ConversationSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PropertyChatTarget> resolveFromProperty(int propertyId) async {
    final response = await apiClient
        .get('/conversaciones/propiedad/$propertyId') as Map<String, dynamic>;
    return PropertyChatTarget.fromJson(response);
  }

  Future<ChatPage> loadMessages(int conversationId, {int? beforeId}) async {
    final query = beforeId == null ? '' : '?antesDe=$beforeId';
    final response = await apiClient.get(
      '/conversaciones/$conversationId/mensajes$query',
    ) as Map<String, dynamic>;
    return ChatPage.fromJson(response);
  }

  Future<SentChatMessage> sendFromProperty(
    int propertyId,
    String content,
  ) async {
    final response = await apiClient.post(
      '/conversaciones/propiedad/$propertyId/mensajes',
      {'contenido': content},
    );
    return SentChatMessage(
      message: ChatMessage.fromJson(
          response['mensajeInicial'] as Map<String, dynamic>),
      conversationId: (response['idConversacion'] as num).toInt(),
      slowReplyWarning: response['avisoRespuestaLenta'] == true,
    );
  }

  Future<SentChatMessage> send(int conversationId, String content) async {
    final response = await apiClient.post(
      '/conversaciones/$conversationId/mensajes',
      {'contenido': content},
    );
    return SentChatMessage(
      message:
          ChatMessage.fromJson(response['mensaje'] as Map<String, dynamic>),
      conversationId: conversationId,
      slowReplyWarning: response['avisoRespuestaLenta'] == true,
    );
  }

  Future<void> markAsRead(int conversationId) async {
    await apiClient.put('/conversaciones/$conversationId/lectura', const {});
  }

  Future<int> currentUserId() async {
    final response = await apiClient.get('/perfil') as Map<String, dynamic>;
    return (response['id'] as num).toInt();
  }

  ChatRealtimeClient realtimeClient(int conversationId) =>
      ChatRealtimeClient(conversationId.toString());
}

final chatService = ChatService();
