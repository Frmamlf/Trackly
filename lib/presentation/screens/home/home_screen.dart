import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import '../../../core/providers/app_provider.dart';
import '../../../core/providers/auth_provider.dart';
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
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getScreenTitle(),
        onSearchPressed: () => _showSearch(context),
        onProfilePressed: () => _showProfile(context),
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
        return 'RSS Reader';
      case 1:
        return 'Product Tracker';
      case 2:
        return 'GitHub Tracker';
      case 3:
        return 'Notifications';
      case 4:
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

  void _showProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildProfileSheet(),
    );
  }

  Widget _buildProfileSheet() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: authProvider.currentUser?.photoUrl != null
                    ? NetworkImage(authProvider.currentUser!.photoUrl!)
                    : null,
                child: authProvider.currentUser?.photoUrl == null
                    ? Text(
                        authProvider.currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 24),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                authProvider.currentUser?.displayName ?? 'User',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                authProvider.currentUser?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('Profile'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      authProvider.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        // TODO: Implement RSS search results
        
        // Search in Products
        _buildSectionHeader('Products'),
        // TODO: Implement product search results
        
        // Search in GitHub repositories
        _buildSectionHeader('GitHub Repositories'),
        // TODO: Implement GitHub search results
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
