import 'package:Vertretung/data/my_keys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/substitute/substitute_logic.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationsManager {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final UserData provider;
  PushNotificationsManager([this.provider]);

  Future<void> init() async {
    RemoteMessage message = await _messaging.getInitialMessage();
    _mayOpenFriendsList(message);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _mayOpenFriendsList(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data["rawSubstituteToday"] != null) {
        List<String> rawSubstituteToday =
            message.data["rawSubstituteToday"].split("||");
        List<String> rawSubstituteTomorrow =
            message.data["rawSubstituteTomorrow"].split("||");
        String lastChange =
            SubstituteLogic().formatLastChange(message.data["lastChange"]);

        provider.rawSubstituteToday = rawSubstituteToday;
        provider.rawSubstituteTomorrow = rawSubstituteTomorrow;
        provider.lastChange = lastChange;
      }
    });
    _messaging.subscribeToTopic("all");
  }

  void _mayOpenFriendsList(RemoteMessage message) {
    if (message == null) return;
    if (message.data["reason"] == "friendAdd")
      MyKeys.navigatorKey.currentState.pushNamed(Names.friendsList);
  }

  Future<void> subTopic(String topic) async {
    if (!kIsWeb) await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubTopic(String topic) async {
    if (!kIsWeb) await _messaging.unsubscribeFromTopic(topic);
  }

  Future<String> getToken() async {
    if (kIsWeb)
      return null;
    else
      return await _messaging.getToken();
  }

  Future<void> signOut() async {
    if (!kIsWeb) await _messaging.deleteToken();
  }
}
