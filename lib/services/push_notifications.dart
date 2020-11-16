import 'package:Vertretung/data/myKeys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _firebaseMessaging.configure(
        onResume: (Map<String, dynamic> message) {
          if (message["data"]["reason"] == "friendAdded")
            MyKeys.navigatorKey.currentState.pushNamed(Names.friendsList);
        },
        onLaunch: (Map<String, dynamic> message) {
          if (message["data"]["reason"] == "friendRequest")
            Future.delayed(Duration(seconds: 1)).then(
              (value) =>
                  MyKeys.navigatorKey.currentState.pushNamed(Names.friendsList),
            );
        },
      );
      _firebaseMessaging.subscribeToTopic("all");

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");

      _initialized = true;
    }
  }

  Future<void> subTopic(String topic) async {
    if (!kIsWeb) await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubTopic(String topic) async {
    if (!kIsWeb) await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<String> getToken() async {
    if (kIsWeb)
      return null;
    else
      return await _firebaseMessaging.getToken();
  }

  Future<void> signOut() async {
    if (!kIsWeb) await _firebaseMessaging.deleteInstanceID();
    return _initialized = false;
  }
}
