import 'package:Vertretung/authentication/logInPage.dart';
import 'package:Vertretung/friends/friendRequests.dart';
import 'package:Vertretung/friends/friendsList.dart';
import 'package:Vertretung/pages/aboutPage.dart';
import 'package:Vertretung/pages/faecherPage.dart';
import 'package:Vertretung/pages/helpPage.dart';
import 'package:Vertretung/main/introScreen.dart';
import 'package:Vertretung/pages/newsPage.dart';
import 'package:Vertretung/authentication/accountPage.dart';
import 'package:Vertretung/main/wrapper.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authentication/changePasswordPage.dart';
import 'logic/localDatabase.dart';
import 'logic/names.dart';
import 'package:Vertretung/provider/theme.dart';
import 'package:Vertretung/provider/themedata.dart';
import 'main/splash.dart';
import 'pages/settingsPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalDatabase().getBool(Names.dark).then((isDark) {
    runApp(ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(isDark ? darkTheme : lightTheme, isDark,false),
      child: MyAppSt(),
    ));
  });
}

class MyAppSt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return StreamProvider<FirebaseUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        theme: theme.getTheme(),
        initialRoute: Names.splashSceen,
        routes: {
          Names.splashSceen: (context) => Splash(),
          Names.wrapper: (context) => Wrapper(),
          Names.settingsPage: (context) => SettingsPage(),
          Names.helpPage: (context) => HelpPage(),
          Names.introScreen: (context) => IntroScreen(),
          Names.faecherPage: (context) => FaecherPage(),
          Names.newsPage: (context) => NewsPage(),
          Names.aboutPage: (context) => AboutPage(),
          Names.accountPage: (context) => AccountPage(),
          Names.friendRequests: (context) => FriendRequests(),
          Names.friendsList: (context) => FriendsList(),
          Names.logInPage: (context) => LogInPage(),
          Names.changePasswordPage: (context) => ChangePasswordPage(),
        },
      ),
    );
  }
}
