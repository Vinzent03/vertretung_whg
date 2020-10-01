import 'package:Vertretung/friends/friendsList.dart';
import 'package:Vertretung/logic/myKeys.dart';
import 'package:Vertretung/news/newsPage.dart';
import 'package:Vertretung/settings/aboutPage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:wiredash/wiredash.dart";
import 'package:Vertretung/pages/helpPage.dart';
import 'package:Vertretung/main/introScreen.dart';
import 'package:Vertretung/authentication/accountPage.dart';
import 'package:Vertretung/main/wrapper.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Vertretung/logic/wiredashKeys.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'authentication/changePasswordPage.dart';
import 'logic/names.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/provider/themedata.dart';
import 'package:Vertretung/settings/settingsPage.dart';
import 'main/splash.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Firebase.initializeApp().then((value) {
    if (!kIsWeb)
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(
      ChangeNotifierProvider<ProviderData>(
        create: (_) => ProviderData(themeData: darkTheme),
        child: MyAppSt(),
      ),
    );
  });
}

class MyAppSt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderData>(context);
    return StreamProvider<User>.value(
      value: AuthService().user,
      //used for the feedback function
      child: Wiredash(
        options: WiredashOptionsData(showDebugFloatingEntryPoint: false),
        theme: WiredashThemeData(brightness: provider.getUsedTheme()),
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
          themeMode: provider.getThemeMode(),
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
      ),
    );
  }
}
