import 'package:car_app/models/notification.dart';
import 'package:flutter/cupertino.dart';

class NotificationService with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  get notifications => _notifications;

  set notifications(notifications) {
    _notifications = notifications;
    notifyListeners();
  }

  set singleNotification(notification) {
    var index =
        _notifications.indexWhere((element) => element.id == notification.id);
    _notifications[index] = notification;
    notifyListeners();
  }

  addNotification(notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  addNotifications(notifications) {
    _notifications.addAll(notifications);
    notifyListeners();
  }
}
