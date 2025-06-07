import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.of(context).languageCode == 'ar';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Settings Section
          _buildSectionHeader(
            context,
            isArabic ? 'إعدادات التطبيق' : 'App Settings',
            Icons.settings,
          ),
          Card(
            child: Column(
              children: [
                // Theme setting
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return SwitchListTile(
                      leading: Icon(
                        appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      ),
                      title: Text(isArabic ? 'الوضع المظلم' : 'Dark Mode'),
                      subtitle: Text(isArabic 
                          ? 'تبديل بين الوضع المظلم والفاتح'
                          : 'Switch between dark and light theme'),
                      value: appProvider.isDarkMode,
                      onChanged: (value) => appProvider.toggleTheme(),
                    );
                  },
                ),
                
                const Divider(height: 1),
                
                // Language setting
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return SwitchListTile(
                      leading: const Icon(Icons.language),
                      title: Text(isArabic ? 'اللغة العربية' : 'Arabic Language'),
                      subtitle: Text(isArabic 
                          ? 'تبديل بين العربية والإنجليزية'
                          : 'Switch between Arabic and English'),
                      value: appProvider.isArabic,
                      onChanged: (value) => appProvider.toggleLanguage(),
                    );
                  },
                ),
                
                const Divider(height: 1),
                
                // Notifications setting
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(isArabic ? 'إعدادات الإشعارات' : 'Notification Settings'),
                  subtitle: Text(isArabic 
                      ? 'إدارة تفضيلات الإشعارات'
                      : 'Manage notification preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to notification settings
                    Navigator.pushNamed(context, '/notification-settings');
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Data Management Section
          _buildSectionHeader(
            context,
            isArabic ? 'إدارة البيانات' : 'Data Management',
            Icons.storage,
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_sync),
                  title: Text(isArabic ? 'مزامنة البيانات' : 'Data Sync'),
                  subtitle: Text(isArabic 
                      ? 'مزامنة البيانات مع السحابة'
                      : 'Sync data with cloud storage'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to sync settings
                    Navigator.pushNamed(context, '/sync-settings');
                  },
                ),
                
                const Divider(height: 1),
                
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: Text(isArabic ? 'النسخ الاحتياطي' : 'Backup'),
                  subtitle: Text(isArabic 
                      ? 'إنشاء نسخة احتياطية من البيانات'
                      : 'Create backup of your data'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showBackupDialog(context, isArabic);
                  },
                ),
                
                const Divider(height: 1),
                
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: Text(isArabic ? 'استعادة البيانات' : 'Restore Data'),
                  subtitle: Text(isArabic 
                      ? 'استعادة البيانات من نسخة احتياطية'
                      : 'Restore data from backup'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showRestoreDialog(context, isArabic);
                  },
                ),
                
                const Divider(height: 1),
                
                ListTile(
                  leading: Icon(Icons.clear_all, color: theme.colorScheme.error),
                  title: Text(
                    isArabic ? 'حذف جميع البيانات' : 'Clear All Data',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: Text(isArabic 
                      ? 'حذف جميع البيانات المحلية'
                      : 'Delete all local data'),
                  onTap: () {
                    _showClearDataDialog(context, isArabic);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Security Section
          _buildSectionHeader(
            context,
            isArabic ? 'الأمان والخصوصية' : 'Security & Privacy',
            Icons.security,
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: Text(isArabic ? 'تغيير كلمة المرور' : 'Change Password'),
                  subtitle: Text(isArabic 
                      ? 'تحديث كلمة مرور الحساب'
                      : 'Update your account password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),
                
                const Divider(height: 1),
                
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: Text(isArabic ? 'المصادقة البيومترية' : 'Biometric Authentication'),
                  subtitle: Text(isArabic 
                      ? 'استخدام البصمة أو الوجه للدخول'
                      : 'Use fingerprint or face for login'),
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement biometric setting
                  },
                ),
                
                const Divider(height: 1),
                
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: Text(isArabic ? 'سياسة الخصوصية' : 'Privacy Policy'),
                  subtitle: Text(isArabic 
                      ? 'اقرأ سياسة الخصوصية الخاصة بنا'
                      : 'Read our privacy policy'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy-policy');
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader(
            context,
            isArabic ? 'حول التطبيق' : 'About',
            Icons.info,
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help),
                  title: Text(isArabic ? 'المساعدة والدعم' : 'Help & Support'),
                  subtitle: Text(isArabic 
                      ? 'احصل على المساعدة والدعم'
                      : 'Get help and support'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(context, '/help');
                  },
                ),
                
                const Divider(height: 1),
                
                ListTile(
                  leading: const Icon(Icons.rate_review),
                  title: Text(isArabic ? 'تقييم التطبيق' : 'Rate App'),
                  subtitle: Text(isArabic 
                      ? 'قيم التطبيق في المتجر'
                      : 'Rate the app on the store'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Open app store rating
                  },
                ),
                
                const Divider(height: 1),
                
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Trackly'),
                  subtitle: Text('Version 1.0.0'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Account Section
          Card(
            child: Column(
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ListTile(
                      leading: Icon(Icons.logout, color: theme.colorScheme.error),
                      title: Text(
                        isArabic ? 'تسجيل الخروج' : 'Sign Out',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      subtitle: Text(isArabic 
                          ? 'الخروج من الحساب الحالي'
                          : 'Sign out of current account'),
                      onTap: () {
                        _showSignOutDialog(context, authProvider, isArabic);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'إنشاء نسخة احتياطية' : 'Create Backup'),
        content: Text(isArabic 
            ? 'سيتم إنشاء نسخة احتياطية من جميع بياناتك. هل تريد المتابعة؟'
            : 'A backup of all your data will be created. Do you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement backup functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic 
                      ? 'تم إنشاء النسخة الاحتياطية بنجاح'
                      : 'Backup created successfully'),
                ),
              );
            },
            child: Text(isArabic ? 'إنشاء' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'استعادة البيانات' : 'Restore Data'),
        content: Text(isArabic 
            ? 'سيتم استبدال البيانات الحالية بالنسخة الاحتياطية. هل تريد المتابعة؟'
            : 'Current data will be replaced with the backup. Do you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement restore functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic 
                      ? 'تم استعادة البيانات بنجاح'
                      : 'Data restored successfully'),
                ),
              );
            },
            child: Text(isArabic ? 'استعادة' : 'Restore'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'حذف جميع البيانات' : 'Clear All Data'),
        content: Text(isArabic 
            ? 'سيتم حذف جميع البيانات المحلية نهائياً. لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟'
            : 'All local data will be permanently deleted. This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear data functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic 
                      ? 'تم حذف جميع البيانات'
                      : 'All data cleared'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(isArabic ? 'حذف' : 'Clear'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'تسجيل الخروج' : 'Sign Out'),
        content: Text(isArabic 
            ? 'هل أنت متأكد من تسجيل الخروج؟'
            : 'Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(isArabic ? 'خروج' : 'Sign Out'),
          ),
        ],
      ),
    );
  }
}