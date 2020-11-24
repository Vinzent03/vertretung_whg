import 'package:Vertretung/authentication/accountPage.dart';
import 'package:Vertretung/data/myKeys.dart';
import 'package:Vertretung/data/wiredashKeys.dart';
import 'package:Vertretung/friends/friendsList.dart';
import 'package:Vertretung/main/introScreen.dart';
import 'package:Vertretung/main/wrapper.dart';
import 'package:Vertretung/news/newsPage.dart';
import 'package:Vertretung/pages/helpPage.dart';
import 'package:Vertretung/provider/themeSettings.dart';
import 'package:Vertretung/provider/themedata.dart';
import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/settings/aboutPage.dart';
import 'package:Vertretung/settings/settingsPage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:wiredash/wiredash.dart";

import 'authentication/changePasswordPage.dart';
import 'data/names.dart';
import 'main/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp().then((value) async {
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
      navigatorKey: MyKeys.navigatorKey,

      //replace with your own keys from wiredash.io or remove the Wiredash Widget
      secret: WiredashKeys.secret,
      projectId: WiredashKeys.id,

      child: MaterialApp(
        navigatorKey: MyKeys.navigatorKey,
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
        ],
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: context.watch<ThemeSettings>().getThemeMode(),
        initialRoute: Names.splashScreen,
        routes: {
          Names.splashScreen: (context) => Splash(),
          Names.wrapper: (context) => Wrapper(),
          Names.settingsPage: (context) => SettingsPage(),
          Names.helpPage: (context) => HelpPage(),
          Names.introScreen: (context) => IntroScreen(),
          Names.newsPage: (context) => NewsPage(),
          Names.aboutPage: (context) => AboutPage(),
          Names.accountPage: (context) => AccountPage(),
          Names.friendsList: (context) => FriendsList(),
          Names.changePasswordPage: (context) => ChangePasswordPage(),
        },
      ),
    );
  }
}
