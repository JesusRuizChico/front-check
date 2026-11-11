import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/mock_database.dart';
import '../../../../domain/models/chat_model.dart';
import '../../../properties/presentation/widgets/theme_selector_sheet.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';
  String _categoriaSeleccionada = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final miUsuario = mockDatabase.usuarioActual;

    return AnimatedBuilder(
      animation: mockDatabase,
      builder: (context, _) {
        final todas = mockDatabase.conversaciones;
        final filtradas = todas.where((c) {
          if (_filtroTexto.isNotEmpty) {
            final query = _filtroTexto.toLowerCase();
            final matchNombre = c.otroUsuarioNombre.toLowerCase().contains(query);
            final matchMensaje = c.ultimoMensaje.toLowerCase().contains(query);
            final matchPropiedad = (c.propiedadTitulo ?? '').toLowerCase().contains(query);
            if (!matchNombre && !matchMensaje && !matchPropiedad) return false;
          }
          if (_categoriaSeleccionada == 'Arrendadores') {
            return c.otroUsuarioRol.toLowerCase().contains('arrendador');
          } else if (_categoriaSeleccionada == 'Servicios') {
            return c.otroUsuarioRol.toLowerCase().contains('servicio') ||
                c.otroUsuarioRol.toLowerCase().contains('especialista');
          }
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mensajes & Chats'),
            actions: [
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                tooltip: 'Cambiar Tema',
                onPressed: () => ThemeSelectorSheet.show(context),
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, size: 28),
                tooltip: 'Mi Perfil',
                onPressed: () => context.push('/perfil'),
              ),
            ],
          ),
          body: Column(
            children: [
              // Barra de búsqueda con estilo moderno
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

              // Filtros tipo Chip (Todos, Arrendadores, Servicios)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['Todos', 'Arrendadores', 'Servicios'].map((cat) {
                    final isSelected = _categoriaSeleccionada == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _categoriaSeleccionada = cat);
                        },
                        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
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

              // Lista de Conversaciones
              Expanded(
                child: filtradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 72,
                              color: theme.colorScheme.primary.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay conversaciones',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Inicia una charla desde el catálogo de propiedades o servicios.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filtradas.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final conv = filtradas[index];
                          return _ConversacionCard(
                            conversacion: conv,
                            onTap: () {
                              context.push('/chat-detail', extra: conv.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConversacionCard extends StatelessWidget {
  final Conversacion conversacion;
  final VoidCallback onTap;

  const _ConversacionCard({
    required this.conversacion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = conversacion.mensajesNoLeidos > 0;

    return Card(
      elevation: hasUnread ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: hasUnread
              ? theme.colorScheme.primary.withOpacity(0.5)
              : Colors.transparent,
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
              // Avatar con badge de status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: conversacion.otroUsuarioFoto != null
                        ? NetworkImage(conversacion.otroUsuarioFoto!)
                        : null,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: conversacion.otroUsuarioFoto == null
                        ? Text(
                            conversacion.otroUsuarioNombre.isNotEmpty
                                ? conversacion.otroUsuarioNombre[0]
                                : 'U',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.cardColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Contenido principal
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
                          _formatearHora(conversacion.fechaUltimoMensaje),
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodySmall?.color,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Rol / Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        conversacion.propiedadTitulo ?? conversacion.otroUsuarioRol,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Último mensaje
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversacion.ultimoMensaje,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
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

  String _formatearHora(DateTime fecha) {
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${fecha.day}/${fecha.month}';
    }
  }
}

