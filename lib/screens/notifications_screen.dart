import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_connect/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"), backgroundColor: Colors.teal),
      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationService().getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notifications"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;
          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications yet"));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final message = notification['message'] ?? '';
              final read = notification['read'] ?? false;

              return ListTile(
                title: Text(message),
                tileColor: read ? Colors.white : Colors.teal[50],
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    NotificationService().markAsRead(notification.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
        onPressed: () {
          NotificationService().clearAll();
        },
      ),
    );
  }
}
