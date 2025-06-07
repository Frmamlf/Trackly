import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onProfilePressed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSearchPressed,
    this.onProfilePressed,
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
            IconButton(
              onPressed: () => _toggleTheme(context),
              icon: Icon(
                appProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              tooltip: 'Toggle Theme',
            ),
            IconButton(
              onPressed: () => _toggleLanguage(context),
              icon: const Icon(Icons.language),
              tooltip: 'Toggle Language',
            ),
            if (onProfilePressed != null)
              IconButton(
                onPressed: onProfilePressed,
                icon: const Icon(Icons.account_circle),
                tooltip: 'Profile',
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
