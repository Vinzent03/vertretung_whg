import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/provider/themedata.dart';

class ProviderData with ChangeNotifier {
  ThemeData themeData;
  ProviderData({this.themeData, this.isDark = true,
      this.isVertretungReload = false, this.isFriendReload =false , this.startAnimation = false});
  bool isDark;
  bool isVertretungReload;
  bool isFriendReload;
  bool startAnimation;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  getTheme() => themeData;

  /// Return true if the dark mode is activated
  getIsDark() => isDark;

  GlobalKey<NavigatorState> getNavigatorKey() => _navigatorKey;

  setDarkTheme() {
    isDark = true;
    SharedPref().setBool(Names.darkmode, true);
    themeData = darkTheme;
    notifyListeners();
  }

  setLightTheme() {
    isDark = false;
    SharedPref().setBool(Names.darkmode, false);
    themeData = lightTheme;
    notifyListeners();
  }

  getVertretungReload() => isVertretungReload;

  setVertretungReload(newBool) {
    isVertretungReload = newBool;
    notifyListeners();
  }

  getAnimation() => startAnimation;

  setAnimation(newBool) {
    startAnimation = newBool;
    notifyListeners();
  }
}
