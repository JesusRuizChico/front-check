import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/rutas.dart';
import '../../../../core/utils/formato.dart';
import '../../../../core/widgets/avatar_usuario.dart';
import '../../../../core/widgets/estado_vacio.dart';
import '../../../../domain/models/chat_model.dart';
import '../../../auth/application/sesion_controller.dart';
import '../../../auth/presentation/widgets/boton_cerrar_sesion.dart';
import '../../../properties/presentation/widgets/theme_selector_sheet.dart';
import '../../application/chat_controller.dart';
import '../../application/conversaciones_controller.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  static const _todos = 'Todos';
  static const _noLeidos = 'No leídos';

  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';
  String _categoriaSeleccionada = _todos;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Conversacion> _filtrar(List<Conversacion> todas) {
    final consulta = _filtroTexto.toLowerCase().trim();
    return todas.where((c) {
      if (consulta.isNotEmpty) {
        final coincide = c.otroUsuarioNombre.toLowerCase().contains(consulta) ||
            (c.ultimoMensaje?.contenido.toLowerCase().contains(consulta) ?? false);
        if (!coincide) return false;
      }
      if (_categoriaSeleccionada == _noLeidos) return c.mensajesNoLeidos > 0;
      return true;
    }).toList();
  }

  void _abrir(Conversacion conversacion, String rolContraparte) {
    context.push(
      Rutas.chat,
      extra: ChatArgs(
        destino: DestinoChat.conversacion(conversacion.id),
        nombre: conversacion.otroUsuarioNombre,
        fotoUrl: conversacion.otroUsuarioFoto,
        rol: rolContraparte,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usuario = ref.watch(sesionProvider).usuario;
    final conversaciones = ref.watch(conversacionesProvider);
    final rolContraparte = usuario?.rolContraparte ?? 'Contacto';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Cambiar Tema',
            onPressed: () => ThemeSelectorSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            tooltip: 'Mi Perfil',
            onPressed: () => context.push(Rutas.perfil),
          ),
          const BotonCerrarSesion(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filtroTexto = val),
              decoration: InputDecoration(
                hintText: 'Buscar en conversaciones...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _filtroTexto.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filtroTexto = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [_todos, _noLeidos].map((cat) {
                final isSelected = _categoriaSeleccionada == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _categoriaSeleccionada = cat);
                    },
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(conversacionesProvider.notifier).refrescar(),
              child: conversaciones.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ListaDesplazable(
                  child: EstadoVacio(
                    icono: Icons.cloud_off_rounded,
                    titulo: 'No se pudieron cargar los mensajes',
                    descripcion: error.toString(),
                    accion: OutlinedButton(
                      onPressed: () => ref.read(conversacionesProvider.notifier).refrescar(),
                      child: const Text('Reintentar'),
                    ),
                  ),
                ),
                data: (todas) {
                  final filtradas = _filtrar(todas);
                  if (filtradas.isEmpty) {
                    return _ListaDesplazable(
                      child: EstadoVacio(
                        icono: Icons.chat_bubble_outline_rounded,
                        titulo: todas.isEmpty ? 'No hay conversaciones' : 'Sin resultados',
                        descripcion: todas.isEmpty
                            ? (usuario?.esArrendador ?? false
                                ? 'Aquí verás los mensajes de los inquilinos interesados en tus propiedades.'
                                : 'Inicia una conversación desde cualquier propiedad del catálogo.')
                            : 'No hay conversaciones que coincidan con tu búsqueda.',
                      ),
                    );
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtradas.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final conv = filtradas[index];
                      return _ConversacionCard(
                        conversacion: conv,
                        rolContraparte: rolContraparte,
                        miUsuarioId: usuario?.id,
                        onTap: () => _abrir(conv, rolContraparte),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Permite el gesto de "jalar para actualizar" aunque no haya elementos.
class _ListaDesplazable extends StatelessWidget {
  final Widget child;

  const _ListaDesplazable({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(height: constraints.maxHeight, child: child),
      ),
    );
  }
}

class _ConversacionCard extends StatelessWidget {
  final Conversacion conversacion;
  final String rolContraparte;
  final int? miUsuarioId;
  final VoidCallback onTap;

  const _ConversacionCard({
    required this.conversacion,
    required this.rolContraparte,
    required this.miUsuarioId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = conversacion.mensajesNoLeidos > 0;
    final ultimo = conversacion.ultimoMensaje;
    final vistaPrevia = ultimo == null
        ? 'Sin mensajes'
        : (miUsuarioId != null && ultimo.esMio(miUsuarioId!) ? 'Tú: ${ultimo.contenido}' : ultimo.contenido);

    return Card(
      elevation: hasUnread ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: hasUnread ? theme.colorScheme.primary.withValues(alpha: 0.5) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AvatarUsuario(
                nombre: conversacion.otroUsuarioNombre,
                fotoUrl: conversacion.otroUsuarioFoto,
                radio: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            conversacion.otroUsuarioNombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          Formato.haceCuanto(conversacion.fechaActividad),
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rolContraparte,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vistaPrevia,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: hasUnread
                                  ? theme.textTheme.bodyLarge?.color
                                  : theme.textTheme.bodySmall?.color,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${conversacion.mensajesNoLeidos}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
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
