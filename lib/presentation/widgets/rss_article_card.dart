import 'package:flutter/material.dart';
import '../../features/rss/models/rss_feed.dart';

class RssArticleCard extends StatelessWidget {
  final RssArticle article;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onMarkAsRead;

  const RssArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with read status and favorite
              Row(
                children: [
                  if (!article.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (!article.isRead) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(article.publishedDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      article.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: article.isFavorite ? Colors.red : null,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Article content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: article.isRead ? FontWeight.normal : FontWeight.w600,
                            color: article.isRead 
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        if (article.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            article.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        if (article.author != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'By ${article.author}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Article image
                  if (article.imageUrl != null) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        article.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
              
              // Categories and actions
              if (article.categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  children: article.categories.take(3).map((category) {
                    return Chip(
                      label: Text(
                        category,
                        style: const TextStyle(fontSize: 10),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
              
              // Action buttons
              const SizedBox(height: 8),
              Row(
                children: [
                  const Spacer(),
                  if (!article.isRead)
                    TextButton.icon(
                      onPressed: onMarkAsRead,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark as Read'),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      // Share functionality
                    },
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
