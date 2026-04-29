//Notification Banners

import 'package:flutter/material.dart';

class NotificationBanners extends StatelessWidget {
  const NotificationBanners({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Banners')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.withValues(alpha: 0.2),
            child: ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blue[700]),
              title: const Text('Info'),
              subtitle: const Text('Your changes have been saved.'),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green.withValues(alpha: 0.2),
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green[700]),
              title: const Text('Success'),
              subtitle: const Text('Payment completed successfully.'),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.orange.withValues(alpha: 0.2),
            child: ListTile(
              leading: Icon(Icons.warning_amber_outlined, color: Colors.orange[700]),
              title: const Text('Warning'),
              subtitle: const Text('Your session will expire soon.'),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.red.withValues(alpha: 0.2),
            child: ListTile(
              leading: Icon(Icons.error_outline, color: Colors.red[700]),
              title: const Text('Error'),
              subtitle: const Text('Something went wrong. Please try again.'),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
            ),
          ),
        ],
      ),
    );
  }
}


//Notification Center

import 'package:flutter/material.dart';

const _notifications = [
  {'title': 'New message', 'body': 'Sarah replied to your comment', 'time': '2m ago', 'read': false},
  {'title': 'Order shipped', 'body': 'Your order #1234 is on the way', 'time': '1h ago', 'read': true},
  {'title': 'Reminder', 'body': 'Team meeting starts in 30 min', 'time': '3h ago', 'read': true},
];

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all read')),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, i) {
          final n = _notifications[i];
          final unread = n['read'] as bool == false;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: unread ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: unread ? Colors.blue.withValues(alpha: 0.2) : Colors.grey[300],
                child: Icon(Icons.notifications, color: unread ? Colors.blue[700] : Colors.grey[600]),
              ),
              title: Text(n['title'] as String),
              subtitle: Text(n['body'] as String),
              trailing: Text(n['time'] as String, style: Theme.of(context).textTheme.bodySmall),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}


//Notification Settings

import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  var _push = true;
  var _email = true;
  var _marketing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications on your device'),
            value: _push,
            onChanged: (v) => setState(() => _push = v),
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Get updates via email'),
            value: _email,
            onChanged: (v) => setState(() => _email = v),
          ),
          SwitchListTile(
            title: const Text('Marketing'),
            subtitle: const Text('Promotional offers and news'),
            value: _marketing,
            onChanged: (v) => setState(() => _marketing = v),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Quiet Hours'),
            subtitle: const Text('10:00 PM - 8:00 AM'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
