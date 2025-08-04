import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService().notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: "Clear All",
            onPressed: () {
              NotificationService().clearNotifications();
              Navigator.pop(context); // Go back and reopen to refresh
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications"))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(notifications[index]),
        ),
      ),
    );
  }
}
