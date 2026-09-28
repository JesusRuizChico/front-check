import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/chat_realtime_client.dart';
import '../../data/chat_service.dart';
import '../widgets/chat_avatar.dart';

class ChatScreen extends StatefulWidget {
  final int? propertyId;
  final int? conversationId;
  final ConversationSummary? initialConversation;

  const ChatScreen.forProperty({
    super.key,
    required this.propertyId,
  })  : conversationId = null,
        initialConversation = null;

  const ChatScreen.forConversation({
    super.key,
    required this.conversationId,
    this.initialConversation,
  }) : propertyId = null;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[];

  ChatUser? _recipient;
  ChatRealtimeClient? _realtime;
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;
  int? _conversationId;
  int? _currentUserId;
  int? _nextBeforeId;
  bool _hasMore = false;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isLoadingOlder = false;
  bool _slowReplyWarning = false;
  String? _error;
  String _connectionState = 'Conectando';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initialize();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    _eventSubscription?.cancel();
    _realtime?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      _currentUserId = await chatService.currentUserId();
      if (widget.propertyId != null) {
        final target =
            await chatService.resolveFromProperty(widget.propertyId!);
        _recipient = target.landlord;
        _conversationId = target.conversationId;
      } else {
        final summary = widget.initialConversation ??
            (await chatService.listConversations()).firstWhere(
              (item) => item.id == widget.conversationId,
            );
        _recipient = summary.otherParticipant;
        _conversationId = summary.id;
        _slowReplyWarning = summary.slowReplyWarning;
      }

      if (_conversationId != null) {
        final page = await chatService.loadMessages(_conversationId!);
        _messages
          ..clear()
          ..addAll(page.messages);
        _nextBeforeId = page.nextBeforeId;
        _hasMore = page.hasMore;
        await chatService.markAsRead(_conversationId!);
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = null;
        _connectionState =
            _conversationId == null ? 'Nuevo chat' : 'Conectando';
      });
      _scrollToBottom();
      if (_conversationId != null) {
        unawaited(_connectRealtime(_conversationId!));
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = _cleanError(error);
      });
    }
  }

  Future<void> _connectRealtime(int conversationId) async {
    final client = chatService.realtimeClient(conversationId);
    _realtime = client;
    _eventSubscription = client.events.listen(
      _handleEvent,
      onError: (_) {
        if (mounted) {
          setState(() => _connectionState = 'Sin conexión en tiempo real');
        }
      },
    );
    try {
      await client.connect();
      if (mounted) setState(() => _connectionState = 'Conectado');
    } catch (_) {
      await client.dispose();
      if (mounted) {
        setState(() => _connectionState = 'Sin conexión en tiempo real');
      }
    }
  }

  void _handleEvent(Map<String, dynamic> event) {
    if (!mounted) return;
    if (event['tipo'] == 'MENSAJE' &&
        event['mensaje'] is Map<String, dynamic>) {
      final wasAtBottom = !_scrollController.hasClients ||
          _scrollController.position.maxScrollExtent -
                  _scrollController.position.pixels <
              120;
      final message = ChatMessage.fromJson(
        event['mensaje'] as Map<String, dynamic>,
      );
      _upsertMessage(message, scroll: wasAtBottom);
      if (event['avisoRespuestaLenta'] == true) {
        setState(() => _slowReplyWarning = true);
      }
    } else if (event['codigo'] != null && event['mensaje'] != null) {
      _showNotice(event['mensaje'].toString());
    } else if (event['tipo'] == 'LECTURA' &&
        (event['idUsuario'] as num?)?.toInt() != _currentUserId) {
      final readAt =
          DateTime.tryParse(event['fecha']?.toString() ?? '')?.toLocal();
      if (readAt != null) {
        setState(() {
          for (var index = 0; index < _messages.length; index++) {
            if (_messages[index].senderId == _currentUserId &&
                _messages[index].readAt == null) {
              _messages[index] = _messages[index].copyWith(readAt: readAt);
            }
          }
        });
      }
    }
  }

  void _upsertMessage(ChatMessage message, {bool scroll = false}) {
    final index = _messages.indexWhere((item) => item.id == message.id);
    setState(() {
      if (index < 0) {
        _messages.add(message);
        _messages.sort((a, b) => a.id.compareTo(b.id));
      } else {
        _messages[index] = message;
      }
    });
    if (scroll) _scrollToBottom();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels <= 60 &&
        _hasMore &&
        !_isLoadingOlder) {
      unawaited(_loadOlderMessages());
    }
  }

  Future<void> _loadOlderMessages() async {
    final conversationId = _conversationId;
    final beforeId = _nextBeforeId;
    if (conversationId == null || beforeId == null) return;
    setState(() => _isLoadingOlder = true);
    try {
      final page = await chatService.loadMessages(
        conversationId,
        beforeId: beforeId,
      );
      if (!mounted) return;
      setState(() {
        final knownIds = _messages.map((message) => message.id).toSet();
        _messages.insertAll(
          0,
          page.messages.where((message) => !knownIds.contains(message.id)),
        );
        _nextBeforeId = page.nextBeforeId;
        _hasMore = page.hasMore;
        _isLoadingOlder = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingOlder = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = _textController.text.trim();
    if (content.isEmpty) {
      _showNotice('Escribe un mensaje antes de enviarlo.');
      return;
    }
    if (content.length > 4000) {
      _showNotice('El mensaje no puede superar los 4000 caracteres.');
      return;
    }
    if (_isSending) return;

    setState(() => _isSending = true);
    try {
      final sent = _conversationId == null
          ? await chatService.sendFromProperty(widget.propertyId!, content)
          : await chatService.send(_conversationId!, content);
      _textController.clear();
      if (_conversationId == null && sent.conversationId != null) {
        _conversationId = sent.conversationId;
        unawaited(_connectRealtime(_conversationId!));
      }
      if (sent.slowReplyWarning) {
        setState(() => _slowReplyWarning = true);
      }
      _upsertMessage(sent.message, scroll: true);
    } catch (error) {
      _showNotice(_cleanError(error));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _cleanError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    unawaited(_initialize());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipient = _recipient;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: recipient == null
            ? const Text('Conversación')
            : Row(
                children: [
                  ChatAvatar(
                    name: recipient.name,
                    photoUrl: recipient.photoUrl,
                    radius: 20,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recipient.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _connectionState == 'Conectado'
                                    ? AppColors.success
                                    : theme.colorScheme.onSurfaceVariant,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _connectionState,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -90,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: .15),
                ),
              ),
            ),
          ),
          Column(
            children: [
              if (_slowReplyWarning) _slowReplyNotice(context),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _loadError(context)
                        : _messageList(context),
              ),
              if (!_isLoading && _error == null) _composer(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slowReplyNotice(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: .28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded,
              size: 18, color: AppColors.accentLight),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'El arrendador lleva varios días sin actividad. Su respuesta podría tardar más de lo habitual.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageList(BuildContext context) {
    final theme = Theme.of(context);
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 14),
              Text(
                'Pregunta por la disponibilidad',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 7),
              Text(
                'Tu mensaje abrirá una conversación con ${_recipient?.name ?? 'el arrendador'}.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: _messages.length + (_isLoadingOlder ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoadingOlder && index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final messageIndex = index - (_isLoadingOlder ? 1 : 0);
        return _MessageBubble(
          message: _messages[messageIndex],
          isMine: _messages[messageIndex].senderId == _currentUserId,
        );
      },
    );
  }

  Widget _loadError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: _retry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _composer(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: .96),
          border: Border(
            top: BorderSide(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 5,
                maxLength: 4000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje…',
                  counterText: '',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide:
                        BorderSide(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide:
                        BorderSide(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 9),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Material(
                color: theme.colorScheme.primary,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Enviar mensaje',
                  onPressed: _isSending ? null : _sendMessage,
                  icon: _isSending
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isMine
        ? theme.colorScheme.primary
        : theme.colorScheme.surface.withValues(alpha: .96);
    final textColor = isMine ? Colors.white : theme.colorScheme.onSurface;
    final time =
        '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .78,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 5),
              bottomRight: Radius.circular(isMine ? 5 : 18),
            ),
            border: isMine
                ? null
                : Border.all(color: theme.colorScheme.onSurfaceVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMine) ...[
                Text(
                  message.senderName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                message.content,
                style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor.withValues(alpha: .72),
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.readAt == null
                            ? Icons.check_rounded
                            : Icons.done_all_rounded,
                        size: 15,
                        color: message.readAt == null
                            ? textColor.withValues(alpha: .72)
                            : Colors.lightBlueAccent,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
