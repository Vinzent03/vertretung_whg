import 'package:Vertretung/authentication/account_page.dart';
import 'package:Vertretung/data/my_keys.dart';
import 'package:Vertretung/data/wiredash_keys.dart';
import 'package:Vertretung/firebase_options.dart';
import 'package:Vertretung/friends/friend_list.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/pages/help_page.dart';
import 'package:Vertretung/provider/theme_data.dart';
import 'package:Vertretung/provider/theme_settings.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/settings/about_page.dart';
import 'package:Vertretung/settings/settings_page.dart';
import 'package:Vertretung/substitute/substitute_logic.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import "package:wiredash/wiredash.dart";

import 'authentication/change_password_page.dart';
import 'data/names.dart';
import 'main/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_handleBackgroundNotification);
  setPathUrlStrategy();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) async {
    if (!kIsWeb) {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeSettings>(
            create: (_) => ThemeSettings(),
          ),
          ChangeNotifierProvider<UserData>(
            create: (_) => UserData(),
          ),
        ],
        child: MyAppSt(),
      ),
    );
  });
}

class MyAppSt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wiredash(
      theme: WiredashThemeData(
          brightness: context.watch<ThemeSettings>().brightness),

      //replace with your own keys from wiredash.io or remove the Wiredash Widget
      secret: WiredashKeys.secret,
      projectId: WiredashKeys.id,
      options: WiredashOptionsData(
        locale: Locale('de', 'DE'),
      ),
      child: MaterialApp(
        navigatorKey: MyKeys.navigatorKey,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: context.watch<ThemeSettings>().getThemeMode(),
        home: Splash(),
        routes: {
          Names.settingsPage: (context) => SettingsPage(),
          Names.helpPage: (context) => HelpPage(),
          Names.aboutPage: (context) => AboutPage(),
          Names.accountPage: (context) => AccountPage(),
          Names.friendsList: (context) => FriendsList(),
          Names.changePasswordPage: (context) => ChangePasswordPage(),
        },
      ),
    );
  }
}

Future<void> _handleBackgroundNotification(RemoteMessage message) async {
  List<String> rawSubstituteToday =
      message.data["rawSubstituteToday"].split("||");
  List<String> rawSubstituteTomorrow =
      message.data["rawSubstituteTomorrow"].split("||");
  String lastChange =
      SubstituteLogic.formatLastChange(message.data["lastChange"]);
  List<String> dayNames = message.data["dayNames"].split("||");
  Future.wait([
    SharedPref.setStringList(Names.substituteToday, rawSubstituteToday),
    SharedPref.setStringList(Names.substituteTomorrow, rawSubstituteTomorrow),
    SharedPref.setString(Names.lastChange, lastChange),
    SharedPref.setStringList(Names.dayNames, dayNames)
  ]);
}
