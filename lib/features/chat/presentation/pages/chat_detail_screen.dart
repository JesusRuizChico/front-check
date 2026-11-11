import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/mock_database.dart';
import '../../../../domain/models/chat_model.dart';
import '../../../properties/presentation/widgets/theme_selector_sheet.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversacionId;

  const ChatDetailScreen({
    super.key,
    required this.conversacionId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mockDatabase.marcarConversacionLeida(widget.conversacionId);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _enviarMensaje() {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    final miId = mockDatabase.usuarioActual?.id ?? 2;
    final conv = mockDatabase.conversaciones.firstWhere(
      (c) => c.id == widget.conversacionId,
      orElse: () => mockDatabase.conversaciones.first,
    );

    mockDatabase.enviarMensaje(
      conversacionId: widget.conversacionId,
      emisorId: miId,
      receptorId: conv.otroUsuarioId,
      contenido: texto,
    );

    _mensajeController.clear();
    setState(() => _isComposing = false);

    Timer(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final miId = mockDatabase.usuarioActual?.id ?? 2;

    return AnimatedBuilder(
      animation: mockDatabase,
      builder: (context, _) {
        final convList = mockDatabase.conversaciones.where((c) => c.id == widget.conversacionId);
        if (convList.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(child: Text('Conversación no encontrada')),
          );
        }

        final conv = convList.first;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: conv.otroUsuarioFoto != null
                      ? NetworkImage(conv.otroUsuarioFoto!)
                      : null,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: conv.otroUsuarioFoto == null
                      ? Text(
                          conv.otroUsuarioNombre.isNotEmpty ? conv.otroUsuarioNombre[0] : 'U',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv.otroUsuarioNombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            conv.otroUsuarioRol,
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                tooltip: 'Tema',
                onPressed: () => ThemeSelectorSheet.show(context),
              ),
              IconButton(
                icon: const Icon(Icons.phone_outlined),
                tooltip: 'Llamar',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Llamando a ${conv.otroUsuarioNombre}...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de contexto de propiedad
              if (conv.propiedadTitulo != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  child: Row(
                    children: [
                      Icon(Icons.home_work_outlined, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Referente a: ${conv.propiedadTitulo}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Lista de mensajes
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: conv.mensajes.length,
                  itemBuilder: (context, index) {
                    final msg = conv.mensajes[index];
                    final esMio = msg.emisorId == miId;

                    return Align(
                      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: esMio
                              ? theme.colorScheme.primary
                              : (theme.brightness == Brightness.dark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(esMio ? 18 : 4),
                            bottomRight: Radius.circular(esMio ? 4 : 18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.contenido,
                              style: TextStyle(
                                color: esMio
                                    ? Colors.white
                                    : (theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatearHoraMensaje(msg.fechaHora),
                                  style: TextStyle(
                                    color: esMio
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                                if (esMio) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.done_all_rounded,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Barra de entrada de texto
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        tooltip: 'Adjuntar imagen',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Simulador: Imagen seleccionada para adjuntar.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _mensajeController,
                          onChanged: (val) {
                            setState(() => _isComposing = val.trim().isNotEmpty);
                          },
                          onSubmitted: (_) => _enviarMensaje(),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            filled: true,
                            fillColor: theme.scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _isComposing
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: _isComposing ? _enviarMensaje : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatearHoraMensaje(DateTime dt) {
    final hora = dt.hour.toString().padLeft(2, '0');
    final minuto = dt.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }
}

