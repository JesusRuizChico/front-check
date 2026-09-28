import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/chat_service.dart';
import '../widgets/chat_avatar.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late Future<List<ConversationSummary>> _conversations;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _conversations = chatService.listConversations();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _conversations;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -70,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: .18),
                ),
              ),
            ),
          ),
          FutureBuilder<List<ConversationSummary>>(
            future: _conversations,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _MessageState(
                  icon: Icons.wifi_off_rounded,
                  title: 'No se pudieron cargar tus conversaciones',
                  action: TextButton(
                    onPressed: () => setState(_load),
                    child: const Text('Volver a intentar'),
                  ),
                );
              }

              final conversations = snapshot.data ?? const [];
              if (conversations.isEmpty) {
                return const _MessageState(
                  icon: Icons.forum_outlined,
                  title: 'Aún no tienes conversaciones',
                  subtitle: 'Cuando tengas una conversación, aparecerá aquí.',
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _ConversationTile(conversation: conversation);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationSummary conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push(
          '/mensajes/${conversation.id}',
          extra: conversation,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.onSurfaceVariant),
          ),
          child: Row(
            children: [
              ChatAvatar(
                name: conversation.otherParticipant.name,
                photoUrl: conversation.otherParticipant.photoUrl,
                radius: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherParticipant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(conversation.lastActivity),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      conversation.lastMessage?.content ??
                          'Inicia la conversación',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: conversation.unreadCount > 0
                            ? theme.colorScheme.onSurface
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (conversation.slowReplyWarning) ...[
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 14, color: AppColors.accentLight),
                          const SizedBox(width: 5),
                          Text(
                            'El arrendador podría tardar en responder',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.accentLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (conversation.unreadCount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  constraints: const BoxConstraints(minWidth: 23),
                  height: 23,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    conversation.unreadCount > 99
                        ? '99+'
                        : conversation.unreadCount.toString(),
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
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (now.difference(date).inDays < 7) {
      const days = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
      return days[date.weekday - 1];
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const _MessageState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: theme.colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 12),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
