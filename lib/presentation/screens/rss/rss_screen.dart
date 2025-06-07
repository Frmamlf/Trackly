import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/rss/providers/rss_provider.dart';
import '../../../features/rss/models/rss_feed.dart';
import '../../widgets/rss_feed_card.dart';
import '../../widgets/rss_article_card.dart';
import '../../widgets/filter_chips.dart';

class RssScreen extends StatefulWidget {
  const RssScreen({super.key});

  @override
  State<RssScreen> createState() => _RssScreenState();
}

class _RssScreenState extends State<RssScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load RSS feeds on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RssProvider>(context, listen: false).loadFeeds();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RssProvider>(
      builder: (context, rssProvider, child) {
        return Column(
          children: [
            // Filter chips
            FilterChips(
              categories: rssProvider.categories,
              selectedCategory: rssProvider.selectedCategory,
              onCategorySelected: rssProvider.setSelectedCategory,
            ),
            
            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'All Articles', icon: Icon(Icons.article)),
                Tab(text: 'Feeds', icon: Icon(Icons.rss_feed)),
                Tab(text: 'Favorites', icon: Icon(Icons.favorite)),
              ],
            ),
            
            // Tab view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildArticlesTab(rssProvider),
                  _buildFeedsTab(rssProvider),
                  _buildFavoritesTab(rssProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticlesTab(RssProvider rssProvider) {
    if (rssProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rssProvider.articles.isEmpty) {
      return _buildEmptyState(
        icon: Icons.article,
        title: 'No Articles',
        subtitle: 'Add RSS feeds to start reading articles',
        action: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/add-rss'),
          icon: const Icon(Icons.add),
          label: const Text('Add RSS Feed'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: rssProvider.refreshAllFeeds,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rssProvider.filteredArticles.length,
        itemBuilder: (context, index) {
          final article = rssProvider.filteredArticles[index];
          return RssArticleCard(
            article: article,
            onTap: () => _openArticle(article),
            onFavoriteToggle: () => rssProvider.toggleArticleFavorite(article.id),
            onMarkAsRead: () => rssProvider.markAsRead(article.id),
          );
        },
      ),
    );
  }

  Widget _buildFeedsTab(RssProvider rssProvider) {
    if (rssProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rssProvider.feeds.isEmpty) {
      return _buildEmptyState(
        icon: Icons.rss_feed,
        title: 'No RSS Feeds',
        subtitle: 'Add your first RSS feed to get started',
        action: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/add-rss'),
          icon: const Icon(Icons.add),
          label: const Text('Add RSS Feed'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rssProvider.feeds.length,
      itemBuilder: (context, index) {
        final feed = rssProvider.feeds[index];
        return RssFeedCard(
          feed: feed,
          onTap: () => _openFeed(feed),
          onRefresh: () => rssProvider.refreshFeed(feed.id),
          onDelete: () => _deleteFeed(feed),
          onToggleActive: () => rssProvider.toggleFeedActive(feed.id),
        );
      },
    );
  }

  Widget _buildFavoritesTab(RssProvider rssProvider) {
    final favoriteArticles = rssProvider.favoriteArticles;

    if (favoriteArticles.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite,
        title: 'No Favorites',
        subtitle: 'Mark articles as favorites to see them here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteArticles.length,
      itemBuilder: (context, index) {
        final article = favoriteArticles[index];
        return RssArticleCard(
          article: article,
          onTap: () => _openArticle(article),
          onFavoriteToggle: () => rssProvider.toggleArticleFavorite(article.id),
          onMarkAsRead: () => rssProvider.markAsRead(article.id),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  void _openArticle(RssArticle article) {
    Navigator.pushNamed(
      context,
      '/article',
      arguments: article,
    );
  }

  void _openFeed(RssFeed feed) {
    Navigator.pushNamed(
      context,
      '/feed',
      arguments: feed,
    );
  }

  void _deleteFeed(RssFeed feed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feed'),
        content: Text('Are you sure you want to delete "${feed.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<RssProvider>(context, listen: false)
                  .deleteFeed(feed.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
