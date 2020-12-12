import 'package:Vertretung/data/myKeys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/substitute/substituteLogic.dart';
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

        SharedPref sharedPref = SharedPref();
        sharedPref.setStringList(Names.substituteToday, rawSubstituteToday);
        sharedPref.setStringList(
            Names.substituteTomorrow, rawSubstituteTomorrow);
        sharedPref.setString(Names.lastChange, lastChange);

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
