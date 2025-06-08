import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
          actions: [
            if (onSearchPressed != null)
              IconButton(
                onPressed: onSearchPressed,
                icon: const Icon(Icons.search),
                tooltip: 'Search',
              ),
            if (onNotificationPressed != null)
              IconButton(
                onPressed: onNotificationPressed,
                icon: const Icon(Icons.notifications),
                tooltip: 'Notifications',
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'theme':
                    _toggleTheme(context);
                    break;
                  case 'language':
                    _toggleLanguage(context);
                    break;
                  case 'profile':
                    _showProfile(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: const [
                      Icon(Icons.account_circle),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'theme',
                  child: Row(
                    children: [
                      Icon(
                        appProvider.themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      const SizedBox(width: 8),
                      Text(appProvider.themeMode == ThemeMode.dark
                          ? 'Light Mode'
                          : 'Dark Mode'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'language',
                  child: Row(
                    children: const [
                      Icon(Icons.language),
                      SizedBox(width: 8),
                      Text('Language'),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
            if (actions != null) ...actions!,
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  void _toggleTheme(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.toggleTheme();
  }

  void _toggleLanguage(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.toggleLanguage();
  }

  void _showProfile(BuildContext context) {
    // This will be handled by the parent widget
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: const Text('Profile settings coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
