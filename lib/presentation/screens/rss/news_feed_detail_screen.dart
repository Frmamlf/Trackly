import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/rss/models/rss_feed.dart';
import '../../../features/rss/providers/rss_provider.dart';
import '../../widgets/rss_article_card.dart';
import 'news_article_detail_screen.dart';
import 'add_rss_feed_screen.dart';

class NewsFeedDetailScreen extends StatefulWidget {
  final RssFeed feed;

  const NewsFeedDetailScreen({
    super.key,
    required this.feed,
  });

  @override
  State<NewsFeedDetailScreen> createState() => _NewsFeedDetailScreenState();
}

class _NewsFeedDetailScreenState extends State<NewsFeedDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh feed when opening detail screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RssProvider>(context, listen: false)
          .refreshFeed(widget.feed.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.feed.title),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _refreshFeed(),
                child: const Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => _editFeed(),
                child: const Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => _toggleFeedActive(),
                child: Row(
                  children: [
                    Icon(widget.feed.isActive ? Icons.pause : Icons.play_arrow),
                    const SizedBox(width: 8),
                    Text(widget.feed.isActive ? 'Pause' : 'Resume'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => _deleteFeed(),
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
        ],
      ),
      body: Consumer<RssProvider>(
        builder: (context, rssProvider, child) {
          final feedArticles = rssProvider.articles
              .where((article) => article.feedId == widget.feed.id)
              .toList();

          return Column(
            children: [
              // Feed info header
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: widget.feed.imageUrl != null 
                                ? NetworkImage(widget.feed.imageUrl!) 
                                : null,
                            child: widget.feed.imageUrl == null 
                                ? const Icon(Icons.rss_feed)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.feed.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.feed.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.feed.description!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Chip(
                            label: Text(widget.feed.category),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          if (widget.feed.unreadCount > 0)
                            Chip(
                              label: Text('${widget.feed.unreadCount} unread'),
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.feed.isActive 
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.feed.isActive ? Icons.radio_button_checked : Icons.pause_circle,
                                  size: 16,
                                  color: widget.feed.isActive ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.feed.isActive ? 'Active' : 'Paused',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.feed.isActive ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last updated: ${_formatDate(widget.feed.lastUpdated)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Articles list
              Expanded(
                child: feedArticles.isEmpty
                    ? _buildEmptyState(rssProvider.isLoading)
                    : RefreshIndicator(
                        onRefresh: () => _refreshFeed(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: feedArticles.length,
                          itemBuilder: (context, index) {
                            final article = feedArticles[index];
                            return RssArticleCard(
                              article: article,
                              onTap: () => _openArticle(article),
                              onFavoriteToggle: () => rssProvider.toggleArticleFavorite(article.id),
                              onMarkAsRead: () => rssProvider.markAsRead(article.id),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Articles Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.feed.isActive
                  ? 'This feed hasn\'t published any articles yet. Pull down to refresh.'
                  : 'This feed is paused. Enable it to start receiving articles.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!widget.feed.isActive)
              FilledButton.icon(
                onPressed: _toggleFeedActive,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resume Feed'),
              )
            else
              OutlinedButton.icon(
                onPressed: _refreshFeed,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
          ],
        ),
      ),
    );
  }

  void _openArticle(RssArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsArticleDetailScreen(article: article),
      ),
    );
  }

  Future<void> _refreshFeed() async {
    await Provider.of<RssProvider>(context, listen: false)
        .refreshFeed(widget.feed.id);
  }

  void _editFeed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRssFeedScreen(existingFeed: widget.feed),
      ),
    );
  }

  void _toggleFeedActive() {
    Provider.of<RssProvider>(context, listen: false)
        .toggleFeedActive(widget.feed.id);
  }

  void _deleteFeed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete News Feed'),
        content: Text('Are you sure you want to delete "${widget.feed.title}"? This will also remove all its articles.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<RssProvider>(context, listen: false)
                  .deleteFeed(widget.feed.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to feeds list
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
