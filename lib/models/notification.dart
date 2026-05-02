import 'package:flutter/material.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;
  final String type; // 'order', 'system', 'message', 'promo'
  final String? actionUrl;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = false,
    required this.type,
    this.actionUrl,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<Notification> _notifications = [];

  List<Notification> get notifications =>
      _notifications.where((n) => !n.read).toList();
  List<Notification> get allNotifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  void addNotification({
    required String title,
    required String message,
    required String type,
    String? actionUrl,
  }) {
    _notifications.insert(
      0,
      Notification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        timestamp: DateTime.now(),
        type: type,
        actionUrl: actionUrl,
      ),
    );
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    try {
      final index =
          _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        _notifications[index] = Notification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          timestamp: _notifications[index].timestamp,
          read: true,
          type: _notifications[index].type,
          actionUrl: _notifications[index].actionUrl,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = Notification(
        id: _notifications[i].id,
        title: _notifications[i].title,
        message: _notifications[i].message,
        timestamp: _notifications[i].timestamp,
        read: true,
        type: _notifications[i].type,
        actionUrl: _notifications[i].actionUrl,
      );
    }
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
