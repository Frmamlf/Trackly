import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Material 3 Expressive - Vibrant and Nuanced Color Palette
  // Rich, emotive colors that create visual energy and guide attention
  static const Color _primarySeed = Color(0xFF6200EA); // Deep Purple - more vibrant
  static const Color _secondarySeed = Color(0xFF03DAC6); // Teal - high contrast
  static const Color _tertiarySeed = Color(0xFFFF6B35); // Orange - energetic accent
  
  // Expressive surface colors for dynamic containers
  static const Color _surfaceVariant = Color(0xFFF3E5F5);
  static const Color _surfaceTint = Color(0xFFE1BEE7);
  
  // Success, Warning, Error colors - more expressive
  static const Color _successColor = Color(0xFF00C853); // Vibrant green
  static const Color _warningColor = Color(0xFFFF9800); // Bold orange
  static const Color _errorColor = Color(0xFFE91E63); // Pink-red for softer impact

  // Light Theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme, false),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.rubik(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Material 3 Expressive Card Theme - Dynamic shapes and elevation
      cardTheme: CardThemeData(
        elevation: 3, // Slightly higher for better hierarchy
        shadowColor: colorScheme.primary.withOpacity(0.1),
        surfaceTintColor: colorScheme.primaryContainer.withOpacity(0.3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(largeRadius), // Larger radius for modern look
        ),
      ),

      // Material 3 Expressive Button Themes - Varied shapes and bold styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4, // Higher elevation for prominence
          shadowColor: colorScheme.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(largeRadius), // Use large radius for primary actions
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w700, // Bolder text
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          side: BorderSide(color: colorScheme.primary, width: 2), // Thicker border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(mediumRadius), // Medium radius for secondary actions
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Filled buttons with unique shape
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(extraLargeRadius), // Pill shape for uniqueness
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Material 3 Expressive Input Decoration - Varied shapes for different contexts
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        
        // Default state - medium radius
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.5), // Thicker focused border
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        
        // Enhanced typography
        labelStyle: GoogleFonts.rubik(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.rubik(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        floatingLabelStyle: GoogleFonts.rubik(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: GoogleFonts.rubik(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.rubik(fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),

      // Material 3 Expressive FloatingActionButton - Bold and prominent
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 6,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(extraLargeRadius), // Large radius for uniqueness
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: 64,
          height: 64,
        ),
        extendedSizeConstraints: const BoxConstraints.tightFor(
          height: 56,
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        splashColor: colorScheme.primaryContainer,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.rubik(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: GoogleFonts.rubik(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: GoogleFonts.rubik(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme, true),
      
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.rubik(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: GoogleFonts.rubik(),
        hintStyle: GoogleFonts.rubik(color: colorScheme.onSurfaceVariant),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: GoogleFonts.rubik(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.rubik(fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),

      // Material 3 Expressive FloatingActionButton - Bold and prominent
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 6,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(extraLargeRadius), // Large radius for uniqueness
        ),
        sizeConstraints: const BoxConstraints.tightFor(
          width: 64,
          height: 64,
        ),
        extendedSizeConstraints: const BoxConstraints.tightFor(
          height: 56,
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        splashColor: colorScheme.primaryContainer,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),

      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.rubik(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: GoogleFonts.rubik(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: GoogleFonts.rubik(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Material 3 Expressive Typography - Emphasized styles with heavier weights
  static TextTheme _buildTextTheme(ColorScheme colorScheme, bool isDark) {
    return TextTheme(
      // Display styles - Extra bold for maximum impact
      displayLarge: GoogleFonts.rubik(
        fontSize: 64, // Larger for more presence
        fontWeight: FontWeight.w800, // Extra bold
        color: colorScheme.primary, // Use primary color for emphasis
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.rubik(
        fontSize: 48,
        fontWeight: FontWeight.w700, // Bold
        color: colorScheme.primary,
        letterSpacing: -1.0,
      ),
      displaySmall: GoogleFonts.rubik(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      
      // Headlines - Strong hierarchy with varied weights
      headlineLarge: GoogleFonts.rubik(
        fontSize: 36,
        fontWeight: FontWeight.w800, // Extra bold for editorial moments
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.rubik(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.rubik(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      
      // Titles - Medium emphasis
      titleLarge: GoogleFonts.rubik(
        fontSize: 24,
        fontWeight: FontWeight.w700, // Bolder than standard
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.rubik(
        fontSize: 18,
        fontWeight: FontWeight.w600, // Semi-bold
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.rubik(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.1,
      ),
      
      // Body text - Clear hierarchy with good readability
      bodyLarge: GoogleFonts.rubik(
        fontSize: 18, // Slightly larger for better readability
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.rubik(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.rubik(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      
      // Labels - Stronger emphasis for UI elements
      labelLarge: GoogleFonts.rubik(
        fontSize: 16,
        fontWeight: FontWeight.w600, // Bolder for buttons and actions
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.rubik(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.rubik(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
    );
  }

  // Material 3 Expressive Shape System - Variety of corner radii for visual interest
  static const double extraSmallRadius = 4.0;   // Minimal rounding
  static const double smallRadius = 8.0;        // Standard small components  
  static const double mediumRadius = 16.0;      // Cards and containers
  static const double largeRadius = 24.0;       // Prominent surfaces
  static const double extraLargeRadius = 32.0;  // Hero elements

  // Custom colors for specific features with expressive palette
  static const Color successColor = _successColor;
  static const Color warningColor = _warningColor;
  static const Color errorColor = _errorColor;

  // Extension colors for RSS categories
  static const List<Color> rssColors = [
    Color(0xFF1976D2), // Blue
    Color(0xFF388E3C), // Green
    Color(0xFFF57C00), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFFD32F2F), // Red
    Color(0xFF00796B), // Teal
    Color(0xFF455A64), // Blue Grey
    Color(0xFF5D4037), // Brown
  ];

  // Extension colors for product categories
  static const List<Color> productColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
  ];

  // Material 3 Expressive Motion System - Fluid animations and spring physics
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
  static const Duration extraLongDuration = Duration(milliseconds: 700);
  
  // Spring animation curves for expressive motion
  static const Curve expressiveEaseOut = Curves.easeOutCubic;
  static const Curve expressiveEaseIn = Curves.easeInCubic;
  static const Curve expressiveSpring = Curves.elasticOut;
  static const Curve expressiveBounce = Curves.bounceOut;

  // Page transition curves for fluid navigation
  static const Curve pageTransitionCurve = Curves.easeOutQuart;

  // Material 3 Expressive Page Transitions - Fluid and dynamic navigation
  static PageRouteBuilder createExpressiveRoute<T>({
    required Widget page,
    RouteSettings? settings,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration ?? mediumDuration,
      reverseTransitionDuration: duration ?? mediumDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Expressive slide and fade transition
        const begin = Offset(0.0, 0.05); // Subtle slide from bottom
        const end = Offset.zero;
        final slideAnimation = Tween(begin: begin, end: end)
            .animate(CurvedAnimation(parent: animation, curve: expressiveEaseOut));
        
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: animation, curve: expressiveEaseOut));
        
        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0)
            .animate(CurvedAnimation(parent: animation, curve: expressiveSpring));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  // Helper method for creating expressive dialog transitions
  static Widget createExpressiveDialog({
    required Widget child,
    required AnimationController controller,
  }) {
    final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: expressiveSpring));
    
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: expressiveEaseOut));

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  // Material 3 Expressive Layout System - Structured containment with flexibility
  static const EdgeInsets compactPadding = EdgeInsets.all(8.0);
  static const EdgeInsets mediumPadding = EdgeInsets.all(16.0);
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);
  static const EdgeInsets extraLargePadding = EdgeInsets.all(32.0);
  
  // Responsive margin system
  static const EdgeInsets compactMargin = EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
  static const EdgeInsets mediumMargin = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const EdgeInsets largeMargin = EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
  
  // Container decoration for expressive surfaces
  static BoxDecoration createExpressiveContainer({
    required ColorScheme colorScheme,
    double borderRadius = 16.0,
    bool elevated = false,
    Color? customColor,
  }) {
    return BoxDecoration(
      color: customColor ?? 
            (elevated ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainer),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: elevated ? [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ] : null,
      border: Border.all(
        color: colorScheme.outline.withOpacity(0.12),
        width: 1,
      ),
    );
  }
  
  // Expressive gradient backgrounds for hero sections
  static LinearGradient createExpressiveGradient(ColorScheme colorScheme) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.primaryContainer.withOpacity(0.3),
        colorScheme.secondaryContainer.withOpacity(0.2),
        colorScheme.tertiaryContainer.withOpacity(0.1),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }
}
