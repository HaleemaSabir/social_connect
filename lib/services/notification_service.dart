import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new notification for a user
  Future<void> addNotification(String toUserId, String message) async {
    await _firestore.collection('notifications').add({
      'toUserId': toUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  /// Get notifications for current logged-in user
  Stream<QuerySnapshot> getUserNotifications() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  /// Clear all notifications for a user
  Future<void> clearAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docs = await _firestore
        .collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .get();

    for (var doc in docs.docs) {
      await doc.reference.delete();
    }
  }
}
