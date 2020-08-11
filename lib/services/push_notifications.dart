import 'package:Vertretung/logic/myKeys.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
          if (message["data"]["reason"] == "friendRequest")
            MyKeys.navigatorKey.currentState.pushNamed(Names.friendRequests);
        },
        onLaunch: (Map<String, dynamic> message) {
          if (message["data"]["reason"] == "friendRequest")
            Future.delayed(Duration(seconds: 1)).then(
              (value) => MyKeys.navigatorKey.currentState
                  .pushNamed(Names.friendRequests),
            );
        },
      );

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

  Future<void> signOut() async {
    await _firebaseMessaging.deleteInstanceID();
    return _initialized = false;
  }
}
