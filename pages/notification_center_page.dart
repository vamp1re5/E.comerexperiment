import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/notification.dart';

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifications, _) {
              if (notifications.unreadCount == 0) return const SizedBox();
              return TextButton(
                onPressed: () => notifications.markAllAsRead(),
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          final notifications = notificationProvider.allNotifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Dismissible(
                key: Key(notification.id),
                onDismissed: (_) =>
                    notificationProvider.deleteNotification(notification.id),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: notification.read
                      ? Colors.white
                      : Colors.blue[50],
                  child: ListTile(
                    leading: _getNotificationIcon(notification.type),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.read
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.message),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: !notification.read
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () {
                      notificationProvider
                          .markAsRead(notification.id);
                      if (notification.actionUrl != null) {
                        context.push(notification.actionUrl!);
                      }
                    },
              ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icon(Icons.shopping_bag, color: Colors.blue);
      case 'promo':
        return Icon(Icons.local_offer, color: Colors.orange);
      case 'message':
        return Icon(Icons.mail, color: Colors.green);
      default:
        return Icon(Icons.notifications, color: Colors.grey);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
