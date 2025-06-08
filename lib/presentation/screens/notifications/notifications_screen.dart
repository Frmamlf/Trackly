import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../features/notifications/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Column(
          children: [
            // Tab bar with action buttons
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Filter chips
                  if (notificationProvider.availableFilters.isNotEmpty) ...[
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: notificationProvider.availableFilters.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: notificationProvider.selectedFilter == null,
                                label: Text(isArabic ? 'الكل' : 'All'),
                                onSelected: (_) => notificationProvider.clearFilter(),
                              ),
                            );
                          }
                          
                          final filter = notificationProvider.availableFilters[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: notificationProvider.selectedFilter == filter,
                              label: Text(_getFilterLabel(filter, isArabic)),
                              onSelected: (_) => notificationProvider.setFilter(filter),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        text: isArabic ? 'الكل' : 'All',
                        icon: Badge(
                          isLabelVisible: notificationProvider.notifications.isNotEmpty,
                          label: Text(notificationProvider.notifications.length.toString()),
                          child: const Icon(Icons.notifications),
                        ),
                      ),
                      Tab(
                        text: isArabic ? 'غير مقروءة' : 'Unread',
                        icon: Badge(
                          isLabelVisible: notificationProvider.unreadCount > 0,
                          label: Text(notificationProvider.unreadCount.toString()),
                          child: const Icon(Icons.mark_email_unread),
                        ),
                      ),
                      Tab(
                        text: isArabic ? 'الإعدادات' : 'Settings',
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tab view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllNotificationsTab(notificationProvider, isArabic),
                  _buildUnreadNotificationsTab(notificationProvider, isArabic),
                  _buildNotificationSettingsTab(isArabic),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllNotificationsTab(NotificationProvider provider, bool isArabic) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final notifications = provider.filteredNotifications;
    
    if (notifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_none,
        title: isArabic ? 'لا توجد إشعارات' : 'No Notifications',
        subtitle: isArabic 
            ? 'ستظهر الإشعارات هنا عند وصولها'
            : 'Notifications will appear here when they arrive',
      );
    }

    return Column(
      children: [
        // Action bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                isArabic 
                    ? '${notifications.length} إشعار'
                    : '${notifications.length} notifications',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (provider.unreadCount > 0) ...[
                TextButton.icon(
                  onPressed: () => provider.markAllAsRead(),
                  icon: const Icon(Icons.done_all, size: 16),
                  label: Text(isArabic ? 'قراءة الكل' : 'Mark all read'),
                ),
                const SizedBox(width: 8),
              ],
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  switch (value) {
                    case 'clear_read':
                      await provider.deleteReadNotifications();
                      break;
                    case 'clear_all':
                      _showClearAllDialog(provider, isArabic);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear_read',
                    child: Row(
                      children: [
                        const Icon(Icons.clear),
                        const SizedBox(width: 8),
                        Text(isArabic ? 'حذف المقروءة' : 'Clear read'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_sweep),
                        const SizedBox(width: 8),
                        Text(isArabic ? 'حذف الكل' : 'Clear all'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Notifications list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification, provider, isArabic);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadNotificationsTab(NotificationProvider provider, bool isArabic) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final unreadNotifications = provider.unreadNotifications;
    
    if (unreadNotifications.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mark_email_read,
        title: isArabic ? 'تم قراءة جميع الإشعارات' : 'All caught up!',
        subtitle: isArabic 
            ? 'لا توجد إشعارات غير مقروءة'
            : 'No unread notifications',
      );
    }

    return Column(
      children: [
        // Action bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                isArabic 
                    ? '${unreadNotifications.length} غير مقروء'
                    : '${unreadNotifications.length} unread',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => provider.markAllAsRead(),
                icon: const Icon(Icons.done_all, size: 16),
                label: Text(isArabic ? 'قراءة الكل' : 'Mark all read'),
              ),
            ],
          ),
        ),
        
        // Unread notifications list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: unreadNotifications.length,
            itemBuilder: (context, index) {
              final notification = unreadNotifications[index];
              return _buildNotificationCard(notification, provider, isArabic);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettingsTab(bool isArabic) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification types section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'أنواع الإشعارات' : 'Notification Types',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // RSS notifications
                  SwitchListTile(
                    title: Text(isArabic ? 'مقالات RSS جديدة' : 'New RSS Articles'),
                    subtitle: Text(isArabic 
                        ? 'إشعار عند وصول مقالات جديدة'
                        : 'Notify when new articles arrive'),
                    value: true,
                    onChanged: (value) {
                      // Implement RSS notification settings
                      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                      notificationProvider.setRssNotificationsEnabled(value);
                    },
                  ),
                  
                  // Product price alerts
                  SwitchListTile(
                    title: Text(isArabic ? 'تنبيهات الأسعار' : 'Price Alerts'),
                    subtitle: Text(isArabic 
                        ? 'إشعار عند تغيير أسعار المنتجات'
                        : 'Notify when product prices change'),
                    value: true,
                    onChanged: (value) {
                      // Implement price alerts notification settings
                      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                      notificationProvider.setPriceAlertsEnabled(value);
                    },
                  ),
                  
                  // GitHub releases
                  SwitchListTile(
                    title: Text(isArabic ? 'إصدارات GitHub جديدة' : 'New GitHub Releases'),
                    subtitle: Text(isArabic 
                        ? 'إشعار عند إصدار نسخة جديدة'
                        : 'Notify when new releases are published'),
                    value: true,
                    onChanged: (value) {
                      // Implement GitHub releases notification settings
                      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                      notificationProvider.setGithubReleasesEnabled(value);
                    },
                  ),
                  
                  // GitHub issues
                  SwitchListTile(
                    title: Text(isArabic ? 'مشاكل GitHub جديدة' : 'New GitHub Issues'),
                    subtitle: Text(isArabic 
                        ? 'إشعار عند إنشاء مشاكل جديدة'
                        : 'Notify when new issues are created'),
                    value: true,
                    onChanged: (value) {
                      // Implement GitHub issues notification settings
                      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                      notificationProvider.setGithubIssuesEnabled(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notification behavior section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'سلوك الإشعارات' : 'Notification Behavior',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Push notifications
                  SwitchListTile(
                    title: Text(isArabic ? 'الإشعارات المباشرة' : 'Push Notifications'),
                    subtitle: Text(isArabic 
                        ? 'إرسال إشعارات للجهاز'
                        : 'Send notifications to device'),
                    value: true,
                    onChanged: (value) {
                      // Implement push notifications settings
                      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                      notificationProvider.setPushNotificationsEnabled(value);
                    },
                  ),
                  
                  // Sound
                  SwitchListTile(
                    title: Text(isArabic ? 'الصوت' : 'Sound'),
                    subtitle: Text(isArabic 
                        ? 'تشغيل صوت مع الإشعارات'
                        : 'Play sound with notifications'),
                    value: true,
                    onChanged: (value) {
                      // Implement sound notification settings
                      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                      notificationProvider.setSoundEnabled(value);
                    },
                  ),
                  
                  // Vibration
                  SwitchListTile(
                    title: Text(isArabic ? 'الاهتزاز' : 'Vibration'),
                    subtitle: Text(isArabic 
                        ? 'اهتزاز الجهاز مع الإشعارات'
                        : 'Vibrate device with notifications'),
                    value: true,
                    onChanged: (value) {
                      // Implement vibration notification settings
                      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                      notificationProvider.setVibrationEnabled(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, NotificationProvider provider, bool isArabic) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
          _openNotificationDetails(notification);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type icon and actions
              Row(
                children: [
                  // Type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Priority and read status
                  Expanded(
                    child: Row(
                      children: [
                        // Priority indicator
                        if (notification.priority != NotificationPriority.normal) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(notification.priority),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getPriorityLabel(notification.priority, isArabic),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        
                        // Unread indicator
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Time
                  Text(
                    _formatNotificationTime(notification.createdAt, isArabic),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  // More actions
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_read':
                          provider.markAsRead(notification.id);
                          break;
                        case 'delete':
                          provider.deleteNotification(notification.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              const Icon(Icons.mark_email_read, size: 16),
                              const SizedBox(width: 8),
                              Text(isArabic ? 'تحديد كمقروء' : 'Mark as read'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 16),
                            const SizedBox(width: 8),
                            Text(isArabic ? 'حذف' : 'Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                notification.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Body
              Text(
                notification.body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog(NotificationProvider provider, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'حذف جميع الإشعارات' : 'Clear All Notifications'),
        content: Text(isArabic 
            ? 'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.'
            : 'Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllNotifications();
              Navigator.pop(context);
            },
            child: Text(isArabic ? 'حذف' : 'Clear'),
          ),
        ],
      ),
    );
  }

  void _openNotificationDetails(NotificationItem notification) {
    // Navigate to relevant screen based on notification type
    switch (notification.type) {
      case NotificationType.rssNewArticle:
        // Navigate to RSS article
        if (notification.data?['articleUrl'] != null) {
          Navigator.pushNamed(
            context,
            '/rss-article',
            arguments: notification.data,
          );
        }
        break;
      case NotificationType.productPriceAlert:
        // Navigate to product details
        if (notification.data?['productUrl'] != null) {
          Navigator.pushNamed(
            context,
            '/product-details',
            arguments: notification.data,
          );
        }
        break;
      case NotificationType.githubNewRelease:
      case NotificationType.githubNewIssue:
        // Navigate to GitHub item
        if (notification.data?['repositoryName'] != null) {
          Navigator.pushNamed(
            context,
            '/github-details',
            arguments: notification.data,
          );
        }
        break;
      case NotificationType.general:
      default:
        // Show notification details dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.title),
            content: Text(notification.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        break;
    }
  }

  String _getFilterLabel(NotificationType type, bool isArabic) {
    switch (type) {
      case NotificationType.rssNewArticle:
        return isArabic ? 'RSS' : 'RSS';
      case NotificationType.productPriceAlert:
        return isArabic ? 'الأسعار' : 'Prices';
      case NotificationType.githubNewRelease:
        return isArabic ? 'الإصدارات' : 'Releases';
      case NotificationType.githubNewIssue:
        return isArabic ? 'المشاكل' : 'Issues';
      case NotificationType.general:
        return isArabic ? 'عام' : 'General';
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.rssNewArticle:
        return Icons.article;
      case NotificationType.productPriceAlert:
        return Icons.price_change;
      case NotificationType.githubNewRelease:
        return Icons.new_releases;
      case NotificationType.githubNewIssue:
        return Icons.bug_report;
      case NotificationType.general:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.rssNewArticle:
        return Colors.blue;
      case NotificationType.productPriceAlert:
        return Colors.green;
      case NotificationType.githubNewRelease:
        return Colors.purple;
      case NotificationType.githubNewIssue:
        return Colors.orange;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  String _getPriorityLabel(NotificationPriority priority, bool isArabic) {
    switch (priority) {
      case NotificationPriority.low:
        return isArabic ? 'منخفض' : 'Low';
      case NotificationPriority.normal:
        return isArabic ? 'عادي' : 'Normal';
      case NotificationPriority.high:
        return isArabic ? 'عالي' : 'High';
      case NotificationPriority.urgent:
        return isArabic ? 'عاجل' : 'Urgent';
    }
  }

  String _formatNotificationTime(DateTime dateTime, bool isArabic) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return DateFormat.yMd().format(dateTime);
    } else if (difference.inDays > 0) {
      final days = difference.inDays;
      return isArabic 
          ? 'منذ $days ${days == 1 ? 'يوم' : 'أيام'}'
          : '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      return isArabic 
          ? 'منذ $hours ${hours == 1 ? 'ساعة' : 'ساعات'}'
          : '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return isArabic 
          ? 'منذ $minutes ${minutes == 1 ? 'دقيقة' : 'دقائق'}'
          : '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return isArabic ? 'منذ قليل' : 'Just now';
    }
  }
}