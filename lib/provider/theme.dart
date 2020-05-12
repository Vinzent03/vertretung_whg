import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/provider/themedata.dart';
class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;
  ThemeChanger(this._themeData,this.isDark,this.newRestore);
  bool isDark;
  bool newRestore;
  getTheme() => _themeData;
  getIsDark() => isDark;

  setDarkTheme() {
    isDark = true;
    LocalDatabase().setBool(Names.dark, true);
    _themeData = darkTheme;
    notifyListeners();
  }

  setLightTheme() {
    isDark= false;
    LocalDatabase().setBool(Names.dark, false);
    _themeData = lightTheme;
    notifyListeners();
  }
  

  getRestore()=> newRestore;

  setRestore(restore){
    newRestore = restore;
    notifyListeners();
  }

}
