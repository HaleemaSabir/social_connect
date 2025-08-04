class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final List<String> _notifications = [];

  List<String> get notifications => _notifications;

  void addNotification(String message) {
    _notifications.insert(0, message); // Insert at top
  }

  void clearNotifications() {
    _notifications.clear();
  }
}
