import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../notifications/domain/notification_item.dart';
import '../../../notifications/presentation/notifications_providers.dart';

class NotificationSheet extends ConsumerWidget {
  const NotificationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationSheet(),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 45) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('dd MMM, hh:mm a').format(dt);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final colors = context.colors;

    final sheetBg = colors.surface;
    final onSurface = colors.textPrimary;
    final onSurfaceVariant = colors.textSecondary;
    final outlineVariant = colors.border;
    final primaryColor = colors.primary;

    return Material(
      color: sheetBg,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Title Row
            Row(
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (unreadCount > 0)
                  InkWell(
                    onTap: () {
                      ref.read(notificationsProvider.notifier).markAllAsRead();
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        'Mark all as read',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, color: onSurfaceVariant, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, thickness: 1, color: colors.divider),
            const SizedBox(height: 12),

            // Notifications List
            Flexible(
              child: notifications.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return _buildNotificationItem(context, ref, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
  ) {
    final colors = context.colors;
    final onSurface = colors.textPrimary;
    final onSurfaceVariant = colors.textSecondary;
    final outlineVariant = colors.border;

    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (item.type) {
      case NotificationType.orderBuy:
        icon = Icons.shopping_bag_outlined;
        iconColor = colors.gain;
        iconBg = colors.gainBg;
        break;
      case NotificationType.orderSell:
        icon = Icons.sell_outlined;
        iconColor = colors.loss;
        iconBg = colors.lossBg;
        break;
      case NotificationType.orderFailure:
        icon = Icons.error_outline;
        iconColor = colors.loss;
        iconBg = colors.lossBg;
        break;
      case NotificationType.watchlist:
        icon = Icons.featured_play_list_outlined;
        iconColor = colors.primary;
        iconBg = colors.primary.withValues(alpha: 0.12);
        break;
      case NotificationType.holding:
        icon = Icons.account_balance_wallet_outlined;
        iconColor = colors.primaryLight;
        iconBg = colors.primaryLight.withValues(alpha: 0.12);
        break;
      case NotificationType.system:
        icon = Icons.info_outline;
        iconColor = colors.textSecondary;
        iconBg = colors.chipBackground;
        break;
    }

    final isUnread = !item.isRead;
    final itemBg = isUnread ? colors.surfaceElevated : colors.chipBackground;

    return Dismissible(
      key: ValueKey('notification_${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(notificationsProvider.notifier).removeNotification(item.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colors.loss.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.delete_outline, color: colors.loss, size: 20),
      ),
      child: InkWell(
        onTap: () {
          if (isUnread) {
            ref.read(notificationsProvider.notifier).markAsRead(item.id);
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isUnread ? colors.primary.withValues(alpha: 0.3) : outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: onSurface,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        Text(
                          _formatTimeAgo(item.timestamp),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: isUnread ? colors.primary : onSurfaceVariant,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.chipBackground,
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 28,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Real-time updates about your orders, holdings, and watchlists will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: colors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
