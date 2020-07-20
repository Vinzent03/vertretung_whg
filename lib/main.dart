import 'package:Vertretung/authentication/logInPage.dart';
import 'package:Vertretung/friends/friendRequests.dart';
import 'package:Vertretung/friends/friendsList.dart';
import 'package:Vertretung/news/newsPage.dart';
import 'package:Vertretung/pages/aboutPage.dart';
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

import 'authentication/changePasswordPage.dart';
import 'logic/sharedPref.dart';
import 'logic/names.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/provider/themedata.dart';
import 'main/splash.dart';
import 'pages/settingsPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPref().getBool(Names.darkmode).then((isDark) {
    runApp(ChangeNotifierProvider<ProviderData>(
      create: (_) => ProviderData(isDark ? darkTheme : lightTheme, isDark),
      child: MyAppSt(),
    ));
  });
}

class MyAppSt extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ProviderData>(context);
    return StreamProvider<FirebaseUser>.value(
      value: AuthService().user,

      //used for the feedback function
      child: Wiredash(
        options: WiredashOptionsData(showDebugFloatingEntryPoint: false),
        theme: WiredashThemeData(
            brightness: Provider.of<ProviderData>(context).getIsDark()
                ? Brightness.dark
                : Brightness.light),
        navigatorKey: _navigatorKey,

        //replace with your own keys from wiredash.io or remove the Wiredash Widget
        secret: WiredashKeys.secret,
        projectId: WiredashKeys.id,

        child: MaterialApp(
          navigatorKey: _navigatorKey,
          theme: theme.getTheme(),
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
            Names.friendRequests: (context) => FriendRequests(),
            Names.friendsList: (context) => FriendsList(),
            Names.logInPage: (context) => LogInPage(),
            Names.changePasswordPage: (context) => ChangePasswordPage(),
          },
        ),
      ),
    );
  }
}
