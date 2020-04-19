import 'package:Vertretung/logic/getter.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/logic/themedata.dart';
class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;
  ThemeChanger(this._themeData,this.isDark);
  bool isDark;
  getTheme() => _themeData;
  getIsDark() => isDark;


  setDarkTheme() {
    isDark = true;
    Getter().setBool(Names.dark, true);
    _themeData = darkTheme;
    notifyListeners();
  }

  setLightTheme() {
    isDark= false;
    Getter().setBool(Names.dark, false);
    _themeData = lightTheme;
    notifyListeners();
  }


}
