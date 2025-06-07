import 'package:flutter/material.dart';
import '../../features/rss/models/rss_feed.dart';

class RssFeedCard extends StatelessWidget {
  final RssFeed feed;
  final VoidCallback onTap;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const RssFeedCard({
    super.key,
    required this.feed,
    required this.onTap,
    required this.onRefresh,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage: feed.imageUrl != null 
              ? NetworkImage(feed.imageUrl!) 
              : null,
          child: feed.imageUrl == null 
              ? const Icon(Icons.rss_feed)
              : null,
        ),
        title: Text(
          feed.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: feed.isActive 
                ? null 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feed.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                feed.description ?? '',
                style: feed.isActive
                  ? null
                  : TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    feed.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                if (feed.unreadCount > 0)
                  Chip(
                    label: Text(
                      '${feed.unreadCount} unread',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                const Spacer(),
                Text(
                  _formatDate(feed.lastUpdated),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onRefresh,
              child: const Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onToggleActive,
              child: Row(
                children: [
                  Icon(feed.isActive ? Icons.pause : Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(feed.isActive ? 'Pause' : 'Resume'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: const Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
