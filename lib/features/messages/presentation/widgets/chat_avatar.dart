import 'package:flutter/material.dart';

class ChatAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;

  const ChatAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: .16),
      foregroundImage: url == null || url.isEmpty ? null : NetworkImage(url),
      onForegroundImageError: url == null || url.isEmpty ? null : (_, __) {},
      child: Text(
        name.trim().isEmpty ? '?' : name.trim().substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: radius * .78,
        ),
      ),
    );
  }
}
