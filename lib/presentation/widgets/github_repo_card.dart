import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../features/github/models/github_repository.dart';
import '../../features/github/providers/github_provider.dart';

class GitHubRepoCard extends StatelessWidget {
  final GitHubRepository repository;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const GitHubRepoCard({
    super.key,
    required this.repository,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Repository header with name and actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repository.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          repository.fullName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Star toggle
                      Consumer<GitHubProvider>(
                        builder: (context, provider, child) {
                          return IconButton(
                            icon: Icon(
                              repository.isStarred
                                  ? Icons.star
                                  : Icons.star_border,
                              color: repository.isStarred
                                  ? Colors.amber
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              provider.toggleStar(repository.id);
                            },
                            tooltip: isArabic 
                                ? (repository.isStarred ? 'إلغاء النجمة' : 'إضافة نجمة')
                                : (repository.isStarred ? 'Unstar' : 'Star'),
                          );
                        },
                      ),
                      // Watch toggle
                      Consumer<GitHubProvider>(
                        builder: (context, provider, child) {
                          return IconButton(
                            icon: Icon(
                              repository.isWatched
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: repository.isWatched
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              provider.toggleWatch(repository.id);
                            },
                            tooltip: isArabic 
                                ? (repository.isWatched ? 'إلغاء المراقبة' : 'مراقبة')
                                : (repository.isWatched ? 'Unwatch' : 'Watch'),
                          );
                        },
                      ),
                      // Delete button
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: onDelete,
                          tooltip: isArabic ? 'حذف' : 'Delete',
                        ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Category chip
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      repository.category,
                      style: theme.textTheme.labelSmall,
                    ),
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (repository.language!.isNotEmpty)
                    Chip(
                      label: Text(
                        isArabic ? repository.language! : repository.language!,
                        style: theme.textTheme.labelSmall,
                      ),
                      backgroundColor: theme.colorScheme.tertiaryContainer,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              if (repository.description!.isNotEmpty) ...[
                Text(
                  repository.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              
              // Statistics row
              Row(
                children: [
                  _buildStatChip(
                    context,
                    Icons.star_border,
                    repository.stargazersCount.toString(),
                    isArabic ? 'نجمة' : 'Stars',
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.fork_right,
                    repository.forksCount.toString(),
                    isArabic ? 'نسخة' : 'Forks',
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.bug_report_outlined,
                    repository.openIssuesCount.toString(),
                    isArabic ? 'مشكلة' : 'Issues',
                  ),
                  const Spacer(),
                  // Last updated
                  Text(
                    _formatLastUpdated(repository.updatedAt, isArabic),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              
              // Quick actions bar
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(
                        isArabic ? 'عرض التفاصيل' : 'View Details',
                        style: theme.textTheme.labelMedium,
                      ),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<GitHubProvider>(
                    builder: (context, provider, child) {
                      return IconButton(
                        onPressed: () => provider.refreshRepository(repository.id),
                        icon: const Icon(Icons.refresh, size: 20),
                        tooltip: isArabic ? 'تحديث' : 'Refresh',
                        style: IconButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated(DateTime dateTime, bool isArabic) {
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
    } else {
      return isArabic ? 'منذ قليل' : 'Just now';
    }
  }
}
