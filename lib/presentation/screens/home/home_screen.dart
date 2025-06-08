import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import '../../../core/providers/app_provider.dart';
import '../../../features/rss/providers/rss_provider.dart';
import '../../../features/products/providers/product_provider.dart';
import '../../../features/github/providers/github_provider.dart';
import '../rss/rss_screen.dart';
import '../rss/add_rss_feed_screen.dart';
import '../products/products_screen.dart';
import '../products/add_product_screen.dart';
import '../github/github_screen.dart';
import '../github/add_github_repo_screen.dart';
// ignore: unused_import
import '../notifications/notifications_screen.dart';
// ignore: unused_import
import '../settings/settings_screen.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const RssScreen(),
    const ProductsScreen(),
    const GitHubScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getScreenTitle(),
        onSearchPressed: () => _showSearch(context),
        onNotificationPressed: () => _showNotifications(context),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return 'News Reader';
      case 1:
        return 'Product Tracker';
      case 2:
        return 'GitHub Tracker';
      case 3:
        return 'Settings';
      default:
        return 'Trackly';
    }
  }

  Widget? _buildFAB() {
    switch (_currentIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () => _addRssFeed(),
          child: const Icon(Icons.rss_feed),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () => _addProduct(),
          child: const Icon(Icons.add_shopping_cart),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => _addRepository(),
          child: const Icon(Icons.code),
        );
      default:
        return null;
    }
  }

  void _addRssFeed() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddRssFeedScreen(),
      ),
    );
    
    if (result == true) {
      // Refresh the RSS screen if needed
    }
  }

  void _addProduct() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
    
    if (result == true) {
      // Refresh the products screen if needed
    }
  }

  void _addRepository() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddGitHubRepoScreen(),
      ),
    );
    
    if (result == true) {
      // Refresh the GitHub screen if needed
    }
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: UniversalSearchDelegate(),
    );
  }

  void _showNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }
}

/// A screen to display notifications in the application.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('No notifications available')),
    );
  }
}

/// A screen for managing application settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}

class UniversalSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter search term'),
      );
    }

    return ListView(
      children: [
        // Search in RSS feeds
        _buildSectionHeader('RSS Articles'),
        Consumer<RssProvider>(
          builder: (context, rssProvider, child) {
            final feeds = rssProvider.feeds
                .where((feed) => feed.title.toLowerCase().contains(query.toLowerCase()) ||
                               (feed.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
                .toList();
            
            if (feeds.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No RSS feeds found'),
              );
            }
            
            return Column(
              children: feeds.map((feed) => ListTile(
                title: Text(feed.title),
                subtitle: Text(feed.description ?? ''),
                leading: const Icon(Icons.rss_feed),
                onTap: () {
                  close(context, null);
                  // Navigate to RSS detail
                },
              )).toList(),
            );
          },
        ),
        
        // Search in Products
        _buildSectionHeader('Products'),
        Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final products = productProvider.products
                .where((product) => product.name.toLowerCase().contains(query.toLowerCase()) ||
                                  (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
                .toList();
            
            if (products.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No products found'),
              );
            }
            
            return Column(
              children: products.map((product) => ListTile(
                title: Text(product.name),
                subtitle: Text(product.description ?? ''),
                leading: const Icon(Icons.shopping_cart),
                trailing: Text('\$${product.currentPrice.toStringAsFixed(2)}'),
                onTap: () {
                  close(context, null);
                  // Navigate to product detail
                },
              )).toList(),
            );
          },
        ),
        
        // Search in GitHub repositories
        _buildSectionHeader('GitHub Repositories'),
        Consumer<GitHubProvider>(
          builder: (context, githubProvider, child) {
            final repos = githubProvider.repositories
                .where((repo) => repo.name.toLowerCase().contains(query.toLowerCase()) ||
                               (repo.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
                .toList();
            
            if (repos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No repositories found'),
              );
            }
            
            return Column(
              children: repos.map((repo) => ListTile(
                title: Text(repo.name),
                subtitle: Text(repo.description ?? ''),
                leading: const Icon(Icons.code),
                trailing: Text('⭐ ${repo.stargazersCount}'),
                onTap: () {
                  close(context, null);
                  // Navigate to repo detail
                },
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
