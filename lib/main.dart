import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/auth_provider.dart';
import 'features/rss/providers/rss_provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/github/providers/github_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase and notifications
  // await Firebase.initializeApp();
  // await NotificationService.init();
  
  runApp(const TracklyApp());
}

class TracklyApp extends StatelessWidget {
  const TracklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RssProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => GitHubProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'Trackly',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            locale: appProvider.locale,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return authProvider.isAuthenticated 
                    ? const HomeScreen() 
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
