import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  // Theme
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // Language
  Locale _locale = const Locale('ar', 'SA');
  Locale get locale => _locale;

  // Security & Privacy
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _dataCollectionEnabled = true;
  
  bool get biometricEnabled => _biometricEnabled;
  bool get twoFactorEnabled => _twoFactorEnabled;
  bool get dataCollectionEnabled => _dataCollectionEnabled;

  // Notifications
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _telegramNotifications = false;
  bool _whatsappNotifications = false;
  bool _slackNotifications = false;

  bool get emailNotifications => _emailNotifications;
  bool get pushNotifications => _pushNotifications;
  bool get telegramNotifications => _telegramNotifications;
  bool get whatsappNotifications => _whatsappNotifications;
  bool get slackNotifications => _slackNotifications;

  // Sound settings
  String _notificationSound = 'default';
  String get notificationSound => _notificationSound;

  // Cloud storage
  bool _googleDriveSync = false;
  bool _dropboxSync = false;
  
  bool get googleDriveSync => _googleDriveSync;
  bool get dropboxSync => _dropboxSync;

  // UI Customization
  double _fontSize = 14.0;
  String _accentColor = 'purple';
  bool _compactMode = false;

  double get fontSize => _fontSize;
  String get accentColor => _accentColor;
  bool get compactMode => _compactMode;

  AppProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    // Language
    final languageCode = prefs.getString('language') ?? 'ar';
    _locale = Locale(languageCode, languageCode == 'ar' ? 'SA' : 'US');
    
    // Security
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    _twoFactorEnabled = prefs.getBool('two_factor_enabled') ?? false;
    _dataCollectionEnabled = prefs.getBool('data_collection_enabled') ?? true;
    
    // Notifications
    _emailNotifications = prefs.getBool('email_notifications') ?? true;
    _pushNotifications = prefs.getBool('push_notifications') ?? true;
    _telegramNotifications = prefs.getBool('telegram_notifications') ?? false;
    _whatsappNotifications = prefs.getBool('whatsapp_notifications') ?? false;
    _slackNotifications = prefs.getBool('slack_notifications') ?? false;
    
    // Sound
    _notificationSound = prefs.getString('notification_sound') ?? 'default';
    
    // Cloud storage
    _googleDriveSync = prefs.getBool('google_drive_sync') ?? false;
    _dropboxSync = prefs.getBool('dropbox_sync') ?? false;
    
    // UI
    _fontSize = prefs.getDouble('font_size') ?? 14.0;
    _accentColor = prefs.getString('accent_color') ?? 'purple';
    _compactMode = prefs.getBool('compact_mode') ?? false;
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
    notifyListeners();
  }

  Future<void> setTwoFactorEnabled(bool enabled) async {
    _twoFactorEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('two_factor_enabled', enabled);
    notifyListeners();
  }

  Future<void> setDataCollectionEnabled(bool enabled) async {
    _dataCollectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('data_collection_enabled', enabled);
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool enabled) async {
    _emailNotifications = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', enabled);
    notifyListeners();
  }

  Future<void> setPushNotifications(bool enabled) async {
    _pushNotifications = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', enabled);
    notifyListeners();
  }

  Future<void> setTelegramNotifications(bool enabled) async {
    _telegramNotifications = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('telegram_notifications', enabled);
    notifyListeners();
  }

  Future<void> setWhatsappNotifications(bool enabled) async {
    _whatsappNotifications = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('whatsapp_notifications', enabled);
    notifyListeners();
  }

  Future<void> setSlackNotifications(bool enabled) async {
    _slackNotifications = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('slack_notifications', enabled);
    notifyListeners();
  }

  Future<void> setNotificationSound(String sound) async {
    _notificationSound = sound;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_sound', sound);
    notifyListeners();
  }

  Future<void> setGoogleDriveSync(bool enabled) async {
    _googleDriveSync = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('google_drive_sync', enabled);
    notifyListeners();
  }

  Future<void> setDropboxSync(bool enabled) async {
    _dropboxSync = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dropbox_sync', enabled);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', size);
    notifyListeners();
  }

  Future<void> setAccentColor(String color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accent_color', color);
    notifyListeners();
  }

  Future<void> setCompactMode(bool enabled) async {
    _compactMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('compact_mode', enabled);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadSettings();
  }

  Map<String, dynamic> exportSettings() {
    return {
      'theme_mode': _themeMode.index,
      'language': _locale.languageCode,
      'biometric_enabled': _biometricEnabled,
      'two_factor_enabled': _twoFactorEnabled,
      'data_collection_enabled': _dataCollectionEnabled,
      'email_notifications': _emailNotifications,
      'push_notifications': _pushNotifications,
      'telegram_notifications': _telegramNotifications,
      'whatsapp_notifications': _whatsappNotifications,
      'slack_notifications': _slackNotifications,
      'notification_sound': _notificationSound,
      'google_drive_sync': _googleDriveSync,
      'dropbox_sync': _dropboxSync,
      'font_size': _fontSize,
      'accent_color': _accentColor,
      'compact_mode': _compactMode,
    };
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    for (String key in settings.keys) {
      final value = settings[key];
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    }
    
    await _loadSettings();
  }

  void toggleTheme() {}

  void toggleLanguage() {}
}
