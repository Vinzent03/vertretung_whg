import 'package:Vertretung/friends/friendRequests.dart';
import 'package:Vertretung/friends/friendsList.dart';
import 'package:Vertretung/pages/aboutPage.dart';
import 'package:Vertretung/pages/faecherPage.dart';
import 'package:Vertretung/pages/helpPage.dart';
import 'package:Vertretung/pages/introScreen.dart';
import 'package:Vertretung/pages/newsPage.dart';
import 'package:Vertretung/pages/wrapper.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/localDatabase.dart';
import 'logic/names.dart';
import 'logic/theme.dart';
import 'logic/themedata.dart';
import 'pages/settingsPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalDatabase().getBool(Names.dark).then((isDark) {
    runApp(ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(isDark ? darkTheme : lightTheme, isDark),
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
        initialRoute: Names.homePage,
        routes: {
          Names.homePage: (context) => Wrapper(),
          Names.settingsPage: (context) => SettingsPage(),
          Names.helpPage: (context) => HelpPage(),
          Names.introScreen: (context) => IntroScreen(),
          Names.faecherPage: (context) => FaecherPage(),
          Names.newsPage: (context) => NewsPage(),
          Names.aboutPage: (context) => AboutPage(),
          Names.friendRequests: (context) => FriendRequests(),
          Names.friendsList: (context) => FriendsList(),
        },
      ),
    );
  }
}
