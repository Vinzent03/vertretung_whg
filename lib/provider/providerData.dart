import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/provider/themedata.dart';

class ProviderData with ChangeNotifier {
  ThemeData _themeData;
  ProviderData(this._themeData, this.isDark,
      {this.isVertretungReload = false, this.isFriendReload =false , this.startAnimation = false});
  bool isDark;
  bool isVertretungReload;
  bool isFriendReload;
  bool startAnimation;
  getTheme() => _themeData;

  /// Return true if the dark mode is activated
  getIsDark() => isDark;

  setDarkTheme() {
    isDark = true;
    SharedPref().setBool(Names.darkmode, true);
    _themeData = darkTheme;
    notifyListeners();
  }

  setLightTheme() {
    isDark = false;
    SharedPref().setBool(Names.darkmode, false);
    _themeData = lightTheme;
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
