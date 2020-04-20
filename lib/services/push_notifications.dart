import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
      _firebaseMessaging.configure(
          onMessage: (Map<String, dynamic> message) async {
        print("$message ist gekommen");
        final SnackBar snackbar = SnackBar(
          content: Text("Neue Inhalte"),
          behavior: SnackBarBehavior.floating,
        );

      });

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }
  void subTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  void unsubTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<String> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
