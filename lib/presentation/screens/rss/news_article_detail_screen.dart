import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../features/rss/models/rss_feed.dart';
import '../../../features/rss/providers/rss_provider.dart';

class NewsArticleDetailScreen extends StatefulWidget {
  final RssArticle article;

  const NewsArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<NewsArticleDetailScreen> createState() => _NewsArticleDetailScreenState();
}

class _NewsArticleDetailScreenState extends State<NewsArticleDetailScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    
    // Mark article as read when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.article.isRead) {
        Provider.of<RssProvider>(context, listen: false)
            .markAsRead(widget.article.id);
      }
    });
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onHttpError: (HttpResponseError error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.article.link));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _toggleFavorite(),
                child: Row(
                  children: [
                    Icon(
                      widget.article.isFavorite 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                      color: widget.article.isFavorite ? Colors.red : null,
                    ),
                    const SizedBox(width: 8),
                    Text(widget.article.isFavorite 
                        ? 'Remove from Favorites' 
                        : 'Add to Favorites'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => _toggleBookmark(),
                child: Row(
                  children: [
                    Icon(
                      widget.article.isBookmarked 
                          ? Icons.bookmark 
                          : Icons.bookmark_border,
                    ),
                    const SizedBox(width: 8),
                    Text(widget.article.isBookmarked 
                        ? 'Remove Bookmark' 
                        : 'Bookmark'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => _shareArticle(),
                child: const Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => _openInBrowser(),
                child: const Row(
                  children: [
                    Icon(Icons.open_in_browser),
                    SizedBox(width: 8),
                    Text('Open in Browser'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Article info header
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.article.author != null) ...[
                    Text(
                      'By ${widget.article.author}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    _formatDate(widget.article.publishedDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (widget.article.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.article.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (widget.article.categories.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: widget.article.categories.map((category) {
                        return Chip(
                          label: Text(category),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // WebView content
          Expanded(
            child: _hasError
                ? _buildErrorView()
                : Stack(
                    children: [
                      WebViewWidget(controller: _controller),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load article',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'There was an error loading the article content.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                    });
                    _initializeWebView();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _openInBrowser,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in Browser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite() {
    Provider.of<RssProvider>(context, listen: false)
        .toggleArticleFavorite(widget.article.id);
  }

  void _toggleBookmark() {
    Provider.of<RssProvider>(context, listen: false)
        .toggleArticleBookmark(widget.article.id);
  }

  void _shareArticle() {
    // Implement share functionality
    // You might want to use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
      ),
    );
  }

  void _openInBrowser() async {
    final url = Uri.parse(widget.article.link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open article in browser'),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
