import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formato.dart';
import '../../../../core/widgets/avatar_usuario.dart';
import '../../../../core/widgets/avisos.dart';
import '../../../../domain/models/chat_model.dart';
import '../../../auth/application/sesion_controller.dart';
import '../../../properties/presentation/widgets/theme_selector_sheet.dart';
import '../../application/chat_controller.dart';

/// Datos para abrir la pantalla de un chat.
class ChatArgs {
  final DestinoChat destino;
  final String nombre;
  final String? fotoUrl;
  final String rol;
  final String? propiedadTitulo;

  const ChatArgs({
    required this.destino,
    required this.nombre,
    this.fotoUrl,
    required this.rol,
    this.propiedadTitulo,
  });
}

class ChatDetailScreen extends ConsumerStatefulWidget {
  final ChatArgs args;

  const ChatDetailScreen({super.key, required this.args});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _mensajeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

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

  Future<void> _enviarMensaje() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;
    _mensajeController.clear();
    setState(() => _isComposing = false);
    try {
      await ref.read(chatProvider(widget.args.destino).notifier).enviar(texto);
    } catch (error) {
      if (!mounted) return;
      _mensajeController.text = texto;
      setState(() => _isComposing = true);
      Avisos.error(context, error);
    }
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
    final args = widget.args;
    final miId = ref.watch(usuarioActualIdProvider);
    final chat = ref.watch(chatProvider(args.destino));

    ref.listen(chatProvider(args.destino).select((s) => s.mensajes.length), (anterior, actual) {
      if (actual != anterior) _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Row(
          children: [
            AvatarUsuario(nombre: args.nombre, fotoUrl: args.fotoUrl, radio: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    args.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(args.rol, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
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
        ],
      ),
      body: Column(
        children: [
          if (args.propiedadTitulo != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Icon(Icons.home_work_outlined, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Referente a: ${args.propiedadTitulo}',
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
          if (chat.avisoRespuestaLenta)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.withValues(alpha: 0.15),
              child: const Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 18, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El arrendador no ha entrado en los últimos días; su respuesta podría tardar.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildMensajes(theme, chat, miId)),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mensajeController,
                      maxLength: 4000,
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (val) => setState(() => _isComposing = val.trim().isNotEmpty),
                      onSubmitted: (_) => _enviarMensaje(),
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        counterText: '',
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
                      color: _isComposing && !chat.enviando
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: 'Enviar',
                      icon: chat.enviando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _isComposing && !chat.enviando ? _enviarMensaje : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensajes(ThemeData theme, ChatState chat, int? miId) {
    if (chat.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (chat.mensajes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            chat.error ??
                (chat.conversacionId == null
                    ? 'Escribe tu primer mensaje para contactar a ${widget.args.nombre}.'
                    : 'Aún no hay mensajes en esta conversación.'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: chat.mensajes.length,
      itemBuilder: (context, index) {
        final msg = chat.mensajes[index];
        return _BurbujaMensaje(mensaje: msg, esMio: miId != null && msg.esMio(miId));
      },
    );
  }
}

class _BurbujaMensaje extends StatelessWidget {
  final Mensaje mensaje;
  final bool esMio;

  const _BurbujaMensaje({required this.mensaje, required this.esMio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final oscuro = theme.brightness == Brightness.dark;
    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: esMio
              ? theme.colorScheme.primary
              : (oscuro ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(esMio ? 18 : 4),
            bottomRight: Radius.circular(esMio ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              mensaje.contenido,
              style: TextStyle(
                color: esMio ? Colors.white : (oscuro ? Colors.white : Colors.black87),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Formato.hora(mensaje.fechaEnvio),
                  style: TextStyle(
                    color: esMio ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                if (esMio) ...[
                  const SizedBox(width: 4),
                  Icon(
                    mensaje.leido ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
